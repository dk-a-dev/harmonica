//
//  StoriesView.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//

import SwiftUI

struct StoriesView: View {
    @Environment(ThemeManager.self) var themeManager
    
    let feedType: ContentView.Tab
    @State private var vm: StoriesViewModel
    @State private var showSearch = false
    @State private var showSettings = false
    
    init(feedType: ContentView.Tab) {
        self.feedType = feedType
        _vm = State(initialValue: StoriesViewModel(feedType: feedType))
    }
    
    var body: some View {
        ZStack {
            LiquidBackground()
            
            StoryListContent(vm: vm)
            
            if vm.isLoading && vm.stories.isEmpty {
                LoadingView()
            }
            
            if let error = vm.errorMessage, vm.stories.isEmpty {
                ErrorView(message: error) {
                    Task { await vm.loadInitial() }
                }
            }
        }
        .task { await vm.loadInitial() }
        .sheet(isPresented: $showSearch) { SearchView() }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .navigationTitle(feedType.rawValue + " Stories")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: { showSearch = true }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(themeManager.current.accent)
                }
            }
            ToolbarItem(placement: .automatic) {
                // Time filter menu
                Menu {
                    ForEach(TimeFilter.allCases, id: \.self) { filter in
                        Button(action: { vm.timeFilter = filter }) {
                            HStack {
                                Text(filter.rawValue)
                                if vm.timeFilter == filter {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(themeManager.current.accent)
                }
            }
            ToolbarItem(placement: .automatic) {
                Button(action: { showSettings = true }) {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(themeManager.current.accent)
                }
            }
        }
    }
}

// MARK: - Extracted List (fixes compiler type-check timeout)
struct StoryListContent: View {
    @Environment(ThemeManager.self) var themeManager
    @Environment(AuthService.self) var authService
    @AppStorage("compactLayout") var compactLayout = false
    let vm: StoriesViewModel
    
    var body: some View {
        List {
            ForEach(Array(vm.filteredStories.enumerated()), id: \.element.id) { index, story in
                ZStack {
                    if compactLayout {
                        CompactStoryRowView(story: story, rank: index + 1)
                    } else {
                        StoryRowView(story: story, rank: index + 1)
                    }
                    NavigationLink(destination: StoryDetailView(story: story)) {
                        EmptyView()
                    }
                    .opacity(0)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .swipeActions(edge: .leading) {
                    Button {
                        HapticManager.generateFeedback(style: .medium)
                        Task { try? await authService.vote(itemId: story.id) }
                    } label: {
                        Label("Upvote", systemImage: "arrow.up")
                    }
                    .tint(themeManager.current.accent)
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        HapticManager.generateFeedback(style: .heavy)
                        BookmarkRepository.shared.toggleBookmark(story: story)
                    } label: {
                        Label("Bookmark", systemImage: BookmarkRepository.shared.isBookmarked(storyID: story.id) ? "star.slash.fill" : "star.fill")
                    }
                    .tint(themeManager.current.secondaryText)
                }
                .onAppear {
                    if index == vm.stories.count - 5 {
                        Task { await vm.loadMore() }
                    }
                }
            }
            
            if vm.isLoading && !vm.stories.isEmpty {
                HStack {
                    Spacer()
                    ProgressView().tint(themeManager.current.accent)
                    Spacer()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable { await vm.refresh() }
    }
}
