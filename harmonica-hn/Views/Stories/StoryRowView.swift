//
//  StoryRowView.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//

import SwiftUI

struct StoryRowView: View {
    @Environment(ThemeManager.self) var themeManager
    let story: Story
    let rank: Int
    
    @State private var pressed = false
    @State private var isVisited = false
    
    var body: some View {
        let theme = themeManager.current
        
        HStack(alignment: .top, spacing: 0) {
            // Rank column with gradient bar
            VStack(spacing: 4) {
                Text("\(rank)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(theme.accent)
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [theme.accent.opacity(0.6), theme.accent.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            .padding(.leading, 16)
            .padding(.top, 16)
            .padding(.trailing, 12)
            
            // Main content
            VStack(alignment: .leading, spacing: 8) {
                // Domain tag
                if let domain = story.domain {
                    Text(domain)
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(theme.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(theme.accent.opacity(0.12))
                                .overlay(
                                    Capsule()
                                        .strokeBorder(theme.accent.opacity(0.2), lineWidth: 0.5)
                                )
                        )
                }
                
                // Title
                Text(story.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(theme.text)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Meta row
                HStack(spacing: 10) {
                    // Points
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 9, weight: .bold))
                        Text("\(story.points_)")
                            .font(.system(size: 11, design: .monospaced))
                    }
                    .foregroundColor(theme.commentDepthColors[0].opacity(0.8))
                    
                    Text("·").foregroundColor(theme.secondaryText.opacity(0.4))
                    
                    // Time
                    HStack(spacing: 3) {
                        Image(systemName: "clock")
                            .font(.system(size: 9))
                        Text(story.timeAgo)
                            .font(.system(size: 11, design: .monospaced))
                    }
                    .foregroundColor(theme.secondaryText)
                    
                    Text("·").foregroundColor(theme.secondaryText.opacity(0.4))
                    
                    // Author
                    Text(story.author_)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(theme.secondaryText)
                }
            }
            .padding(.vertical, 16)
            .padding(.trailing, 8)
            
            Spacer()
            
            // Comment count flame
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(
                            story.commentCount > 0
                                ? theme.accent.opacity(0.12)
                                : theme.secondaryText.opacity(0.06)
                        )
                        .frame(width: 36, height: 36)
                    
                    VStack(spacing: 1) {
                        Image(systemName: story.commentCount > 0 ? "flame.fill" : "bubble.left")
                            .font(.system(size: 14))
                            .foregroundColor(
                                story.commentCount > 0 ? theme.accent : theme.secondaryText
                            )
                        
                        if story.commentCount > 0 {
                            Text("\(story.commentCount)")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(theme.secondaryText)
                        }
                    }
                }
            }
            .padding(.top, 16)
            .padding(.trailing, 12)
        }
        .background(
            ZStack {
                // Glass base
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.surface.opacity(theme.isLiquid ? 0.4 : 0.7))
                
                // Gradient shimmer on liquid themes
                if theme.isLiquid {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    theme.accent.opacity(0.04),
                                    Color.clear,
                                    theme.commentDepthColors[1].opacity(0.03)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                // Border
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                theme.accent.opacity(0.2),
                                theme.secondaryText.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            }
        )
        .scaleEffect(pressed ? 0.97 : 1.0)
        .animation(.spring(duration: 0.2), value: pressed)
        .opacity(isVisited ? 0.5 : 1.0)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .onAppear {
            let clicked = UserDefaults.standard.array(forKey: "clickedStories") as? [Int] ?? []
            isVisited = clicked.contains(story.id)
        }
    }
}
