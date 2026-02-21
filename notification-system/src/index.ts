import { Env } from "./types";
import { handleRegisterDevice } from "./handlers/registerDevice";
import { handlePollHN } from "./handlers/pollHN";

export default {
    // 1. Endpoint for registering a device token
    async fetch(
        request: Request,
        env: Env,
        ctx: ExecutionContext
    ): Promise<Response> {
        const url = new URL(request.url);
        if (url.pathname === "/register_device") {
            return handleRegisterDevice(request, env);
        }
        return new Response("Not Found", { status: 404 });
    },

    // 2. Cron trigger for polling Hacker News
    async scheduled(
        controller: ScheduledController,
        env: Env,
        ctx: ExecutionContext
    ): Promise<void> {
        ctx.waitUntil(handlePollHN(env));
    }
};
