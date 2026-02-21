import { importPKCS8, SignJWT } from "jose";
import { Env } from "../types";

export async function sendPushNotification(tokens: string[], newKidId: number, parentId: number, env: Env) {
    if (!env.APNS_TEAM_ID || !env.APNS_KEY_ID || !env.APNS_BUNDLE_ID || !env.APNS_PRIVATE_KEY) {
        console.log("[PUSH MOCK] APNs Credentials missing. Mocking payload:");
        console.log(`Payload: {"item_id": ${newKidId}, "parent_id": ${parentId}}`);
        return;
    }

    // 1. Generate JWT
    const privateKeyObj = await importPKCS8(env.APNS_PRIVATE_KEY, 'ES256');

    const jwt = await new SignJWT({})
        .setProtectedHeader({ alg: 'ES256', kid: env.APNS_KEY_ID })
        .setIssuer(env.APNS_TEAM_ID)
        .setIssuedAt()
        .sign(privateKeyObj);

    // 2. We use mutable-content: 1 to wake up the NotificationServiceExtension on iOS
    // so the iPhone can fetch the comment text in the background before showing the alert.
    const payload = {
        aps: {
            alert: {
                title: "New Reply",
                body: "Loading content..." // Placeholder, extension replaces this
            },
            "mutable-content": 1,
            sound: "default"
        },
        item_id: newKidId,
        parent_id: parentId
    };

    const isSandbox = true; // Use api.sandbox for debug builds, api.push for App Store
    const host = isSandbox ? "https://api.sandbox.push.apple.com" : "https://api.push.apple.com";

    // 3. Dispatch to all tokens
    for (const token of tokens) {
        try {
            const response = await fetch(`${host}/3/device/${token}`, {
                method: 'POST',
                headers: {
                    'authorization': `bearer ${jwt}`,
                    'apns-topic': env.APNS_BUNDLE_ID,
                    'apns-push-type': 'alert'
                },
                body: JSON.stringify(payload)
            });

            console.log(`[APNs POST] ${token.substring(0, 8)}... : Status ${response.status}`);
            if (response.status !== 200) {
                const errorText = await response.text();
                console.error(`APNs Error: ${errorText}`);
            }
        } catch (e: any) {
            console.error(`Failed to send to ${token}: ${e.message}`);
        }
    }
}
