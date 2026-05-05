import Foundation
import Observation

struct UserPreferences: Codable, Equatable {
    var interesesSeleccionados: [String] = []
    var widgetsActivos: [String] = ["vacaciones", "solicitudes", "bienestar", "accesos"]
    var widgetsOrden: [String] = ["vacaciones", "accesos", "bienestar", "solicitudes"]
    var shortcutsActivos: [String] = ["chat", "vacaciones", "solicitudes", "bienestar"]
    var shortcutsOrden: [String] = ["chat", "vacaciones", "solicitudes", "bienestar"]
    var notificacionesActivas: Bool = true
    var onboardingCompletado: Bool = false

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        interesesSeleccionados = try container.decodeIfPresent([String].self, forKey: .interesesSeleccionados) ?? []
        widgetsActivos = try container.decodeIfPresent([String].self, forKey: .widgetsActivos) ?? ["vacaciones", "solicitudes", "bienestar", "accesos"]
        widgetsOrden = try container.decodeIfPresent([String].self, forKey: .widgetsOrden) ?? ["vacaciones", "accesos", "bienestar", "solicitudes"]
        shortcutsActivos = try container.decodeIfPresent([String].self, forKey: .shortcutsActivos) ?? Self.defaultShortcuts(for: interesesSeleccionados)
        shortcutsOrden = try container.decodeIfPresent([String].self, forKey: .shortcutsOrden) ?? Self.defaultShortcuts(for: interesesSeleccionados)
        notificacionesActivas = try container.decodeIfPresent(Bool.self, forKey: .notificacionesActivas) ?? true
        onboardingCompletado = try container.decodeIfPresent(Bool.self, forKey: .onboardingCompletado) ?? false
    }

    static func defaultShortcuts(for interests: [String]) -> [String] {
        let mapped = interests.map { interest -> String in
            switch interest {
            case "vacaciones":
                return "vacaciones"
            case "constancias", "nomina", "permisos", "incapacidades", "historial":
                return interest
            default:
                return interest
            }
        }

        var result = ["chat"]
        for item in mapped where !result.contains(item) {
            result.append(item)
        }
        for fallback in ["vacaciones", "solicitudes", "bienestar"] where !result.contains(fallback) {
            result.append(fallback)
        }
        return Array(result.prefix(6))
    }
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
        preferences.widgetsActivos.contains(widget)
    }

    func orderedWidgets() -> [String] {
        let known = ["vacaciones", "accesos", "bienestar", "solicitudes"]
        let ordered = preferences.widgetsOrden.filter { known.contains($0) }
        return ordered + known.filter { !ordered.contains($0) }
    }

    func orderedShortcuts() -> [String] {
        let known = ["chat", "vacaciones", "solicitudes", "bienestar", "constancias", "nomina", "permisos", "incapacidades", "historial"]
        let ordered = preferences.shortcutsOrden.filter { known.contains($0) }
        return ordered + known.filter { !ordered.contains($0) }
    }
}
