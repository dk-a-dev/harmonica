//
//  SubmissionView.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//


import SwiftUI

// Matches screenshot 3: Title field (0/80), URL, Text, Formatting + Submit buttons
struct SubmissionView: View {
    @Environment(ThemeManager.self) var themeManager
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var url = ""
    @State private var text = ""
    @State private var showFormatting = false
    
    var body: some View {
        let theme = themeManager.current
        
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Title field
                            VStack(alignment: .trailing, spacing: 4) {
                                RoundedTextField(
                                    placeholder: "Title",
                                    text: $title,
                                    theme: theme
                                )
                                Text("\(title.count)/80")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(theme.secondaryText)
                            }
                            
                            RoundedTextField(placeholder: "URL", text: $url, theme: theme)
                                .autocorrectionDisabled()
                            #if os(iOS)
                                .keyboardType(.URL)
                            #endif
                                .autocorrectionDisabled()
                            
                            RoundedTextField(
                                placeholder: "Text",
                                text: $text,
                                theme: theme,
                                isMultiLine: true
                            )
                            
                            Text("Leave url blank to submit a question for discussion. If there is no url, text will appear at the top of the thread. If there is a url, text is optional.")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(theme.text)
                                .padding(.horizontal, 4)
                        }
                        .padding(16)
                    }
                    
                    // Bottom action bar - matches screenshot 3
                    Divider().background(theme.secondaryText.opacity(0.3))
                    
                    HStack(spacing: 16) {
                        Button(action: { showFormatting = true }) {
                            Text("Formatting")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(theme.text)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(theme.secondaryText.opacity(0.4), lineWidth: 1)
                                )
                        }
                        
                        Button(action: submit) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.right")
                                Text("Submit")
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(title.isEmpty ? theme.secondaryText : theme.accent)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(theme.secondaryText.opacity(0.4), lineWidth: 1)
                            )
                        }
                        .disabled(title.isEmpty)
                        
                        Spacer()
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Submission")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
    
    func submit() {
        // Opens HN submit page in browser (HN has no API for submissions)
        var components = URLComponents(string: "https://news.ycombinator.com/submit")!
        components.queryItems = [
            URLQueryItem(name: "title", value: title),
            URLQueryItem(name: "url", value: url),
            URLQueryItem(name: "text", value: text)
        ]
        if let url = components.url {
                #if os(iOS)
                UIApplication.shared.open(url)
                #else
                NSWorkspace.shared.open(url)
                #endif
        }
    }
}

struct RoundedTextField: View {
    let placeholder: String
    @Binding var text: String
    let theme: AppTheme
    var isMultiLine = false
    
    var body: some View {
        Group {
            if isMultiLine {
                TextField(placeholder, text: $text, axis: .vertical)
                    .lineLimit(4...8)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .foregroundColor(theme.text)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(theme.secondaryText.opacity(0.3), lineWidth: 1)
        )
    }
}
