import { Env, UserPreferences } from "../types";

export async function handleRegisterDevice(request: Request, env: Env): Promise<Response> {
    if (request.method !== "POST") {
        return new Response("Method Not Allowed", { status: 405 });
    }

    try {
        const data: any = await request.json();
        const { hn_username, device_token, watch_all_replies = true, watched_item_ids = [] } = data;

        if (!hn_username || !device_token) {
            return new Response("Missing username or token", { status: 400 });
        }

        // Rate Limiting on registration (Max 10 registrations per minute per IP)
        const ip = request.headers.get("CF-Connecting-IP") || "unknown";
        const rlKey = `rl:reg:${ip}`;
        const rlCountStr = await env.HN_DB.get(rlKey);
        let rlCount = rlCountStr ? parseInt(rlCountStr) : 0;
        if (rlCount > 10) {
            return new Response("Too Many Requests", { status: 429 });
        }
        await env.HN_DB.put(rlKey, (rlCount + 1).toString(), { expirationTtl: 60 });

        // Store in KV: Key: `user:${hn_username}`, Value: UserPreferences
        const existingPrefsStr = await env.HN_DB.get(`user:${hn_username}`);
        let prefs: UserPreferences;

        if (existingPrefsStr) {
            try {
                const parsed = JSON.parse(existingPrefsStr);
                if (Array.isArray(parsed)) {
                    // Backward compatibility for old simple string array
                    prefs = {
                        deviceTokens: parsed,
                        watchedItemIds: [],
                        watchAllReplies: true,
                        rateLimitHits: 0,
                        lastResetTime: Date.now()
                    };
                } else {
                    prefs = parsed;
                }
            } catch {
                prefs = { deviceTokens: [], watchedItemIds: [], watchAllReplies: true, rateLimitHits: 0, lastResetTime: Date.now() };
            }
        } else {
            prefs = {
                deviceTokens: [],
                watchedItemIds: [],
                watchAllReplies: true,
                rateLimitHits: 0,
                lastResetTime: Date.now()
            };
        }

        if (!prefs.deviceTokens) prefs.deviceTokens = [];
        if (!prefs.watchedItemIds) prefs.watchedItemIds = [];

        if (!prefs.deviceTokens.includes(device_token)) {
            prefs.deviceTokens.push(device_token);
        }

        // Enforce max specific item tracking to save resources (e.g. limit to 3 or a custom number)
        const MAX_WATCHED_ITEMS = 5;
        prefs.watchAllReplies = watch_all_replies;
        prefs.watchedItemIds = Array.from(new Set([...prefs.watchedItemIds, ...watched_item_ids])).slice(0, MAX_WATCHED_ITEMS);

        await env.HN_DB.put(`user:${hn_username}`, JSON.stringify(prefs));

        return new Response(JSON.stringify({ success: true, prefs }), {
            headers: { "Content-Type": "application/json" }
        });
    } catch (e: any) {
        return new Response("Error: " + e.message, { status: 500 });
    }
}
