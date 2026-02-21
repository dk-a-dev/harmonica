//
//  LiquidBackground.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//


import SwiftUI

// Animated liquid blob background - used for liquid themes
struct LiquidBackground: View {
    @Environment(ThemeManager.self) var themeManager
    
    @State private var animate = false
    
    var body: some View {
        let theme = themeManager.current
        
        GeometryReader { geo in
            ZStack {
                theme.background.ignoresSafeArea()
                
                if theme.isLiquid {
                    // Blob 1
                    Circle()
                        .fill(theme.accent.opacity(0.15))
                        .frame(width: geo.size.width * 0.8)
                        .blur(radius: 80)
                        .offset(
                            x: animate ? -geo.size.width * 0.2 : -geo.size.width * 0.1,
                            y: animate ? -geo.size.height * 0.1 : -geo.size.height * 0.2
                        )
                        .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: animate)
                    
                    // Blob 2
                    Circle()
                        .fill(theme.commentDepthColors[1].opacity(0.12))
                        .frame(width: geo.size.width * 0.7)
                        .blur(radius: 70)
                        .offset(
                            x: animate ? geo.size.width * 0.3 : geo.size.width * 0.1,
                            y: animate ? geo.size.height * 0.3 : geo.size.height * 0.1
                        )
                        .animation(.easeInOut(duration: 9).repeatForever(autoreverses: true).delay(2), value: animate)
                    
                    // Blob 3
                    Circle()
                        .fill(theme.commentDepthColors[2].opacity(0.1))
                        .frame(width: geo.size.width * 0.5)
                        .blur(radius: 60)
                        .offset(
                            x: animate ? 0 : geo.size.width * 0.2,
                            y: animate ? geo.size.height * 0.5 : geo.size.height * 0.3
                        )
                        .animation(.easeInOut(duration: 11).repeatForever(autoreverses: true).delay(4), value: animate)
                }
            }
        }
        .onAppear { animate = true }
    }
}