import Foundation
import Observation

@Observable
final class ChatViewModel {
    var mensajes = MockDataService.chatInicial
    var textoActual = ""
    var isTyping = false
    var linkedPrestaciones: [UUID: Prestacion] = [:]

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
        if let prestacion = Self.checkForPrestacionLink(in: "\(texto) \(respuesta.texto)") {
            linkedPrestaciones[respuesta.id] = prestacion
        }
        isTyping = false
    }

    static func checkForPrestacionLink(in response: String) -> Prestacion? {
        let keywords: [(String, String)] = [
            ("aguinaldo", "aguinaldo"),
            ("vacacion", "prima"),
            ("vacación", "prima"),
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
            ("descuento", "convenios")
        ]
        let lower = response.lowercased()
        for (keyword, id) in keywords where lower.contains(keyword) {
            return MockDataService.prestaciones.first { $0.id == id }
        }
        return nil
    }
}
