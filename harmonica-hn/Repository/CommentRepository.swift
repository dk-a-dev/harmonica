//
//  CommentRepository.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//


import CoreData

actor CommentRepository {
    static let shared = CommentRepository()
    
    private let persistence = PersistenceController.shared
    private let algoliaService = AlgoliaService.shared
    
    func fetchComments(storyID: Int, forceRefresh: Bool = false) async throws -> AlgoliaService.AlgoliaItem {
        // Check cache
        if !forceRefresh {
            let cached = fetchCachedComments(storyID: storyID)
            if !cached.isEmpty, let first = cached.first, first.isFresh(maxAge: 300) {
                print("📦 Comment cache hit for story \(storyID)")
                return buildAlgoliaItem(storyID: storyID, from: cached)
            }
        }
        
        // Network fetch
        print("🌐 Fetching comments for story \(storyID)")
        let item = try await algoliaService.fetchItemWithComments(id: storyID)
        
        // Cache in background
        Task.detached {
            await self.cacheComments(item.children ?? [], storyID: storyID)
        }
        
        return item
    }
    
    private func fetchCachedComments(storyID: Int) -> [CachedComment] {
        let ctx = persistence.container.viewContext
        let request = CachedComment.fetchRequest()
        request.predicate = NSPredicate(format: "storyID == %d", storyID)
        request.sortDescriptors = [NSSortDescriptor(key: "depth", ascending: true)]
        return (try? ctx.fetch(request)) ?? []
    }
    
    private func cacheComments(_ comments: [AlgoliaService.AlgoliaComment], storyID: Int) async {
        let ctx = persistence.backgroundContext
        await ctx.perform {
            // Delete old
            let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CachedComment")
            deleteRequest.predicate = NSPredicate(format: "storyID == %d", storyID)
            try? ctx.execute(NSBatchDeleteRequest(fetchRequest: deleteRequest))
            
            // Flatten and insert
            func insertFlat(_ comments: [AlgoliaService.AlgoliaComment]) {
                for comment in comments {
                    let cached = CachedComment(context: ctx)
                    cached.populate(from: comment, storyID: storyID)
                    if let children = comment.children { insertFlat(children) }
                }
            }
            insertFlat(comments)
            try? ctx.save()
        }
    }
    
    private func buildAlgoliaItem(storyID: Int, from cached: [CachedComment]) -> AlgoliaService.AlgoliaItem {
        let comments = cached.map { $0.toAlgoliaComment() }
        return AlgoliaService.AlgoliaItem(
            id: storyID, title: nil, url: nil,
            points: nil, author: nil, createdAt: nil,
            numComments: comments.count, children: comments
        )
    }
}