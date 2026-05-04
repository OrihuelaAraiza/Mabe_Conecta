import Foundation

struct AIService {
    func responder(a texto: String) async -> ChatMessage {
        try? await Task.sleep(for: .milliseconds(850))
        let normalizado = texto.lowercased()

        if normalizado.contains("vacaciones") || normalizado.contains("vacación") {
            return ChatMessage(
                rol: .asistente,
                texto: "Tienes **12 días disponibles** de los 15 anuales. Tu próximo corte es el 15 de enero de 2025.",
                fecha: Date(),
                sugerencias: ["Solicitar vacaciones", "Ver historial", "Hablar con RH"]
            )
        }

        if normalizado.contains("constancia") || normalizado.contains("empleo") {
            return ChatMessage(
                rol: .asistente,
                texto: "Con gusto la gestiono. ¿La necesitas con o sin sueldo? Elige una opción:",
                fecha: Date(),
                sugerencias: ["Con sueldo", "Sin sueldo"]
            )
        }

        return ChatMessage(
            rol: .asistente,
            texto: "Entiendo tu consulta. Déjame conectarte con un especialista de RH para darte la mejor respuesta.",
            fecha: Date(),
            sugerencias: ["Crear solicitud", "Llamar a RH", "Ver preguntas frecuentes"]
        )
    }
}
