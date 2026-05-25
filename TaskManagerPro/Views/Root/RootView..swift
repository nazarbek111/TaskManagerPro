import SwiftUI

struct RootView: View {
    @EnvironmentObject private var auth: AuthService
    @State private var selectedTab: AppTab = .tasks
    @State private var isLocked: Bool = false

    private var savedPin: String {
        UserDefaults.standard.string(forKey: "appPin") ?? ""
    }

    var body: some View {
        Group {
            if !auth.isLoggedIn {
                // Не авторизован → экран входа/регистрации
                AuthView()
            } else if isLocked {
                LockScreenView {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.88)) {
                        isLocked = false
                    }
                }
                .transition(.opacity)
            } else {
                mainTabView
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.88), value: auth.isLoggedIn)
        .animation(.spring(response: 0.4, dampingFraction: 0.88), value: isLocked)
        .onAppear {
            if auth.isLoggedIn && !savedPin.isEmpty {
                isLocked = true
            }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            TaskListView()
                .tabItem { Label("Tasks", systemImage: "checklist") }
                .tag(AppTab.tasks)

            StatisticsView()
                .tabItem { Label("Stats", systemImage: "chart.pie.fill") }
                .tag(AppTab.statistics)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(AppTab.settings)
        }
    }
}
