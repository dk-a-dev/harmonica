//
//  CommentRowView.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//


import SwiftUI

struct CommentRowView: View {
    @Environment(ThemeManager.self) var themeManager
    let comment: AlgoliaService.AlgoliaComment
    let depth: Int
    @State private var isCollapsed = false
    
    var body: some View {
        let theme = themeManager.current
        let depthColor = theme.commentDepthColors[min(depth, theme.commentDepthColors.count - 1)]
        
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                // Depth indent lines
                HStack(spacing: 6) {
                    ForEach(0..<depth, id: \.self) { i in
                        let lineColor = theme.commentDepthColors[min(i, theme.commentDepthColors.count - 1)]
                        Rectangle()
                            .fill(lineColor.opacity(0.25))
                            .frame(width: 1.5)
                            .cornerRadius(1)
                    }
                }
                .padding(.leading, 12)
                .padding(.trailing, depth > 0 ? 8 : 0)
                
                // Comment card
                VStack(alignment: .leading, spacing: 0) {
                    // Header bar
                    HStack(spacing: 8) {
                        // Accent dot
                        Circle()
                            .fill(depthColor)
                            .frame(width: 6, height: 6)
                        
                        Text(comment.author ?? "[deleted]")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(depthColor)
                        
                        Text(comment.timeAgo)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(theme.secondaryText.opacity(0.6))
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring(duration: 0.3)) {
                                isCollapsed.toggle()
                            }
                        }) {
                            Image(systemName: isCollapsed ? "plus.circle" : "minus.circle")
                                .font(.system(size: 13))
                                .foregroundColor(theme.secondaryText.opacity(0.5))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 10)
                    .padding(.bottom, 6)
                    
                    if !isCollapsed {
                        if let text = comment.text {
                            HTMLTextView(html: text)
                                .foregroundColor(theme.text.opacity(0.9))
                                .padding(.horizontal, 12)
                                .padding(.bottom, 12)
                        }
                    } else {
                        Text("Tap to expand")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(theme.secondaryText.opacity(0.4))
                            .padding(.horizontal, 12)
                            .padding(.bottom, 8)
                    }
                }
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.surface.opacity(theme.isLiquid ? 0.35 : 0.6))
                        
                        if theme.isLiquid {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            depthColor.opacity(0.05),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        // Left accent border built into card
                        HStack {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [depthColor, depthColor.opacity(0)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 2.5)
                                .cornerRadius(2)
                            Spacer()
                        }
                        
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(depthColor.opacity(0.15), lineWidth: 0.5)
                    }
                )
                .padding(.trailing, 12)
            }
            .padding(.vertical, 4)
        }
        .padding(.leading, CGFloat(depth) * 4)
    }
}

struct CommentSkeletonView: View {
    let depth: Int
    let theme: AppTheme
    @State private var shimmer = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .fill(theme.surface)
                .frame(width: 100, height: 10)
            RoundedRectangle(cornerRadius: 4)
                .fill(theme.surface)
                .frame(height: 10)
            RoundedRectangle(cornerRadius: 4)
                .fill(theme.surface)
                .frame(width: 200, height: 10)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.surface.opacity(0.4))
        )
        .opacity(shimmer ? 0.4 : 0.8)
        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: shimmer)
        .padding(.horizontal, 12)
        .padding(.leading, CGFloat(depth) * 16)
        .onAppear { shimmer = true }
    }
}
// Time ago for Algolia comments
extension AlgoliaService.AlgoliaComment {
    var timeAgo: String {
        guard let dateStr = createdAt else { return "" }
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateStr) else { return "" }
        return date.timeAgoDisplay()
    }
}
