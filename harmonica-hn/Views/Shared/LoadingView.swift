//
//  LoadingView.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//
import SwiftUI

struct LoadingView: View {
    @Environment(ThemeManager.self) var themeManager
    @State private var rotate = false
    @State private var scale = false
    
    var body: some View {
        let theme = themeManager.current
        
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(theme.accent.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .scaleEffect(scale ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: scale)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 32))
                    .foregroundColor(theme.accent)
                    .rotationEffect(.degrees(rotate ? 8 : -8))
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: rotate)
            }
            
            Text("Loading...")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(theme.secondaryText)
        }
        .onAppear {
            rotate = true
            scale = true
        }
    }
}

struct ErrorView: View {
    @Environment(ThemeManager.self) var themeManager
    let message: String
    let retry: () -> Void
    
    var body: some View {
        let theme = themeManager.current
        
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 36))
                .foregroundColor(theme.secondaryText)
            
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: retry) {
                Text("Retry")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)
                    .background(
                        Capsule().fill(theme.accent)
                    )
            }
        }
    }
}
