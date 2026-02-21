//
//  SettingsView.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(ThemeManager.self) var themeManager
    @Environment(AuthService.self) var authService
    @Environment(\.dismiss) var dismiss
    
    @State private var showLogin = false
    
    // UserDefaults keys
    @AppStorage("hideJobPosts") var hideJobPosts = false
    @AppStorage("hideClickedPosts") var hideClickedPosts = false
    @AppStorage("alwaysOpenComments") var alwaysOpenComments = false
    @AppStorage("animateComments") var animateComments = true
    @AppStorage("commentTextSize") var commentTextSize = 14.0
    @AppStorage("useExternalBrowser") var useExternalBrowser = false
    @AppStorage("matchWebViewDarkMode") var matchWebViewDarkMode = true
    @AppStorage("showNavigationButtons") var showNavigationButtons = false
    @AppStorage("commentSorting") var commentSorting = "Default"
    @AppStorage("monochromeThreadIndicators") var monochromeThreadIndicators = false
    @AppStorage("autoCollapseTopLevel") var autoCollapseTopLevel = false
    
    var body: some View {
        let theme = themeManager.current
        
        NavigationStack {
            ZStack {
                LiquidBackground()
                
                List {
                    // ACCOUNT
                    Section {
                        if authService.isLoggedIn {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Logged in as").foregroundColor(theme.secondaryText).font(.caption)
                                    Text(authService.username ?? "").foregroundColor(theme.text).font(.body.bold())
                                }
                                Spacer()
                                Button("Logout") {
                                    authService.logout()
                                }
                                .foregroundColor(.red)
                            }
                        } else {
                            Button("Login to Hacker News") {
                                showLogin = true
                            }
                            .foregroundColor(theme.accent)
                        }
                    } header: { Text("ACCOUNT").foregroundColor(theme.secondaryText) }
                      .listRowBackground(theme.surface.opacity(0.7))
                    
                    // THEME
                    Section {
                        ForEach(AppTheme.allThemes) { t in
                            HStack {
                                HStack(spacing: 4) {
                                    Circle().fill(t.accent).frame(width: 14, height: 14)
                                    Circle().fill(t.commentDepthColors[0]).frame(width: 8, height: 8)
                                    Circle().fill(t.commentDepthColors[1]).frame(width: 8, height: 8)
                                    if t.isLiquid {
                                        Text("✦").font(.system(size: 8)).foregroundColor(t.accent)
                                    }
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(t.name).foregroundColor(theme.text)
                                    Text(t.isLiquid ? "Liquid UI" : t.colorScheme == .dark ? "Dark" : "Light")
                                        .font(.caption).foregroundColor(theme.secondaryText)
                                }
                                Spacer()
                                if themeManager.current.id == t.id {
                                    Image(systemName: "checkmark").foregroundColor(theme.accent)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { themeManager.setTheme(t) }
                            .listRowBackground(theme.surface.opacity(0.7))
                        }
                    } header: { Text("THEME").foregroundColor(theme.secondaryText) }
                    
                    // STORIES
                    Section {
                        Toggle(isOn: $hideJobPosts) {
                            Label {
                                VStack(alignment: .leading) {
                                    Text("Hide job posts").foregroundColor(theme.text)
                                    Text("Includes \"Who is hiring\" posts")
                                        .font(.caption).foregroundColor(theme.secondaryText)
                                }
                            } icon: {
                                Image(systemName: "briefcase.slash")
                                    .foregroundColor(theme.secondaryText)
                            }
                        }
                        .tint(theme.accent)
                        
                        Toggle(isOn: $hideClickedPosts) {
                            Label {
                                VStack(alignment: .leading) {
                                    Text("Hide clicked posts").foregroundColor(theme.text)
                                    Text("Applies on refresh")
                                        .font(.caption).foregroundColor(theme.secondaryText)
                                }
                            } icon: {
                                Image(systemName: "eye.slash")
                                    .foregroundColor(theme.secondaryText)
                            }
                        }
                        .tint(theme.accent)
                        
                        Toggle(isOn: $alwaysOpenComments) {
                            Label {
                                VStack(alignment: .leading) {
                                    Text("Always open comments").foregroundColor(theme.text)
                                    Text("Tap goes directly to comments")
                                        .font(.caption).foregroundColor(theme.secondaryText)
                                }
                            } icon: {
                                Image(systemName: "chevron.right.2")
                                    .foregroundColor(theme.secondaryText)
                            }
                        }
                        .tint(theme.accent)
                        
                    } header: { Text("STORIES").foregroundColor(theme.secondaryText) }
                      .listRowBackground(theme.surface.opacity(0.7))
                    
                    // COMMENTS
                    Section {
                        Toggle(isOn: $animateComments) {
                            Label("Animate comments", systemImage: "circle.hexagonpath")
                                .foregroundColor(theme.text)
                        }
                        .tint(theme.accent)
                        
                        Toggle(isOn: $monochromeThreadIndicators) {
                            Label("Monochrome thread indicators", systemImage: "paintpalette")
                                .foregroundColor(theme.text)
                        }
                        .tint(theme.accent)
                        
                        Toggle(isOn: $autoCollapseTopLevel) {
                            Label {
                                VStack(alignment: .leading) {
                                    Text("Auto-collapse top level").foregroundColor(theme.text)
                                    Text("Comments").font(.caption).foregroundColor(theme.secondaryText)
                                }
                            } icon: {
                                Image(systemName: "minus").foregroundColor(theme.secondaryText)
                            }
                        }
                        .tint(theme.accent)
                        
                        Toggle(isOn: $showNavigationButtons) {
                            Label {
                                VStack(alignment: .leading) {
                                    Text("Show navigation buttons").foregroundColor(theme.text)
                                    Text("Navigate between top level comments")
                                        .font(.caption).foregroundColor(theme.secondaryText)
                                }
                            } icon: {
                                Image(systemName: "location.north.line")
                                    .foregroundColor(theme.secondaryText)
                            }
                        }
                        .tint(theme.accent)
                        
                        // Comment text size slider
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Comment text size: \(Int(commentTextSize))sp",
                                  systemImage: "textformat.size")
                                .foregroundColor(theme.text)
                            Slider(value: $commentTextSize, in: 11...22, step: 1)
                                .tint(theme.accent)
                        }
                        
                        // Comment sorting picker
                        Picker(selection: $commentSorting) {
                            Text("Default").tag("Default")
                            Text("Top").tag("Top")
                            Text("New").tag("New")
                        } label: {
                            Label("Comment sorting", systemImage: "arrow.up.arrow.down")
                                .foregroundColor(theme.text)
                        }
                        .tint(theme.accent)
                        
                    } header: { Text("COMMENTS").foregroundColor(theme.secondaryText) }
                      .listRowBackground(theme.surface.opacity(0.7))
                    
                    // BROWSER
                    Section {
                        Toggle(isOn: $useExternalBrowser) {
                            Label {
                                VStack(alignment: .leading) {
                                    Text("Use external browser").foregroundColor(theme.text)
                                    Text("In place of in-app WebView")
                                        .font(.caption).foregroundColor(theme.secondaryText)
                                }
                            } icon: {
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(theme.secondaryText)
                            }
                        }
                        .tint(theme.accent)
                        
                        Toggle(isOn: $matchWebViewDarkMode) {
                            Label("Match WebView to theme", systemImage: "circle.lefthalf.filled")
                                .foregroundColor(theme.text)
                        }
                        .tint(theme.accent)
                        
                    } header: { Text("BROWSER").foregroundColor(theme.secondaryText) }
                      .listRowBackground(theme.surface.opacity(0.7))
                    
                    // DATA
                    Section {
                        Button(action: {
                            Task { await StoryRepository.shared.clearCache() }
                        }) {
                            Label("Clear story cache", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                        
                        Button(action: {
                            // Clear clicked stories from UserDefaults
                            UserDefaults.standard.removeObject(forKey: "clickedStories")
                        }) {
                            Label("Clear clicked stories", systemImage: "xmark.circle")
                                .foregroundColor(theme.text)
                        }
                        
                    } header: { Text("DATA").foregroundColor(theme.secondaryText) }
                      .listRowBackground(theme.surface.opacity(0.7))
                    
                    // ABOUT
                    Section {
                        HStack {
                            Label("Version", systemImage: "info.circle")
                                .foregroundColor(theme.text)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(theme.secondaryText)
                        }
                        Link(destination: URL(string: "https://github.com/SimonHalvdansson/Harmonic-HN")!) {
                            Label("Original Harmonic (Android)", systemImage: "link")
                                .foregroundColor(theme.accent)
                        }
                    } header: { Text("ABOUT").foregroundColor(theme.secondaryText) }
                      .listRowBackground(theme.surface.opacity(0.7))
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") { dismiss() }
                        .foregroundColor(theme.accent)
                }
            }
        }
        .sheet(isPresented: $showLogin) {
            LoginView()
                .environment(themeManager)
                .environment(authService)
        }
    }
}
