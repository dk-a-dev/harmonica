//
//  Story.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//


import Foundation

struct Story: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let url: String?
    let score: Int?
    let by: String?
    let time: TimeInterval
    let descendants: Int?
    let kids: [Int]?
    let type: String?
    let text: String?
    
    // Algolia fields
    var objectID: String?
    var numComments: Int?
    var points: Int?
    var author: String?
    var createdAtI: Int?
    
    // Computed
    var domain: String? {
        guard let urlString = url,
              let host = URL(string: urlString)?.host else { return nil }
        return host.replacingOccurrences(of: "www.", with: "")
    }
    
    var timeAgo: String {
        let date = Date(timeIntervalSince1970: time)
        return date.timeAgoDisplay()
    }
    
    var commentCount: Int {
        return descendants ?? numComments ?? 0
    }
    
    var points_: Int {
        return score ?? points ?? 0
    }
    
    var author_: String {
        return by ?? author ?? "unknown"
    }
    
    // CodingKeys to handle both HN Firebase API and Algolia API
    enum CodingKeys: String, CodingKey {
        case id, title, url, score, by, time, descendants, kids, type, text
        case objectID
        case numComments = "num_comments"
        case points
        case author
        case createdAtI = "created_at_i"
    }
}