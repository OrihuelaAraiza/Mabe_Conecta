import Foundation
import Observation

@Observable
final class ChatViewModel {
    var mensajes = MockDataService.chatInicial
    var textoActual = ""
    var isTyping = false

    private let aiService = AIService()

    @MainActor
    func enviar(_ textoForzado: String? = nil) async {
        let texto = (textoForzado ?? textoActual).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !texto.isEmpty, !isTyping else { return }

        textoActual = ""
        mensajes.append(ChatMessage(rol: .usuario, texto: texto, fecha: Date()))
        isTyping = true
        let respuesta = await aiService.responder(a: texto)
        mensajes.append(respuesta)
        isTyping = false
    }
}
