import { HNItem, HNUser } from "../types";

export async function fetchHNUser(username: string): Promise<HNUser | null> {
    const res = await fetch(`https://hacker-news.firebaseio.com/v0/user/${username}.json`);
    if (!res.ok) return null;
    return await res.json();
}

export async function fetchHNItem(itemId: number): Promise<HNItem | null> {
    const res = await fetch(`https://hacker-news.firebaseio.com/v0/item/${itemId}.json`);
    if (!res.ok) return null;
    return await res.json();
}
