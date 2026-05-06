import SwiftUI

@main
struct MabeConectaRHApp: App {
    @State private var appState = AppState()
    @State private var preferencesStore = UserPreferencesStore()

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
                .onAppear {
                    appState.hasCompletedOnboarding = preferencesStore.hasCompletedOnboarding
                }
        }
    }
}
