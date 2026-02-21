//
//  HNService.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//


import Foundation

// HN Firebase API - for fetching story/comment details and user profiles
actor HNService {
    static let shared = HNService()
    
    private let baseURL = "https://hacker-news.firebaseio.com/v0"
    private let session = URLSession.shared
    
    // MARK: - Stories
    
    func fetchTopStoryIDs() async throws -> [Int] {
        try await fetchIDs(endpoint: "topstories")
    }
    
    func fetchNewStoryIDs() async throws -> [Int] {
        try await fetchIDs(endpoint: "newstories")
    }
    
    func fetchAskStoryIDs() async throws -> [Int] {
        try await fetchIDs(endpoint: "askstories")
    }
    
    func fetchShowStoryIDs() async throws -> [Int] {
        try await fetchIDs(endpoint: "showstories")
    }
    
    func fetchJobStoryIDs() async throws -> [Int] {
        try await fetchIDs(endpoint: "jobstories")
    }
    
    private func fetchIDs(endpoint: String) async throws -> [Int] {
        let url = URL(string: "\(baseURL)/\(endpoint).json")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode([Int].self, from: data)
    }
    
    // MARK: - Items (Stories + Comments)
    
    func fetchItem(id: Int) async throws -> Story {
        let url = URL(string: "\(baseURL)/item/\(id).json")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(Story.self, from: data)
    }
    
    func fetchComment(id: Int) async throws -> Comment {
        let url = URL(string: "\(baseURL)/item/\(id).json")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(Comment.self, from: data)
    }
    
    // Fetch multiple stories concurrently (for story list)
    func fetchStories(ids: [Int], limit: Int = 30) async throws -> [Story] {
        let limitedIDs = Array(ids.prefix(limit))
        return try await withThrowingTaskGroup(of: Story?.self) { group in
            for id in limitedIDs {
                group.addTask {
                    try? await self.fetchItem(id: id)
                }
            }
            var stories: [Story] = []
            for try await story in group {
                if let story = story { stories.append(story) }
            }
            // Re-sort to original order
            return stories.sorted { a, b in
                let aIdx = limitedIDs.firstIndex(of: a.id) ?? 0
                let bIdx = limitedIDs.firstIndex(of: b.id) ?? 0
                return aIdx < bIdx
            }
        }
    }
    
    // MARK: - Comments (recursive tree)
    
    func fetchCommentTree(storyID: Int) async throws -> [Comment] {
        let story = try await fetchItem(id: storyID)
        guard let kidIDs = story.kids else { return [] }
        return try await fetchComments(ids: kidIDs, depth: 0)
    }
    
    private func fetchComments(ids: [Int], depth: Int) async throws -> [Comment] {
        return try await withThrowingTaskGroup(of: Comment?.self) { group in
            for id in ids {
                group.addTask {
                    let comment = try? await self.fetchComment(id: id)
                    comment?.depth = depth
                    return comment
                }
            }
            var comments: [Comment] = []
            for try await comment in group {
                if let comment = comment { comments.append(comment) }
            }
            // Sort back to original order
            let sorted = comments.sorted { a, b in
                let ai = ids.firstIndex(of: a.id) ?? 0
                let bi = ids.firstIndex(of: b.id) ?? 0
                return ai < bi
            }
            // Recursively fetch children (limit depth for performance)
            if depth < 4 {
                for comment in sorted {
                    if let kidIDs = comment.kids, !kidIDs.isEmpty {
                        comment.children = try await fetchComments(ids: kidIDs, depth: depth + 1)
                    }
                }
            }
            return sorted
        }
    }
    
    // MARK: - User
    
    func fetchUser(username: String) async throws -> HNUser {
        let url = URL(string: "\(baseURL)/user/\(username).json")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(HNUser.self, from: data)
    }
}
