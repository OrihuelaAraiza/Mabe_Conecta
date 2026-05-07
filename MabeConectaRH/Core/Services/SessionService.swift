import Foundation

struct SessionData: Codable {
    let empleadoId: String
    let rol: String
    let isDemoMode: Bool
    let authToken: String?
    let backendPoints: Int?
    let chatSessionId: String?
    let user: Empleado?
    let timestamp: Date
}

enum SessionService {
    private static let key = "mabe.session"
    private static let expirationHours: Double = 8
    private static let chatMessagesPrefix = "mabe.chat.messages."

    static func save(
        empleadoId: String, rol: UserRole, isDemoMode: Bool, authToken: String? = nil,
        backendPoints: Int? = nil, chatSessionId: String? = nil, user: Empleado? = nil
    ) {
        let session = SessionData(
            empleadoId: empleadoId,
            rol: rol == .agenteRH ? "rh" : "empleado",
            isDemoMode: isDemoMode,
            authToken: authToken,
            backendPoints: backendPoints,
            chatSessionId: chatSessionId,
            user: user,
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

    static func saveChatSessionId(_ sessionId: String) {
        guard var session = load() else { return }

        session = SessionData(
            empleadoId: session.empleadoId,
            rol: session.rol,
            isDemoMode: session.isDemoMode,
            authToken: session.authToken,
            backendPoints: session.backendPoints,
            chatSessionId: sessionId,
            user: session.user,
            timestamp: Date()
        )

        if let data = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func loadChatMessages() -> [ChatMessage]? {
        guard let session = load() else { return nil }
        let chatKey = chatMessagesPrefix + session.empleadoId

        guard let data = UserDefaults.standard.data(forKey: chatKey),
            let decoded = try? JSONDecoder().decode([ChatMessage].self, from: data)
        else { return nil }

        return decoded
    }

    static func saveChatMessages(_ messages: [ChatMessage]) {
        guard let session = load() else { return }
        let chatKey = chatMessagesPrefix + session.empleadoId

        if let data = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(data, forKey: chatKey)
        }
    }

    static func saveBackendPoints(_ points: Int) {
        guard var session = load() else { return }

        session = SessionData(
            empleadoId: session.empleadoId,
            rol: session.rol,
            isDemoMode: session.isDemoMode,
            authToken: session.authToken,
            backendPoints: points,
            chatSessionId: session.chatSessionId,
            user: session.user,
            timestamp: Date()
        )

        if let data = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
