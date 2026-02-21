//
//  ThemeManager.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//


import SwiftUI
import Observation

@Observable
class ThemeManager {
    var current: AppTheme = .harmonicDefault
    
    init() {
        // Load saved theme from UserDefaults
        if let savedID = UserDefaults.standard.string(forKey: "selectedTheme"),
           let saved = AppTheme.allThemes.first(where: { $0.id == savedID }) {
            current = saved
        }
    }
    
    func setTheme(_ theme: AppTheme) {
        withAnimation(.spring(duration: 0.4)) {
            current = theme
        }
        UserDefaults.standard.set(theme.id, forKey: "selectedTheme")
    }
}