## Push Notifications Backend (Cloudflare Worker)
This project includes a fully functional, highly scalable Cloudflare Worker in the `notification-system` directory that periodically polls Hacker News for replies and dispatches Apple Push Notifications (APNs) directly to users' devices.

### Setting up APNs for the Notification Server
If you have a paid Apple Developer account and want to run the Push Notification server yourself:
1. Go to `developer.apple.com` > **Certificates, Identifiers & Profiles** > **Keys**.
2. Create a new Key with the **Apple Push Notifications service (APNs)** capability.
3. Download the `.p8` file.
4. Duplicate the `notification-system/.dev.vars.example` file and rename it to `.dev.vars`.
5. Fill in your `APNS_TEAM_ID` (10 characters), `APNS_KEY_ID` (10 characters), `APNS_BUNDLE_ID`, and the contents of your `.p8` file (replacing actual newlines with `\n` so it fits on one line).
6. Run `npm install` and `npx wrangler deploy` to push it to Cloudflare!

> **Note on Free Developer Accounts:** Apple strictly restricts Remote Push Notifications to paid developer accounts. If you are using a free account, you cannot use the Cloudflare worker. Instead, the Harmonica HN iOS app includes a fallback **Background Fetch** system that checks for replies locally.