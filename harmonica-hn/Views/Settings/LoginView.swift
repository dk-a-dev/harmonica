//
//  LoginView.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//

import SwiftUI

struct LoginView: View {
    @Environment(ThemeManager.self) var themeManager
    @Environment(\.dismiss) var dismiss
    
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        let theme = themeManager.current
        
        NavigationStack {
            ZStack {
                LiquidBackground()
                
                VStack(spacing: 24) {
                    // Logo / Header
                    VStack(spacing: 12) {
                        if theme.isLiquid {
                            Image(systemName: "sparkles")
                                .font(.system(size: 44))
                                .foregroundColor(theme.accent)
                        } else {
                            Image(systemName: "y.square.fill")
                                .font(.system(size: 54))
                                .foregroundColor(theme.accent)
                        }
                        
                        Text("Hacker News")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(theme.text)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    VStack(spacing: 16) {
                        TextField("Username", text: $username)
                            .padding(14)
                            .background(theme.surface.opacity(0.8))
                            .cornerRadius(12)
                            .foregroundColor(theme.text)
                            .disableAutocorrection(true)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(theme.secondaryText.opacity(0.2), lineWidth: 1)
                            )
                        
                        SecureField("Password", text: $password)
                            .padding(14)
                            .background(theme.surface.opacity(0.8))
                            .cornerRadius(12)
                            .foregroundColor(theme.text)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(theme.secondaryText.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 24)
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    Button(action: login) {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Login")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(theme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(username.isEmpty || password.isEmpty || isLoading)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    Spacer()
                }
            }
            .navigationTitle("Login")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(theme.accent)
                }
            }
        }
    }
    
    private func login() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let success = try await AuthService.shared.login(username: username, password: password)
                if success {
                    dismiss()
                } else {
                    errorMessage = "Invalid username or password"
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
