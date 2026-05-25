//
//  TaskManagerProApp.swift
//  TaskManagerPro
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct TaskManagerProApp: App {
    init() {
        // Configure Firebase on app launch. Requires GoogleService-Info.plist in the target.
        FirebaseApp.configure()
    }

    @AppStorage("appAppearance") private var appAppearanceRawValue = AppAppearance.system.rawValue
    @StateObject private var auth = AuthService.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TaskItem.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .preferredColorScheme(AppAppearance(rawValue: appAppearanceRawValue)?.colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
