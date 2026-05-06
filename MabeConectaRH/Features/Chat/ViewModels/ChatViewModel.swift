import Foundation
import Observation

@Observable
final class ChatViewModel {
    var mensajes: [ChatMessage]
    var textoActual = ""
    var isTyping = false
    var linkedPrestaciones: [UUID: Prestacion] = [:]

    private let aiService = AIService()
    private let api = BackendAPI()

    init() {
        if let saved = SessionService.loadChatMessages(), !saved.isEmpty {
            mensajes = saved
        } else {
            mensajes = MockDataService.chatInicial
        }
    }

    @MainActor
    func enviar(_ textoForzado: String? = nil) async {
        let texto = (textoForzado ?? textoActual).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !texto.isEmpty, !isTyping else { return }

        textoActual = ""
        mensajes.append(ChatMessage(rol: .usuario, texto: texto, fecha: Date()))
        persistMessages()
        isTyping = true

        if let session = SessionService.load() {
            do {
                let response = try await api.chat(
                    prompt: texto, sessionID: session.chatSessionId, authToken: session.authToken)
                SessionService.saveChatSessionId(response.session_id)

                let assistantMessage = ChatMessage(
                    rol: .asistente,
                    texto: response.response,
                    fecha: response.timestamp,
                    sugerencias: sugerenciasParaRespuesta(response.response)
                )

                mensajes.append(assistantMessage)
                persistMessages()
                if let prestacion = Self.checkForPrestacionLink(in: assistantMessage.texto) {
                    linkedPrestaciones[assistantMessage.id] = prestacion
                }
                isTyping = false
                return
            } catch {
                // If backend fails, continue with local fallback for demo resilience
            }
        }

        let respuesta = await aiService.responder(a: texto)
        mensajes.append(respuesta)
        persistMessages()
        if let prestacion = Self.checkForPrestacionLink(in: respuesta.texto) {
            linkedPrestaciones[respuesta.id] = prestacion
        }
        isTyping = false
    }

    private func sugerenciasParaRespuesta(_ response: String) -> [String] {
        let lower = response.lowercased()
        var suggestions: [String] = []

        if lower.contains("vacacion") {
            suggestions.append(contentsOf: ["Ver mi saldo de vacaciones", "Solicitar vacaciones"])
        }

        if lower.contains("cup") || lower.contains("coupon") || lower.contains("beneficio") {
            suggestions.append(contentsOf: ["Ver cupones", "Mostrar cupones canjeados"])
        }

        if lower.contains("solicitud") || lower.contains("rh") {
            suggestions.append(contentsOf: ["Crear solicitud RH", "Ver mis solicitudes"])
        }

        if lower.contains("bienestar") || lower.contains("mood") || lower.contains("estado") {
            suggestions.append(contentsOf: ["Registrar bienestar", "Ver historial de bienestar"])
        }

        if lower.contains("recompensa") || lower.contains("puntos") || lower.contains("logro") {
            suggestions.append(contentsOf: ["Ver mis beneficios", "¿Qué cupón me conviene?"])
        }

        if suggestions.isEmpty {
            suggestions = ["Ver mis beneficios", "Ver mis solicitudes", "Registrar bienestar"]
        }

        return Array(NSOrderedSet(array: suggestions)) as? [String] ?? suggestions
    }

    private func persistMessages() {
        SessionService.saveChatMessages(mensajes)
    }

    static func checkForPrestacionLink(in response: String) -> Prestacion? {
        let keywords: [(String, String)] = [
            ("aguinaldo", "aguinaldo"),
            ("prima vacacional", "prima"),
            ("fondo de ahorro", "fondo"),
            ("vales", "vales"),
            ("despensa", "vales"),
            ("bono", "bonos"),
            ("caja de ahorro", "caja"),
            ("seguro", "sgmm"),
            ("gastos médicos", "sgmm"),
            ("cumpleaños", "cumple"),
            ("maternidad", "maternidad"),
            ("maestría", "posgrado"),
            ("doctorado", "posgrado"),
            ("posgrado", "posgrado"),
            ("prepa", "prepa"),
            ("convenio", "convenios"),
            ("descuento", "convenios"),
        ]
        let lower = response.lowercased()
        for (keyword, id) in keywords where lower.contains(keyword) {
            return MockDataService.prestaciones.first { $0.id == id }
        }
        return nil
    }
}
