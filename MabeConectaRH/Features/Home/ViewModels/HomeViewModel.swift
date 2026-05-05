import Foundation
import Observation

@Observable
final class HomeViewModel {
    let empleado: Empleado
    let solicitudes: [Solicitud]

    init(empleado: Empleado) {
        self.empleado = empleado
        self.solicitudes = Array(MockDataService.solicitudesRecientes.prefix(3))
    }

    func accesos(for preferences: UserPreferences) -> [QuickAccessItem] {
        let active = Set(preferences.shortcutsActivos)
        let ordered = preferences.shortcutsOrden + QuickAccessItem.defaultOrder.filter { !preferences.shortcutsOrden.contains($0) }
        return ordered
            .filter { active.contains($0) }
            .compactMap(QuickAccessItem.item(for:))
    }
}

enum HomeQuickAccessDestination: Hashable, Identifiable {
    case chat
    case benefits
    case vacaciones
    case solicitudes
    case bienestar
    case tramite(String)

    var id: Self { self }
}

struct QuickAccessItem: Identifiable, Hashable {
    let id = UUID()
    let titulo: String
    let subtitulo: String
    let icono: String
    let destination: HomeQuickAccessDestination

    static let defaultOrder = ["chat", "benefits", "vacaciones", "solicitudes", "bienestar", "constancias", "nomina", "permisos", "incapacidades", "historial"]

    static func item(for id: String) -> QuickAccessItem? {
        switch id {
        case "chat":
            QuickAccessItem(titulo: "Chat RH", subtitulo: "Respuesta inmediata", icono: "bubble.left.and.bubble.right.fill", destination: .chat)
        case "benefits":
            QuickAccessItem(titulo: "Beneficios", subtitulo: "Cupones y apoyos", icono: "ticket.fill", destination: .benefits)
        case "vacaciones":
            QuickAccessItem(titulo: "Vacaciones", subtitulo: "Saldo y solicitudes", icono: "calendar.badge.clock", destination: .vacaciones)
        case "solicitudes":
            QuickAccessItem(titulo: "Solicitudes", subtitulo: "Trámites activos", icono: "doc.text.fill", destination: .solicitudes)
        case "bienestar":
            QuickAccessItem(titulo: "Bienestar", subtitulo: "Check-in diario", icono: "heart.fill", destination: .bienestar)
        case "constancias":
            QuickAccessItem(titulo: "Constancias", subtitulo: "Laborales y fiscales", icono: "doc.badge.plus", destination: .tramite(id))
        case "nomina":
            QuickAccessItem(titulo: "Nómina", subtitulo: "Recibos y dudas", icono: "dollarsign.circle.fill", destination: .tramite(id))
        case "permisos":
            QuickAccessItem(titulo: "Permisos", subtitulo: "Solicitar ausencia", icono: "checklist.checked", destination: .tramite(id))
        case "incapacidades":
            QuickAccessItem(titulo: "Incapacidades", subtitulo: "Registro y seguimiento", icono: "cross.case.fill", destination: .tramite(id))
        case "historial":
            QuickAccessItem(titulo: "Historial", subtitulo: "Movimientos RH", icono: "chart.bar.doc.horizontal.fill", destination: .tramite(id))
        default:
            nil
        }
    }
}
