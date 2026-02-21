//
//  SearchView.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//


import SwiftUI

// Matches screenshot 2: search bar top, empty state "Search for stories"
struct SearchView: View {
    @Environment(ThemeManager.self) var themeManager
    @Environment(\.dismiss) var dismiss
    
    @State private var vm = SearchViewModel()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        let theme = themeManager.current
        
        NavigationStack {
            ZStack {
                LiquidBackground()
                
                VStack(spacing: 0) {
                    // Search bar - matches screenshot 2
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(theme.accent)
                        
                        TextField("Search posts", text: $vm.query)
                            .focused($isFocused)
                            .foregroundColor(theme.text)
                            .autocorrectionDisabled()
                            .onChange(of: vm.query) { vm.search() }
                        
                        if !vm.query.isEmpty {
                            Button(action: vm.clear) {
                                Image(systemName: "xmark")
                                    .foregroundColor(theme.secondaryText)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(theme.accent),
                        alignment: .bottom
                    )
                    
                    if vm.isSearching {
                        Spacer()
                        ProgressView().tint(theme.accent)
                        Spacer()
                    } else if vm.results.isEmpty && vm.query.isEmpty {
                        // Empty state - matches screenshot 2
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 44))
                                .foregroundColor(theme.secondaryText)
                            Text("Search for stories")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(theme.text)
                        }
                        Spacer()
                    } else if vm.results.isEmpty && !vm.query.isEmpty {
                        Spacer()
                        Text("No results for \"\(vm.query)\"")
                            .foregroundColor(theme.secondaryText)
                        Spacer()
                    } else {
                        List {
                            ForEach(Array(vm.results.enumerated()), id: \.element.id) { index, story in
                                NavigationLink(destination: StoryDetailView(story: story)) {
                                    StoryRowView(story: story, rank: index + 1)
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Search")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") { dismiss() }
                        .foregroundColor(theme.accent)
                }
            }
        }
        .onAppear { isFocused = true }
        .background(theme.background)
    }
}
