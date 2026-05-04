import Foundation
import Observation

struct UserPreferences: Codable, Equatable {
    var interesesSeleccionados: [String] = []
    var widgetsActivos: [String] = ["vacaciones", "solicitudes", "bienestar", "accesos"]
    var notificacionesActivas: Bool = true
    var onboardingCompletado: Bool = false
}

@Observable
final class UserPreferencesStore {
    private let key = "mabe.userPreferences"
    var preferences: UserPreferences

    init() {
        if
            let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode(UserPreferences.self, from: data)
        {
            preferences = decoded
        } else {
            preferences = UserPreferences()
        }
    }

    var hasCompletedOnboarding: Bool {
        preferences.onboardingCompletado
    }

    func save(_ preferences: UserPreferences) {
        self.preferences = preferences
        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func reset() {
        UserDefaults.standard.removeObject(forKey: key)
        preferences = UserPreferences()
    }

    func isWidgetActive(_ widget: String) -> Bool {
        preferences.widgetsActivos.isEmpty || preferences.widgetsActivos.contains(widget)
    }
}
