import Foundation
import Observation

@Observable
final class VacacionesViewModel {
    let empleado: Empleado
    var selectedDates: Set<DateComponents> = []
    var showingSheet = false
    var motivo = ""
    var historial: [Solicitud] = [
        Solicitud(id: "V001", tipo: "Vacaciones (23-27 dic)", fecha: Date(), estado: .aprobada),
        Solicitud(id: "V002", tipo: "Vacaciones (12-14 ago)", fecha: Date().addingTimeInterval(-7_000_000), estado: .pendiente),
        Solicitud(id: "V003", tipo: "Vacaciones (8-10 may)", fecha: Date().addingTimeInterval(-18_000_000), estado: .rechazada)
    ]

    init(empleado: Empleado) {
        self.empleado = empleado
    }

    var diasUsados: Int {
        empleado.diasVacacionesTotales - empleado.diasVacacionesDisponibles
    }

    var monthTitle: String {
        Date().formatted(.dateTime.month(.wide).year()).capitalized
    }

    func toggle(_ components: DateComponents) {
        Haptics.impact(.light)
        if selectedDates.contains(components) {
            selectedDates.remove(components)
        } else {
            selectedDates.insert(components)
        }
    }

    func enviarSolicitud() {
        historial.insert(
            Solicitud(id: UUID().uuidString, tipo: "Vacaciones solicitadas", fecha: Date(), estado: .pendiente, detalle: motivo),
            at: 0
        )
        selectedDates.removeAll()
        motivo = ""
        showingSheet = false
    }
}
