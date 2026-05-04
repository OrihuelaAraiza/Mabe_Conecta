import Foundation
import Observation

@Observable
final class HomeViewModel {
    let empleado: Empleado
    let accesos: [QuickAccessItem]
    let solicitudes: [Solicitud]

    init(empleado: Empleado) {
        self.empleado = empleado
        self.solicitudes = Array(MockDataService.solicitudesRecientes.prefix(3))
        self.accesos = [
            QuickAccessItem(titulo: "Chat RH", subtitulo: "Respuesta inmediata", icono: "bubble.left.and.bubble.right.fill", destination: .chat),
            QuickAccessItem(titulo: "Vacaciones", subtitulo: "Saldo y solicitudes", icono: "calendar.badge.clock", destination: .vacaciones),
            QuickAccessItem(titulo: "Solicitudes", subtitulo: "Trámites activos", icono: "doc.text.fill", destination: .solicitudes),
            QuickAccessItem(titulo: "Bienestar", subtitulo: "Check-in diario", icono: "heart.fill", destination: .bienestar)
        ]
    }
}

enum HomeQuickAccessDestination: Hashable, Identifiable {
    case chat
    case vacaciones
    case solicitudes
    case bienestar

    var id: Self { self }
}

struct QuickAccessItem: Identifiable, Hashable {
    let id = UUID()
    let titulo: String
    let subtitulo: String
    let icono: String
    let destination: HomeQuickAccessDestination
}
