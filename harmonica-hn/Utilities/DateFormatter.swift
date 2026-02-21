//
//  DateFormatter.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//

import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        let seconds = Int(Date().timeIntervalSince(self))
        
        switch seconds {
        case 0..<60:       return "\(seconds)s"
        case 60..<3600:    return "\(seconds / 60)m"
        case 3600..<86400: return "\(seconds / 3600)h"
        default:           return "\(seconds / 86400)d"
        }
    }
}
