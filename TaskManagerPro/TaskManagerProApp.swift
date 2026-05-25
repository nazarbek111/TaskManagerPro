//
//  TaskManagerProApp.swift
//  TaskManagerPro
//

import SwiftUI
import SwiftData

@main
struct TaskManagerProApp: App {
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
