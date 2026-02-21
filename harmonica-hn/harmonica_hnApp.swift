//
//  harmonica_hnApp.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//
import SwiftUI
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        Task {
            await PushRegistrationService.shared.registerDevice(token: token)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
}

@main
struct harmonica_hnApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @State private var themeManager = ThemeManager()
    @State private var authService = AuthService.shared
    @Environment(\.scenePhase) private var scenePhase
    
    let persistence = PersistenceController.shared
    
    init() {
        PushRegistrationService.shared.requestPermissions()
        BackgroundPushService.shared.registerBackgroundTasks()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(themeManager)
                .environment(authService)
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .preferredColorScheme(themeManager.current.colorScheme)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                BackgroundPushService.shared.scheduleAppRefresh()
            }
        }
    }
}
