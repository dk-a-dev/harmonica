//
//  Comment.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//


import Foundation

// Recursive comment tree model
class Comment: Identifiable, Codable {
    let id: Int
    let by: String?
    let time: TimeInterval
    let text: String?
    let parent: Int?
    var kids: [Int]?
    var children: [Comment]?
    let deleted: Bool?
    let dead: Bool?
    let type: String?
    
    var depth: Int = 0
    var isCollapsed: Bool = false
    
    var timeAgo: String {
        Date(timeIntervalSince1970: time).timeAgoDisplay()
    }
    
    var isVisible: Bool {
        return deleted != true && dead != true && text != nil
    }
    
    enum CodingKeys: String, CodingKey {
        case id, by, time, text, parent, kids, children, deleted, dead, type
    }
}
