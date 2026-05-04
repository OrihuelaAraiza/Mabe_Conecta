import SwiftUI

@main
struct MabeConectaRHApp: App {
    var body: some Scene {
        WindowGroup {
            AppRouter()
                .tint(.mabeBlue)
        }
    }
}
