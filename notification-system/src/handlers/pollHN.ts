import { Env, UserPreferences } from "../types";
import { fetchHNUser, fetchHNItem } from "../services/hnService";
import { sendPushNotification } from "../services/pushService";

export async function handlePollHN(env: Env): Promise<void> {
    console.log("Starting HN Poll...");

    // 1. Get all registered users from KV
    const listResult = await env.HN_DB.list({ prefix: "user:" });
    const keys = listResult.keys;

    for (const key of keys) {
        const username = key.name.replace("user:", "");

        // Get preferences for this user
        const prefsStr = await env.HN_DB.get(key.name);
        if (!prefsStr) continue;

        // Fallback for older data format which was just string[] of tokens
        let prefs: UserPreferences;
        try {
            const parsed = JSON.parse(prefsStr);
            if (Array.isArray(parsed)) {
                prefs = { deviceTokens: parsed, watchedItemIds: [], watchAllReplies: true, rateLimitHits: 0, lastResetTime: Date.now() };
            } else {
                prefs = parsed;
            }
        } catch { continue; }

        if (prefs.deviceTokens.length === 0) continue;

        // Reset rate limits every 24 hours
        const ONE_DAY = 24 * 60 * 60 * 1000;
        if (Date.now() - prefs.lastResetTime > ONE_DAY) {
            prefs.rateLimitHits = 0;
            prefs.lastResetTime = Date.now();
        }

        // Rate limiting: Stop processing this user if they hit > 100 notifications a day
        if (prefs.rateLimitHits > 100) {
            console.log(`User ${username} exceeded daily APNs quota (100). Skipping.`);
            continue;
        }

        let itemsToCheck = new Set<number>();

        // 2. Fetch User Profile from HN (if they want all replies)
        if (prefs.watchAllReplies) {
            const hnUser = await fetchHNUser(username);
            if (hnUser && hnUser.submitted) {
                // Tracking only top 15 recent submissions to save resources
                hnUser.submitted.slice(0, 15).forEach(id => itemsToCheck.add(id));
            }
        }

        // Add specific items they requested to watch
        prefs.watchedItemIds.forEach(id => itemsToCheck.add(id));

        let updatedPrefs = false;

        // 3. Process the collected items to check
        for (const itemId of Array.from(itemsToCheck)) {
            // Fetch current item state
            const hnItem = await fetchHNItem(itemId);
            if (!hnItem) continue;

            const currentKids = hnItem.kids || [];

            // Fetch cached state from KV
            const cachedItemStr = await env.HN_DB.get(`item:${itemId}`);
            let cachedKids: number[] = cachedItemStr ? JSON.parse(cachedItemStr) : [];

            // Simple diff: Are there new kids?
            const newKids = currentKids.filter(k => !cachedKids.includes(k));

            if (newKids.length > 0) {
                console.log(`Found ${newKids.length} new replies for item ${itemId}`);

                for (const newKid of newKids) {
                    if (prefs.rateLimitHits < 100) {
                        await sendPushNotification(prefs.deviceTokens, newKid, itemId);
                        prefs.rateLimitHits++;
                        updatedPrefs = true;
                    }
                }

                // Update cache
                await env.HN_DB.put(`item:${itemId}`, JSON.stringify(currentKids), {
                    expirationTtl: 60 * 60 * 24 * 7 // Expire cache after 7 days automatically
                });
            } else if (!cachedItemStr && currentKids.length > 0) {
                // If we never cached it before, cache it now
                await env.HN_DB.put(`item:${itemId}`, JSON.stringify(currentKids), {
                    expirationTtl: 60 * 60 * 24 * 7
                });
            }
        }

        // If we increased the rate limit counter, save it back
        if (updatedPrefs) {
            await env.HN_DB.put(key.name, JSON.stringify(prefs));
        }
    }
}
