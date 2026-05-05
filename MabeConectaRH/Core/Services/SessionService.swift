import Foundation

struct SessionData: Codable {
    let empleadoId: String
    let rol: String
    let isDemoMode: Bool
    let timestamp: Date
}

enum SessionService {
    private static let key = "mabe.session"
    private static let expirationHours: Double = 8

    static func save(empleadoId: String, rol: UserRole, isDemoMode: Bool) {
        let session = SessionData(
            empleadoId: empleadoId,
            rol: rol == .agenteRH ? "rh" : "empleado",
            isDemoMode: isDemoMode,
            timestamp: Date()
        )

        if let data = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> SessionData? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let session = try? JSONDecoder().decode(SessionData.self, from: data)
        else { return nil }

        let elapsedHours = Date().timeIntervalSince(session.timestamp) / 3600
        guard elapsedHours < expirationHours else {
            clear()
            return nil
        }

        return session
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
