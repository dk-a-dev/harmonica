# Harmonica

A native Swift/SwiftUI Hacker News client inspired by [Harmonic for Android](https://github.com/SimonHalvdansson/Harmonic-HN).

Built with SwiftUI, Core Data, and zero third-party dependencies.

---

## Screenshots

> screenshots

---

## Features

- **Best, New, Ask, Show, Jobs** feeds
- **Time filter** — 24h / 48h / Week / Month / All
- **In-app WebView** with progress bar, back/forward navigation, share
- **Bookmarks** — save stories, export as text
- **Comments** — full threaded view with collapse/expand
- **User profiles** — karma, bio, submissions
- **Search** — powered by Algolia full-text search
- **Submit** — post stories to HN
- **Offline caching** — Core Data cache with smart expiry
- **7 themes** including 3 animated Liquid UI themes

---

## Architecture

```
harmonica-hn/
├── Models/              Pure Swift structs (API models)
├── CoreData/            Core Data stack + entity extensions
├── Repository/          Cache-first data layer
├── Services/            Network layer (HN Firebase + Algolia)
├── ViewModels/          @Observable state management
├── Views/               SwiftUI views
├── Theme/               Theme definitions + liquid animations
└── Utilities/           HTML parser, date formatter, extensions
```

### Data Flow
```
View → ViewModel → Repository → Cache (Core Data)
                              ↓ (if stale/empty)
                              → Service (Network)
                              → Cache (save)
                              → ViewModel → View
```

---

## APIs Used

### HN Firebase API
```
https://hacker-news.firebaseio.com/v0/
```
- `/beststories.json` — Best story IDs
- `/newstories.json` — New story IDs
- `/askstories.json` — Ask HN IDs
- `/showstories.json` — Show HN IDs
- `/jobstories.json` — Jobs IDs
- `/item/{id}.json` — Story or comment detail
- `/user/{id}.json` — User profile

### Algolia Search API
```
https://hn.algolia.com/api/v1/
```
- `/search?tags=front_page` — Front page stories
- `/search_by_date?query=...` — Full text search
- `/items/{id}` — Story with full comment tree
- `/search_by_date?tags=author_{username}` — User submissions

### Cache Expiry
| Data | Duration |
|------|----------|
| Best stories | 10 min |
| New stories | 5 min |
| Ask / Show / Jobs | 15 min |
| Comments | 5 min |
| User profiles | 30 min |

---

## Requirements

- Xcode 15+
- iOS 17+ / macOS 14+
- Swift 5.9+
- No third-party dependencies

---

## Setup

1. Clone the repo
2. Open `harmonica-hn.xcodeproj` in Xcode
3. Select your target device (iPhone simulator or My Mac)
4. Press `Cmd+R` to run

No API keys required — both HN Firebase and Algolia APIs

---

## Building for macOS

The app uses SwiftUI Multiplatform — macOS support is built in from day one.

Select **My Mac** in the Xcode device picker and press Run.

All platform-specific code is wrapped in `#if os(iOS)` / `#if os(macOS)` blocks so both targets compile cleanly.

---

## Roadmap

- [x] HN login + voting
- [ ] Push notifications for replies
- [ ] iCloud sync for bookmarks  
- [x] iPad optimised split view
- [ ] Home screen widget — top story of the day
- [ ] Filter stories by keyword / domain
- [ ] Comment navigation buttons (jump between top-level)
- [x] Font size settings
- [x] Reader mode in WebView

---

## Credits

- Original Harmonic Android app by [Simon Halvdansson](https://github.com/SimonHalvdansson/Harmonic-HN)
- [HN Firebase API](https://github.com/HackerNews/API)
- [Algolia HN Search API](https://hn.algolia.com/api)