//
//  StoryRepository.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//


import CoreData

// The Repository pattern:
// ViewModels ONLY talk to Repository
// Repository decides: use cache or hit network?
// Network calls go through Services

actor StoryRepository {
    static let shared = StoryRepository()
    
    private let persistence = PersistenceController.shared
    private let hnService = HNService.shared
    private let algoliaService = AlgoliaService.shared
    
    // MARK: - Fetch Stories
    
    func fetchStories(feedType: String, forceRefresh: Bool = false) async throws -> [Story] {
        if feedType == "bookmarked" {
            return BookmarkRepository.shared.allBookmarks()
        }
        
        // 1. Check cache first
        if !forceRefresh {
            let cached = fetchCachedStories(feedType: feedType)
            if !cached.isEmpty && cached.allSatisfy({ $0.isFresh() }) {
                print("📦 Cache hit for \(feedType)")
                return cached.map { $0.toStory() }
            }
        }
        
        // 2. Cache miss or stale — fetch from network
        print("🌐 Network fetch for \(feedType)")
        let stories = try await fetchFromNetwork(feedType: feedType)
        
        // 3. Save to cache in background
        Task.detached {
            await self.cacheStories(stories, feedType: feedType)
        }
        
        return stories
    }
    
    // MARK: - Cache Read
    
    private func fetchCachedStories(feedType: String) -> [CachedStory] {
        let ctx = persistence.container.viewContext
        let request = CachedStory.fetchRequest()
        request.predicate = NSPredicate(format: "feedType == %@", feedType)
        request.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: true)]
        request.fetchLimit = 30
        return (try? ctx.fetch(request)) ?? []
    }
    
    // MARK: - Cache Write
    
    private func cacheStories(_ stories: [Story], feedType: String) async {
        let ctx = persistence.backgroundContext
        
        await ctx.perform {
            // Delete old cached stories for this feed
            let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CachedStory")
            deleteRequest.predicate = NSPredicate(format: "feedType == %@", feedType)
            let batchDelete = NSBatchDeleteRequest(fetchRequest: deleteRequest)
            try? ctx.execute(batchDelete)
            
            // Insert new ones
            for (index, story) in stories.enumerated() {
                let cached = CachedStory(context: ctx)
                cached.populate(from: story, feedType: feedType, rank: index)
            }
            
            try? ctx.save()
            print("✅ Cached \(stories.count) stories for \(feedType)")
        }
    }
    
    // MARK: - Clear Cache
    
    func clearCache(feedType: String? = nil) async {
        let ctx = persistence.backgroundContext
        await ctx.perform {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CachedStory")
            if let feedType = feedType {
                request.predicate = NSPredicate(format: "feedType == %@", feedType)
            }
            let batch = NSBatchDeleteRequest(fetchRequest: request)
            try? ctx.execute(batch)
            try? ctx.save()
        }
    }
    
    // MARK: - Network Fetch
    
    private func fetchFromNetwork(feedType: String) async throws -> [Story] {
        switch feedType {
        case "top":
            return try await algoliaService.fetchTopStories(hitsPerPage: 30)
        case "new":
            let ids = try await hnService.fetchNewStoryIDs()
            return try await hnService.fetchStories(ids: ids, limit: 30)
        case "ask":
            let ids = try await hnService.fetchAskStoryIDs()
            return try await hnService.fetchStories(ids: ids, limit: 30)
        case "show":
            let ids = try await hnService.fetchShowStoryIDs()
            return try await hnService.fetchStories(ids: ids, limit: 30)
        case "jobs":
            let ids = try await hnService.fetchJobStoryIDs()
            return try await hnService.fetchStories(ids: ids, limit: 30)
        default:
            return try await algoliaService.fetchTopStories(hitsPerPage: 30)
        }
    }
}
