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
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
