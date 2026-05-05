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
    @State private var selectedIndex = 0

    private var selectedTab: MainTab {
        MainTab.allCases[selectedIndex]
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Group {
                    switch selectedTab {
                    case .home:
                        if let empleado = appState.currentUser {
                            HomeView(empleado: empleado) { tab in
                                selectedIndex = MainTab.allCases.firstIndex(of: tab) ?? 0
                            }
                        }
                    case .assistant:
                        ChatView()
                    case .benefits:
                        BenefitsView()
                    case .rh:
                        MiRHView()
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 88)
                }
                .animation(.easeInOut(duration: 0.22), value: selectedIndex)

                VStack(spacing: 0) {
                    Spacer()
                    AppTabBar(selectedIndex: $selectedIndex)
                        .padding(.bottom, 16)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
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
