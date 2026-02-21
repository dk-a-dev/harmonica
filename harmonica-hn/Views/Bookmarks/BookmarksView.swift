//
//  BookmarksView.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//
import SwiftUI

struct BookmarksView: View {
    @Environment(ThemeManager.self) var themeManager
    @State private var bookmarks: [Story] = []
    @State private var showExport = false
    @State private var exportText = ""
    
    var body: some View {
        let theme = themeManager.current
        
        ZStack {
            LiquidBackground()
            
            if bookmarks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 44))
                        .foregroundColor(theme.secondaryText)
                    Text("No bookmarks yet")
                        .font(.title3.bold())
                        .foregroundColor(theme.text)
                    Text("Tap the bookmark icon on any story")
                        .font(.caption)
                        .foregroundColor(theme.secondaryText)
                }
            } else {
                List {
                    ForEach(Array(bookmarks.enumerated()), id: \.element.id) { index, story in
                        NavigationLink(destination: StoryDetailView(story: story)) {
                            StoryRowView(story: story, rank: index + 1)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                BookmarkRepository.shared.removeBookmark(storyID: story.id)
                                loadBookmarks()
                            } label: {
                                Label("Remove", systemImage: "bookmark.slash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Bookmarks")
        .toolbar {
            if !bookmarks.isEmpty {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        exportText = BookmarkRepository.shared.exportAsText()
                        showExport = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(theme.accent)
                    }
                }
            }
        }
        .onAppear { loadBookmarks() }
        .sheet(isPresented: $showExport) {
            #if os(iOS)
            ShareSheet(items: [exportText])
            #endif
        }
    }
    
    func loadBookmarks() {
        bookmarks = BookmarkRepository.shared.allBookmarks()
    }
}

#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}
#endif
