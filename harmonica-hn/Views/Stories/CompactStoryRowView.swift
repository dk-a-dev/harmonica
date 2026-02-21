//
//  CompactStoryRowView.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//

import SwiftUI

struct CompactStoryRowView: View {
    @Environment(ThemeManager.self) var themeManager
    let story: Story
    let rank: Int
    
    @AppStorage("showPoints") var showPoints = true
    @AppStorage("showDomain") var showDomain = true
    
    @State private var isVisited = false
    
    var body: some View {
        let theme = themeManager.current
        
        HStack(alignment: .top, spacing: 12) {
            // Rank
            Text("\(rank).")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(theme.secondaryText)
                .frame(width: 30, alignment: .trailing)
                .padding(.top, 2)
            
            // Main Content
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(story.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(theme.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Meta info
                HStack(spacing: 6) {
                    if showPoints {
                        Text("\(story.points_) points")
                    }
                    if showDomain, let domain = story.domain {
                        if showPoints { Text("•") }
                        Text(domain)
                    }
                    if showPoints || showDomain { Text("•") }
                    Text(story.timeAgo)
                }
                .font(.system(size: 12))
                .foregroundColor(theme.secondaryText)
                .lineLimit(1)
            }
            
            Spacer(minLength: 8)
            
            // Comment Flame
            VStack(spacing: 2) {
                Image(systemName: story.commentCount > 0 ? "flame.fill" : "flame")
                    .font(.system(size: 16))
                    .foregroundColor(story.commentCount > 0 ? theme.accent : theme.secondaryText.opacity(0.5))
                
                if story.commentCount > 0 {
                    Text("\(story.commentCount)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(theme.secondaryText)
                }
            }
            .frame(width: 36)
            .padding(.top, 2)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .opacity(isVisited ? 0.6 : 1.0)
        .background(Color.clear)
        .contentShape(Rectangle()) // To make the whole row tappable consistently
        .onAppear {
            let clicked = UserDefaults.standard.array(forKey: "clickedStories") as? [Int] ?? []
            isVisited = clicked.contains(story.id)
        }
    }
}
