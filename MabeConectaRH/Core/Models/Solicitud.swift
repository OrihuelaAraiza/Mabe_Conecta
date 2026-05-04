import Foundation
import SwiftUI

enum EstadoSolicitud: String, CaseIterable, Hashable {
    case pendiente = "Pendiente"
    case aprobada = "Aprobada"
    case rechazada = "Rechazada"
    case completada = "Completada"

    var color: Color {
        switch self {
        case .pendiente:
            .mabeWarning
        case .aprobada, .completada:
            .mabeSuccess
        case .rechazada:
            .mabeDanger
        }
    }
}

struct Solicitud: Identifiable, Hashable {
    let id: String
    let tipo: String
    let fecha: Date
    let estado: EstadoSolicitud
    let detalle: String
}

extension Solicitud {
    init(id: String, tipo: String, fecha: Date, estado: EstadoSolicitud) {
        self.init(id: id, tipo: tipo, fecha: fecha, estado: estado, detalle: "Solicitud registrada correctamente en el portal RH.")
    }
}
