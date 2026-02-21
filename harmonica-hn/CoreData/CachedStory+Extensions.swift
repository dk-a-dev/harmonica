//
//  CachedStory+Extensions.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//
 import CoreData

extension CachedStory {
    
    // Convert NSManagedObject → our clean Story struct
    func toStory() -> Story {
        Story(
            id: Int(self.id),
            title: self.title ?? "",
            url: self.url,
            score: Int(self.score),
            by: self.by,
            time: self.time,
            descendants: Int(self.descendants),
            kids: self.kidIDs as? [Int],
            type: self.type,
            text: self.text
        )
    }
    
    // Populate from a Story struct
    func populate(from story: Story, feedType: String, rank: Int) {
        self.id = Int64(story.id)
        self.title = story.title
        self.url = story.url
        self.score = Int32(story.points_)
        self.by = story.author_
        self.time = story.time
        self.descendants = Int32(story.commentCount)
        self.type = story.type
        self.text = story.text
        if let kids = story.kids {
            self.kidIDs = try? JSONEncoder().encode(kids)
        }
        self.feedType = feedType
        self.rank = Int32(rank)
        self.cachedAt = Date()
    }
    
    // Is this cache still fresh? (default: 10 minutes)
    func isFresh(maxAge: TimeInterval = 600) -> Bool {
        guard let cachedAt = self.cachedAt else { return false }
        return Date().timeIntervalSince(cachedAt) < maxAge
    }
}
