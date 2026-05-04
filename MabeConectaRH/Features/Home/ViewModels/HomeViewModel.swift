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
            QuickAccessItem(titulo: "Chat RH", icono: "bubble.left.and.bubble.right"),
            QuickAccessItem(titulo: "Mis Vacaciones", icono: "calendar"),
            QuickAccessItem(titulo: "Mis Solicitudes", icono: "doc.text"),
            QuickAccessItem(titulo: "Mi Bienestar", icono: "heart")
        ]
    }
}

struct QuickAccessItem: Identifiable, Hashable {
    let id = UUID()
    let titulo: String
    let icono: String
}
