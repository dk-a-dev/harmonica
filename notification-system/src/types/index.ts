export interface Env {
    HN_DB: KVNamespace;
    APNS_TEAM_ID: string;
    APNS_KEY_ID: string;
    APNS_BUNDLE_ID: string;
    APNS_PRIVATE_KEY: string;
}

export interface HNItem {
    id: number;
    kids?: number[];
    type: string;
}

export interface HNUser {
    id: string;
    submitted?: number[];
}

export interface UserPreferences {
    deviceTokens: string[];
    watchedItemIds: number[]; // specific items the user wants to watch (allow 3 per some)
    watchAllReplies: boolean; // if false, only track watchedItemIds
    rateLimitHits: number;
    lastResetTime: number;
}
