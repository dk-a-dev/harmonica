//
//  ContentView.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//
import SwiftUI

struct ContentView: View {
    @Environment(ThemeManager.self) var themeManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedTab: Tab = .top
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    enum Tab: String, CaseIterable {
        case top = "Top"
        case new = "New"
        case ask = "Ask"
        case show = "Show"
        case jobs = "Jobs"
        case bookmarked = "Bookmarked"
        
        var icon: String {
            switch self {
            case .top: return "flame"
            case .new: return "sparkles"
            case .ask: return "questionmark.bubble"
            case .show: return "eye"
            case .jobs: return "briefcase"
            case .bookmarked: return "star.fill"
            }
        }
    }
    
    var body: some View {
        if horizontalSizeClass == .regular {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                List(Tab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        Label(tab.rawValue, systemImage: tab.icon)
                            .foregroundStyle(selectedTab == tab ? themeManager.current.accent : .primary)
                    }
                }
                .navigationTitle("Harmonic HN")
            } detail: {
                NavigationStack {
                    StoriesView(feedType: selectedTab ?? .top)
                }
            }
            .tint(themeManager.current.accent)
        } else {
            TabView(selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    NavigationStack {
                        StoriesView(feedType: tab)
                    }
                    .tabItem {
                        Label(tab.rawValue, systemImage: tab.icon)
                    }
                    .tag(tab)
                }
            }
            .tint(themeManager.current.accent)
        }
    }
}
