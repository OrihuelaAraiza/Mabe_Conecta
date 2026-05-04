import Foundation
import Observation

enum SolicitudesSegment: String, CaseIterable {
    case pendientes = "Pendientes"
    case completadas = "Completadas"
}

@Observable
final class SolicitudesViewModel {
    var selectedSegment: SolicitudesSegment = .pendientes
    let solicitudes = MockDataService.solicitudesRecientes

    var filtradas: [Solicitud] {
        switch selectedSegment {
        case .pendientes:
            solicitudes.filter { $0.estado == .pendiente }
        case .completadas:
            solicitudes.filter { $0.estado != .pendiente }
        }
    }
}
