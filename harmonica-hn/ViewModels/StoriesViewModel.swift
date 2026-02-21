//
//  StoriesViewModel.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//

import SwiftUI
import Observation


enum TimeFilter: String, CaseIterable {
    case day = "24h"
    case week48 = "48h"
    case week = "Week"
    case month = "Month"
    case all = "All"
    
    var seconds: Double? {
        switch self {
        case .day:    return 86400
        case .week48: return 172800
        case .week:   return 604800
        case .month:  return 2592000
        case .all:    return nil
        }
    }
}

@Observable
class StoriesViewModel {
    var stories: [Story] = []
    var isLoading = false
    var isRefreshing = false
    var errorMessage: String?
    var isFromCache = false
    var hasMore = true
    var currentPage = 0
    
    let feedType: ContentView.Tab
    
    init(feedType: ContentView.Tab) {
        self.feedType = feedType
    }
    
    @MainActor
    func loadInitial() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        currentPage = 0
        hasMore = true
        
        do {
            stories = try await StoryRepository.shared.fetchStories(
                feedType: feedType.rawValue.lowercased()
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    @MainActor
    func refresh() async {
        isRefreshing = true
        currentPage = 0
        hasMore = true
        do {
            stories = try await StoryRepository.shared.fetchStories(
                feedType: feedType.rawValue.lowercased(),
                forceRefresh: true
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isRefreshing = false
    }
    
    @MainActor
    func loadMore() async {
        guard !isLoading && hasMore else { return }
        isLoading = true
        
        do {
            if feedType == .top {
                let more = try await AlgoliaService.shared.fetchTopStories(
                    hitsPerPage: 30,
                    page: currentPage + 1
                )
                stories.append(contentsOf: more)
                hasMore = !more.isEmpty
            } else {
                let allIDs = try await fetchIDs(for: feedType)
                   let start = stories.count
                   guard start < allIDs.count else {
                       hasMore = false
                       isLoading = false
                       return
                   }
                   let end = min(start + 30, allIDs.count)
                   let pageIDs = Array(allIDs[start..<end])
                   let more = try await HNService.shared.fetchStories(ids: pageIDs, limit: 30)
                   stories.append(contentsOf: more)
                   hasMore = end < allIDs.count
            }
            currentPage += 1
        } catch {
            // Silent fail on pagination
        }
        isLoading = false
    }
    
    
    // Add these two properties to StoriesViewModel:
    var timeFilter: TimeFilter = .all

    var filteredStories: [Story] {
        guard let seconds = timeFilter.seconds else { return stories }
        let cutoff = Date().timeIntervalSince1970 - seconds
        return stories.filter { $0.time >= cutoff }
    }

    
    // MARK: - Private
    
    private func fetchIDs(for tab: ContentView.Tab) async throws -> [Int] {
        switch tab {
        case .top:  return try await HNService.shared.fetchTopStoryIDs()
        case .new:  return try await HNService.shared.fetchNewStoryIDs()
        case .ask:  return try await HNService.shared.fetchAskStoryIDs()
        case .show: return try await HNService.shared.fetchShowStoryIDs()
        case .jobs: return try await HNService.shared.fetchJobStoryIDs()
        case .bookmarked: return []
        }
    }
    
   
}
