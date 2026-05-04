import Foundation

enum ChatRole: Hashable {
    case usuario
    case asistente
}

struct ChatMessage: Identifiable, Hashable {
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
