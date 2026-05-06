import SwiftUI

@main
struct MabeConectaRHApp: App {
    @State private var appState = AppState()
    @State private var preferencesStore = UserPreferencesStore()
    @State private var rewardService = RewardService()

    init() {
        MabeFontLoader.registerFonts()
        MabeHaptics.shared.prepareEngine()
    }

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .tint(.mabeBlue)
                .environment(appState)
                .environment(preferencesStore)
                .environment(rewardService)
                .onAppear {
                    appState.hasCompletedOnboarding = preferencesStore.hasCompletedOnboarding
                }
        }
    }
}
