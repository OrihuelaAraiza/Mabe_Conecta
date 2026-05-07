import Foundation

enum ChatRole: String, Hashable, Codable {
    case usuario
    case asistente
}

struct ChatMessage: Identifiable, Hashable, Codable {
    let id: UUID
    let rol: ChatRole
    let texto: String
    let fecha: Date
    let sugerencias: [String]

    init(id: UUID = UUID(), rol: ChatRole, texto: String, fecha: Date, sugerencias: [String] = []) {
        self.id = id
        self.rol = rol
        self.texto = texto
        self.fecha = fecha
        self.sugerencias = sugerencias
    }
}

struct ChatSession: Identifiable, Hashable {
    let id = UUID()
    var mensajes: [ChatMessage]
}

enum ChatUrgencia: String, Hashable {
    case alta = "Alta"
    case normal = "Normal"
}

struct ChatEscalado: Identifiable, Hashable {
    let id = UUID()
    let empleadoNombre: String
    let empleadoId: String
    let ultimoMensaje: String
    let fecha: Date
    let urgencia: ChatUrgencia
    var resuelto: Bool = false

    var iniciales: String {
        empleadoNombre.split(separator: " ").prefix(2)
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
            .uppercased()
    }

    var tiempoRelativo: String {
        fecha.formatted(.relative(presentation: .named))
    }
}
