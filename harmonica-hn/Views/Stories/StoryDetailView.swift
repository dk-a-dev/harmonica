//
//  StoryDetailView.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//

import SwiftUI

struct StoryDetailView: View {
    @Environment(ThemeManager.self) var themeManager
    @Environment(AuthService.self) var authService
    
    let story: Story
    @State private var vm = CommentsViewModel()
    @State private var showUserProfile = false
    @State private var selectedUser: String = ""
    @State private var showShareSheet = false
    @State private var isBookmarked = false
    @State private var webViewURL: URL? = nil
    @AppStorage("useExternalBrowser") var useExternalBrowser = false
    
    @State private var isVoting = false
    @State private var hasVoted = false
    @State private var voteError: String?
    @State private var showLoginAlert = false
    
    var body: some View {
        let theme = themeManager.current
        
        ZStack {
            LiquidBackground()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    storyHeader(theme: theme)
                    
                    Divider().background(theme.secondaryText.opacity(0.2))
                    
                    actionBar(theme: theme)
                    
                    Divider().background(theme.secondaryText.opacity(0.2))
                    
                    if let text = story.text, !text.isEmpty {
                        HTMLTextView(html: text)
                            .padding(16)
                    }
                    
                    if vm.isLoading {
                        commentsLoadingView(theme: theme)
                    } else {
                        commentsSection(theme: theme)
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(story.domain ?? "")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: { openURL(story.url ?? "") }) {
                    Image(systemName: "safari")
                        .foregroundColor(themeManager.current.accent)
                }
                .disabled(story.url == nil || story.url?.isEmpty == true)
            }
        }
        .task {
            await vm.load(storyID: story.id)
            isBookmarked = BookmarkRepository.shared.isBookmarked(storyID: story.id)
            
            // Mark as visited
            var clicked = UserDefaults.standard.array(forKey: "clickedStories") as? [Int] ?? []
            if !clicked.contains(story.id) {
                clicked.append(story.id)
                UserDefaults.standard.set(clicked, forKey: "clickedStories")
            }
        }
        .sheet(item: $webViewURL) { url in
            InAppWebView(url: url)
                .environment(themeManager)
        }
        .sheet(isPresented: $showUserProfile) {
            UserProfileView(username: selectedUser)
                .environment(themeManager)
        }
        .alert("Login Required", isPresented: $showLoginAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please login from Settings to vote on Hacker News")
        }
        .alert("Error Voting", isPresented: Binding(get: { voteError != nil }, set: { if !$0 { voteError = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(voteError ?? "")
        }
        .sheet(isPresented: $showShareSheet) {
#if os(iOS)
    if let urlString = story.url, let url = URL(string: urlString) {
        ShareSheet(items: [url])
    } else {
        ShareSheet(items: [story.title])
    }
    #else
    EmptyView()
    #endif
        }
    }
    
    // MARK: - Open URL
    func openURL(_ urlString: String) {
        guard !urlString.isEmpty else { return }
        print("🌐 Opening URL: \(urlString)")
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            return
        }
        if useExternalBrowser {
            #if os(iOS)
            UIApplication.shared.open(url)
            #else
            NSWorkspace.shared.open(url)
            #endif
        } else {
            webViewURL = url
        }
    }
    
    // MARK: - Story Header
    @ViewBuilder
    func storyHeader(theme: AppTheme) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let domain = story.domain {
                Text("(\(domain))")
                    .font(.system(size: 13))
                    .foregroundColor(theme.secondaryText)
            }
            
            Text(story.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(theme.text)
            
            HStack(spacing: 16) {
                Label("\(story.points_)", systemImage: "hand.thumbsup.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(theme.secondaryText)
                
                Label("\(story.commentCount)", systemImage: "bubble.left.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(theme.secondaryText)
                
                Label(story.timeAgo, systemImage: "clock")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(theme.secondaryText)
                
                Label(story.author_, systemImage: "person.circle")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(theme.secondaryText)
            }
            
            if let urlString = story.url, !urlString.isEmpty {
                Button(action: { openURL(urlString) }) {
                    HStack(spacing: 6) {
                        Image(systemName: "link")
                        Text(urlString)
                            .lineLimit(1)
                    }
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(theme.accent)
                }
            }
        }
        .padding(16)
    }
    
    // MARK: - Action Bar
    @ViewBuilder
    func actionBar(theme: AppTheme) -> some View {
        HStack(spacing: 0) {
            ActionBarButton(icon: "person.circle", theme: theme) {
                selectedUser = story.author_
                showUserProfile = true
            }
            
            ActionBarButton(icon: "bubble.left.and.bubble.right", theme: theme) {}
            
            Button(action: {
                if !authService.isLoggedIn {
                    showLoginAlert = true
                    return
                }
                guard !hasVoted, !isVoting else { return }
                
                isVoting = true
                Task {
                    do {
                        let success = try await authService.vote(itemId: story.id)
                        if success {
                            hasVoted = true
                        } else {
                            voteError = "Failed to vote. Please try again."
                        }
                    } catch {
                        voteError = error.localizedDescription
                    }
                    isVoting = false
                }
            }) {
                if isVoting {
                    ProgressView()
                        .frame(width: 44, height: 44)
                        .tint(theme.accent)
                } else {
                    Image(systemName: hasVoted ? "hand.thumbsup.fill" : "hand.thumbsup")
                        .font(.system(size: 18))
                        .foregroundColor(hasVoted ? theme.accent : theme.secondaryText)
                        .frame(width: 44, height: 44)
                }
            }

            
            ActionBarButton(icon: isBookmarked ? "bookmark.fill" : "bookmark", theme: theme) {
                BookmarkRepository.shared.toggleBookmark(story: story)
                isBookmarked = BookmarkRepository.shared.isBookmarked(storyID: story.id)
            }
            
            ActionBarButton(icon: "square.and.arrow.up", theme: theme) {
                showShareSheet = true
            }
            
            Spacer()
            
            ActionBarButton(icon: "ellipsis", theme: theme) {}
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Comments Loading
    @ViewBuilder
    func commentsLoadingView(theme: AppTheme) -> some View {
        VStack(spacing: 16) {
            ForEach(0..<5, id: \.self) { i in
                CommentSkeletonView(depth: i % 3, theme: theme)
            }
        }
        .padding(16)
    }
    
    // MARK: - Comments
    @ViewBuilder
    func commentsSection(theme: AppTheme) -> some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(vm.flatComments) { flatComment in
                CommentRowView(
                    comment: flatComment.comment,
                    depth: flatComment.depth
                )
                .onTapGesture {
                    selectedUser = flatComment.comment.author ?? ""
                    if !selectedUser.isEmpty {
                        showUserProfile = true
                    }
                }
            }
        }
    }
}

// MARK: - Action Bar Button
struct ActionBarButton: View {
    let icon: String
    let theme: AppTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(theme.secondaryText)
                .frame(width: 44, height: 44)
        }
    }
}
