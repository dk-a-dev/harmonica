//
//  AlgoliaService.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//

import Foundation

actor AlgoliaService {
    static let shared = AlgoliaService()
    
    private let baseURL = "https://hn.algolia.com/api/v1"
    private let session = URLSession.shared
    
    // MARK: - Search response model (matches Algolia's actual JSON)
    struct AlgoliaResponse: Codable {
        let hits: [AlgoliaHit]
        let nbHits: Int?
        let page: Int?
        let nbPages: Int?
    }
    
    struct AlgoliaHit: Codable {
        let objectID: String
        let title: String?
        let url: String?
        let author: String?
        let points: Int?
        let storyText: String?
        let numComments: Int?
        let createdAtI: Int?
        
        enum CodingKeys: String, CodingKey {
            case objectID
            case title
            case url
            case author
            case points
            case storyText = "story_text"
            case numComments = "num_comments"
            case createdAtI = "created_at_i"
        }
        
        func toStory() -> Story {
            Story(
                id: Int(objectID) ?? 0,
                title: title ?? "",
                url: url,
                score: points,
                by: author,
                time: TimeInterval(createdAtI ?? 0),
                descendants: numComments,
                kids: nil,
                type: "story",
                text: storyText
            )
        }
    }
    
    // MARK: - Algolia Item (for comments)
    struct AlgoliaItem: Codable {
        let id: Int
        let title: String?
        let url: String?
        let points: Int?
        let author: String?
        let createdAt: String?
        let numComments: Int?
        var children: [AlgoliaComment]?
        
        enum CodingKeys: String, CodingKey {
            case id, title, url, points, author, children
            case createdAt = "created_at"
            case numComments = "num_comments"
        }
    }
    
    struct AlgoliaComment: Codable, Identifiable {
        let id: Int
        let author: String?
        let text: String?
        let createdAt: String?
        var children: [AlgoliaComment]?
        var depth: Int = 0
        
        enum CodingKeys: String, CodingKey {
            case id, author, text, children
            case createdAt = "created_at"
        }
    }
    
    // MARK: - Front page (Best stories via Algolia)
    func fetchTopStories(hitsPerPage: Int = 30, page: Int = 0) async throws -> [Story] {
        var components = URLComponents(string: "\(baseURL)/search")!
        components.queryItems = [
            URLQueryItem(name: "tags", value: "front_page"),
            URLQueryItem(name: "hitsPerPage", value: "\(hitsPerPage)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        let (data, _) = try await session.data(from: components.url!)
        let response = try JSONDecoder().decode(AlgoliaResponse.self, from: data)
        return response.hits.map { $0.toStory() }
    }
    
    // MARK: - Search
    func search(query: String, page: Int = 0) async throws -> [Story] {
        var components = URLComponents(string: "\(baseURL)/search_by_date")!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "tags", value: "story"),
            URLQueryItem(name: "hitsPerPage", value: "50"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "typoTolerance", value: "min")
        ]
        let (data, _) = try await session.data(from: components.url!)
        let response = try JSONDecoder().decode(AlgoliaResponse.self, from: data)
        return response.hits.map { $0.toStory() }
    }
    
    // MARK: - Item with comments
    func fetchItemWithComments(id: Int) async throws -> AlgoliaItem {
        let url = URL(string: "\(baseURL)/items/\(id)")!
        let (data, _) = try await session.data(from: url)
        var item = try JSONDecoder().decode(AlgoliaItem.self, from: data)
        if var children = item.children {
            setDepths(&children, depth: 0)
            item.children = children
        }
        return item
    }
    
    private func setDepths(_ comments: inout [AlgoliaComment], depth: Int) {
        for i in comments.indices {
            comments[i].depth = depth
            if var children = comments[i].children {
                setDepths(&children, depth: depth + 1)
                comments[i].children = children
            }
        }
    }
    
    // MARK: - User submissions
    func fetchUserSubmissions(username: String) async throws -> [Story] {
        var components = URLComponents(string: "\(baseURL)/search_by_date")!
        components.queryItems = [
            URLQueryItem(name: "tags", value: "author_\(username)"),
            URLQueryItem(name: "hitsPerPage", value: "100")
        ]
        let (data, _) = try await session.data(from: components.url!)
        let response = try JSONDecoder().decode(AlgoliaResponse.self, from: data)
        return response.hits.map { $0.toStory() }
    }
}
