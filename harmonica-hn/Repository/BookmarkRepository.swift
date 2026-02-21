//
//  BookmarkRepository.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//


import CoreData

class BookmarkRepository {
    static let shared = BookmarkRepository()
    
    private let persistence = PersistenceController.shared
    
    // Check if story is bookmarked
    func isBookmarked(storyID: Int) -> Bool {
        let ctx = persistence.container.viewContext
        let request = BookmarkedStory.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", storyID)
        return (try? ctx.count(for: request)) ?? 0 > 0
    }
    
    // Toggle bookmark
    func toggleBookmark(story: Story) {
        if isBookmarked(storyID: story.id) {
            removeBookmark(storyID: story.id)
        } else {
            addBookmark(story: story)
        }
    }
    
    func addBookmark(story: Story) {
        let ctx = persistence.container.viewContext
        let bookmark = BookmarkedStory(context: ctx)
        bookmark.id = Int64(story.id)
        bookmark.title = story.title
        bookmark.url = story.url
        bookmark.by = story.author_
        bookmark.score = Int32(story.points_)
        bookmark.descendants = Int32(story.commentCount)
        bookmark.time = story.time
        bookmark.bookmarkedAt = Date()
        try? ctx.save()
    }
    
    func removeBookmark(storyID: Int) {
        let ctx = persistence.container.viewContext
        let request = BookmarkedStory.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", storyID)
        if let results = try? ctx.fetch(request) {
            results.forEach { ctx.delete($0) }
            try? ctx.save()
        }
    }
    
    func allBookmarks() -> [Story] {
        let ctx = persistence.container.viewContext
        let request = BookmarkedStory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "bookmarkedAt", ascending: false)]
        let results = (try? ctx.fetch(request)) ?? []
        return results.map { b in
            Story(
                id: Int(b.id),
                title: b.title ?? "",
                url: b.url,
                score: Int(b.score),
                by: b.by,
                time: b.time,
                descendants: Int(b.descendants),
                kids: nil, type: "story", text: nil
            )
        }
    }
    
    // Export bookmarks as text
    func exportAsText() -> String {
        allBookmarks().map { "\($0.id) \($0.title)\n\($0.url ?? "")" }
            .joined(separator: "\n\n")
    }
}
