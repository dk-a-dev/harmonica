//
//  harmonica_hnApp.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//
import SwiftUI
import CoreData

@main
struct harmonica_hnApp: App {
    @State private var themeManager = ThemeManager()
    @State private var authService = AuthService.shared
    let persistence = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(themeManager)
                .environment(authService)
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .preferredColorScheme(themeManager.current.colorScheme)
        }
    }
}
