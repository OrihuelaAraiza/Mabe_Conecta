import SwiftUI

struct AppRouter: View {
    @Environment(AppState.self) private var appState
    @Environment(UserPreferencesStore.self) private var preferencesStore
    @State private var hasShownDemoToast = false

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                switch appState.flow {
                case .login:
                    LoginView()
                        .transition(.opacity)
                case .onboarding:
                    OnboardingView()
                        .transition(.opacity)
                case .main:
                    MainTabView()
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: appState.flowHash)

            if let message = appState.toastMessage {
                MabeToastView(message: message)
                    .padding(.top, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .onChange(of: appState.flowHash) {
            scheduleDemoToastIfNeeded()
        }
        .onAppear {
            appState.hasCompletedOnboarding = preferencesStore.hasCompletedOnboarding
            scheduleDemoToastIfNeeded()
        }
    }

    private func scheduleDemoToastIfNeeded() {
        guard appState.flow == .main, appState.isDemoMode, !hasShownDemoToast else { return }
        hasShownDemoToast = true
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(300))
            appState.showToast("🔧 Modo Demo activo")
        }
    }
}

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: MainTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                if let empleado = appState.currentUser {
                    HomeView(empleado: empleado) { tab in
                        selectedTab = tab
                    }
                }
            }
            .tabItem {
                Label(MainTab.home.title, systemImage: selectedTab == .home ? MainTab.home.iconFilled : MainTab.home.icon)
            }
            .tag(MainTab.home)

            NavigationStack {
                ChatView()
            }
            .tabItem {
                Label(MainTab.assistant.title, systemImage: selectedTab == .assistant ? MainTab.assistant.iconFilled : MainTab.assistant.icon)
            }
            .tag(MainTab.assistant)

            NavigationStack {
                MiRHView()
            }
            .tabItem {
                Label(MainTab.rh.title, systemImage: selectedTab == .rh ? MainTab.rh.iconFilled : MainTab.rh.icon)
            }
            .tag(MainTab.rh)
        }
        .tint(Color.mabeBlue)
    }
}

private extension AppState {
    var flowHash: String {
        switch flow {
        case .login: "login"
        case .onboarding: "onboarding"
        case .main: "main"
        }
    }
}
