import Foundation
import Observation

@Observable
@MainActor
final class VacacionesViewModel {
    var empleado: Empleado
    var selectedDates: Set<DateComponents> = []
    var showingSheet = false
    var motivo = ""
    var historial: [Solicitud] = [
        Solicitud(id: "V001", tipo: "Vacaciones (23-27 dic)", fecha: Date(), estado: .aprobada),
        Solicitud(
            id: "V002", tipo: "Vacaciones (12-14 ago)",
            fecha: Date().addingTimeInterval(-7_000_000), estado: .pendiente),
        Solicitud(
            id: "V003", tipo: "Vacaciones (8-10 may)",
            fecha: Date().addingTimeInterval(-18_000_000), estado: .rechazada),
    ]
    var isLoading = false

    private let api = BackendAPI()

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

    func loadFromBackendIfPossible() async {
        guard let session = SessionService.load(), let authToken = session.authToken else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            async let balanceTask = api.vacationBalance(authToken: authToken)
            async let requestsTask = api.listVacationRequests(authToken: authToken)

            let balance = try await balanceTask
            let requests = try await requestsTask

            empleado = Empleado(
                id: empleado.id,
                nombre: empleado.nombre,
                apellidos: empleado.apellidos,
                puesto: empleado.puesto,
                departamento: empleado.departamento,
                planta: empleado.planta,
                diasVacacionesDisponibles: balance.dias_vacaciones_disponibles,
                diasVacacionesTotales: balance.dias_vacaciones_totales
            )

            historial = requests.map { request in
                let start =
                    BackendAPIDate.day.date(from: request.start_date)?.formatted(
                        .dateTime.day().month(.abbreviated)) ?? request.start_date
                let end =
                    BackendAPIDate.day.date(from: request.end_date)?.formatted(
                        .dateTime.day().month(.abbreviated)) ?? request.end_date

                return Solicitud(
                    id: request.id,
                    tipo: "Vacaciones (\(start)-\(end))",
                    fecha: request.inserted_at ?? Date(),
                    estado: estadoSolicitud(from: request.status),
                    detalle: request.reason ?? "Solicitud de vacaciones"
                )
            }
        } catch {
            // keep local seeded experience
        }
    }

    func createVacationRequest(startDate: Date, endDate: Date, reason: String) async {
        guard let session = SessionService.load(), let authToken = session.authToken else {
            historial.insert(
                Solicitud(
                    id: UUID().uuidString, tipo: "Vacaciones solicitadas", fecha: Date(),
                    estado: .pendiente, detalle: reason),
                at: 0
            )
            return
        }

        do {
            let request = try await api.createVacationRequest(
                startDate: startDate, endDate: endDate, reason: reason, authToken: authToken)
            historial.insert(
                Solicitud(
                    id: request.id,
                    tipo: "Vacaciones solicitadas",
                    fecha: request.inserted_at ?? Date(),
                    estado: estadoSolicitud(from: request.status),
                    detalle: request.reason ?? reason
                ),
                at: 0
            )

            if empleado.diasVacacionesDisponibles > 0 {
                let diasHabilesAproximados =
                    max(
                        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day
                            ?? 0, 0) + 1
                let disponibles = max(
                    empleado.diasVacacionesDisponibles - diasHabilesAproximados, 0)
                empleado = Empleado(
                    id: empleado.id,
                    nombre: empleado.nombre,
                    apellidos: empleado.apellidos,
                    puesto: empleado.puesto,
                    departamento: empleado.departamento,
                    planta: empleado.planta,
                    diasVacacionesDisponibles: disponibles,
                    diasVacacionesTotales: empleado.diasVacacionesTotales
                )
            }
        } catch {
            historial.insert(
                Solicitud(
                    id: UUID().uuidString, tipo: "Vacaciones solicitadas", fecha: Date(),
                    estado: .pendiente, detalle: reason),
                at: 0
            )
        }
    }

    private func estadoSolicitud(from status: String) -> EstadoSolicitud {
        switch status.lowercased() {
        case "approved": return .aprobada
        case "rejected": return .rechazada
        case "completed", "resolved": return .completada
        default: return .pendiente
        }
    }
}
