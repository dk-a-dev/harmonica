//
//  AppTheme.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//


import SwiftUI

// All themes for the app - matches Harmonic's theming
struct AppTheme: Identifiable, Equatable {
    let id: String
    let name: String
    let accent: Color
    let background: Color
    let surface: Color
    let text: Color
    let secondaryText: Color
    let commentDepthColors: [Color]  // Left border colors for comment nesting
    let colorScheme: ColorScheme
    let isLiquid: Bool  // Whether to show animated liquid background
    
    static let allThemes: [AppTheme] = [
        .harmonicDefault,
        .harmonicDark,
        .liquidOrange,
        .liquidPurple,
        .liquidOcean,
        .monolight,
        .monodark
    ]
    
    // Exactly like Harmonic Android app - warm beige/light
    static let harmonicDefault = AppTheme(
        id: "harmonic_default",
        name: "Harmonic",
        accent: Color(hex: "#8B4513"),
        background: Color(hex: "#FAF0E6"),
        surface: Color(hex: "#F5E6D3"),
        text: Color(hex: "#2C1810"),
        secondaryText: Color(hex: "#8B7355"),
        commentDepthColors: [
            Color(hex: "#4A90D9"),  // blue
            Color(hex: "#E91E8C"),  // pink
            Color(hex: "#4CAF50"),  // green
            Color(hex: "#FF9800"),  // orange
        ],
        colorScheme: .light,
        isLiquid: false
    )
    
    // Dark mode version
    static let harmonicDark = AppTheme(
        id: "harmonic_dark",
        name: "Harmonic Dark",
        accent: Color(hex: "#FF6B35"),
        background: Color(hex: "#1C1C1E"),
        surface: Color(hex: "#2C2C2E"),
        text: Color.white,
        secondaryText: Color(hex: "#8E8E93"),
        commentDepthColors: [
            Color(hex: "#4A90D9"),
            Color(hex: "#E91E8C"),
            Color(hex: "#4CAF50"),
            Color(hex: "#FF9800"),
        ],
        colorScheme: .dark,
        isLiquid: false
    )
    
    // Liquid themes with animated blob backgrounds
    static let liquidOrange = AppTheme(
        id: "liquid_orange",
        name: "Liquid Fire",
        accent: Color(hex: "#FF6B35"),
        background: Color(hex: "#0A0A0F"),
        surface: Color(hex: "#12121A"),
        text: Color(hex: "#E8E8F0"),
        secondaryText: Color(hex: "#6B6B80"),
        commentDepthColors: [
            Color(hex: "#FF6B35"),
            Color(hex: "#7C3AED"),
            Color(hex: "#06D6A0"),
            Color(hex: "#F59E0B"),
        ],
        colorScheme: .dark,
        isLiquid: true
    )
    
    static let liquidPurple = AppTheme(
        id: "liquid_purple",
        name: "Liquid Cosmos",
        accent: Color(hex: "#A78BFA"),
        background: Color(hex: "#07071A"),
        surface: Color(hex: "#0F0F2A"),
        text: Color(hex: "#E8E8FF"),
        secondaryText: Color(hex: "#6B6BAA"),
        commentDepthColors: [
            Color(hex: "#A78BFA"),
            Color(hex: "#F472B6"),
            Color(hex: "#34D399"),
            Color(hex: "#FCD34D"),
        ],
        colorScheme: .dark,
        isLiquid: true
    )
    
    static let liquidOcean = AppTheme(
        id: "liquid_ocean",
        name: "Liquid Ocean",
        accent: Color(hex: "#06B6D4"),
        background: Color(hex: "#020F1A"),
        surface: Color(hex: "#071828"),
        text: Color(hex: "#E0F7FF"),
        secondaryText: Color(hex: "#4A8FA0"),
        commentDepthColors: [
            Color(hex: "#06B6D4"),
            Color(hex: "#818CF8"),
            Color(hex: "#34D399"),
            Color(hex: "#FB923C"),
        ],
        colorScheme: .dark,
        isLiquid: true
    )
    
    static let monolight = AppTheme(
        id: "mono_light",
        name: "Mono Light",
        accent: Color.black,
        background: Color.white,
        surface: Color(hex: "#F5F5F5"),
        text: Color.black,
        secondaryText: Color(hex: "#666666"),
        commentDepthColors: [
            Color(hex: "#333333"),
            Color(hex: "#666666"),
            Color(hex: "#999999"),
            Color(hex: "#CCCCCC"),
        ],
        colorScheme: .light,
        isLiquid: false
    )
    
    static let monodark = AppTheme(
        id: "mono_dark",
        name: "Mono Dark",
        accent: Color.white,
        background: Color.black,
        surface: Color(hex: "#111111"),
        text: Color.white,
        secondaryText: Color(hex: "#888888"),
        commentDepthColors: [
            Color(hex: "#FFFFFF"),
            Color(hex: "#AAAAAA"),
            Color(hex: "#777777"),
            Color(hex: "#444444"),
        ],
        colorScheme: .dark,
        isLiquid: false
    )
}

// Hex color convenience
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}