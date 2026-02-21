//
//  func.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//

import CoreData


extension CachedComment {
    
    func toAlgoliaComment() -> AlgoliaService.AlgoliaComment {
        AlgoliaService.AlgoliaComment(
            id: Int(self.id),
            author: self.by,
            text: self.text,
            createdAt: nil,
            children: nil,
            depth: Int(self.depth)
        )
    }
    
    func populate(from comment: AlgoliaService.AlgoliaComment, storyID: Int) {
        self.id = Int64(comment.id)
        self.storyID = Int64(storyID)
        self.by = comment.author
        self.text = comment.text
        self.depth = Int16(comment.depth)
        self.cachedAt = Date()
    }
    
    func isFresh(maxAge: TimeInterval = 300) -> Bool { // 5 min for comments
        guard let cachedAt = self.cachedAt else { return false }
        return Date().timeIntervalSince(cachedAt) < maxAge
    }
}
