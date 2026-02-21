//
//  UserProfileView.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//


import SwiftUI

struct UserProfileView: View {
    @Environment(ThemeManager.self) var themeManager
    
    let username: String
    @State private var user: HNUser?
    @State private var submissions: [Story] = []
    @State private var isLoading = false
    
    var body: some View {
        let theme = themeManager.current
        
        NavigationStack {
            ZStack {
                LiquidBackground()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if isLoading {
                            ProgressView().tint(theme.accent).frame(maxWidth: .infinity)
                        } else if let user = user {
                            // User header card
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(theme.accent)
                                    
                                    VStack(alignment: .leading) {
                                        Text(user.id)
                                            .font(.title2.bold())
                                            .foregroundColor(theme.text)
                                        Text("Karma: \(user.karma)")
                                            .foregroundColor(theme.secondaryText)
                                        Text("Joined: \(user.createdDate.formatted(.dateTime.year().month()))")
                                            .foregroundColor(theme.secondaryText)
                                    }
                                }
                                
                                if let about = user.about, !about.isEmpty {
                                    HTMLTextView(html: about)
                                }
                            }
                            .padding(16)
                            .background(theme.surface.opacity(0.7))
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            
                            // Submissions
                            Text("Submissions")
                                .font(.headline)
                                .foregroundColor(theme.secondaryText)
                                .padding(.horizontal, 16)
                            
                            LazyVStack {
                                ForEach(Array(submissions.enumerated()), id: \.element.id) { index, story in
                                    NavigationLink(destination: StoryDetailView(story: story)) {
                                        StoryRowView(story: story, rank: index + 1)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 16)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(username)
            // Replace .navigationBarTitleDisplayMode(.inline) with:
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .task {
            isLoading = true
            async let userTask = try? HNService.shared.fetchUser(username: username)
            async let subTask = try? AlgoliaService.shared.fetchUserSubmissions(username: username)
            user = await userTask
            submissions = await subTask ?? []
            isLoading = false
        }
    }
}
