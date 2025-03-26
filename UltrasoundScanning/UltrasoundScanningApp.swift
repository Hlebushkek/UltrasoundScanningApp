//
//  UltrasoundScanningApp.swift
//  UltrasoundScanning
//
//  Created by Hlib Sobolevskyi on 3/25/25.
//

import SwiftUI
import SwiftData

@main
struct UltrasoundScanningApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
