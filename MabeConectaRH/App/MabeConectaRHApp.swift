import SwiftUI

@main
struct MabeConectaRHApp: App {
    @State private var appState = AppState()
    @State private var preferencesStore = UserPreferencesStore()

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
