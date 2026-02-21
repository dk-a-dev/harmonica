//
//  HNUser.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//


import Foundation

struct HNUser: Codable, Identifiable {
    let id: String
    let created: TimeInterval
    let karma: Int
    let about: String?
    let submitted: [Int]?
    
    var createdDate: Date {
        Date(timeIntervalSince1970: created)
    }
}