import Foundation
import Observation

enum SolicitudesSegment: String, CaseIterable {
    case pendientes = "Pendientes"
    case completadas = "Completadas"
}

@Observable
@MainActor
final class SolicitudesViewModel {
    var selectedSegment: SolicitudesSegment = .pendientes
    var solicitudes = MockDataService.solicitudesRecientes
    var isLoading = false

    private let api = BackendAPI()

    var filtradas: [Solicitud] {
        switch selectedSegment {
        case .pendientes:
            solicitudes.filter { $0.estado == .pendiente }
        case .completadas:
            solicitudes.filter { $0.estado != .pendiente }
        }
    }

    func loadFromBackendIfPossible() async {
        guard let session = SessionService.load(), let authToken = session.authToken else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let remote = try await api.listHRRequests(authToken: authToken)
            solicitudes = remote.map { request in
                Solicitud(
                    id: request.id,
                    tipo: request.subject,
                    fecha: request.inserted_at ?? Date(),
                    estado: estadoSolicitud(from: request.status),
                    detalle: request.detail ?? "Solicitud RH"
                )
            }
        } catch {
            // keep local data fallback
        }
    }

    func createSolicitud(kind: String, subject: String, detail: String, priority: String) async {
        guard let session = SessionService.load(), let authToken = session.authToken else {
            solicitudes.insert(
                Solicitud(
                    id: UUID().uuidString,
                    tipo: subject,
                    fecha: Date(),
                    estado: .pendiente,
                    detalle: detail
                ),
                at: 0
            )
            return
        }

        do {
            let created = try await api.createHRRequest(
                kind: kind,
                subject: subject,
                detail: detail,
                priority: priority,
                authToken: authToken
            )

            solicitudes.insert(
                Solicitud(
                    id: created.id,
                    tipo: created.subject,
                    fecha: created.inserted_at ?? Date(),
                    estado: estadoSolicitud(from: created.status),
                    detalle: created.detail ?? detail
                ),
                at: 0
            )
        } catch {
            solicitudes.insert(
                Solicitud(
                    id: UUID().uuidString,
                    tipo: subject,
                    fecha: Date(),
                    estado: .pendiente,
                    detalle: detail
                ),
                at: 0
            )
        }
    }

    private func estadoSolicitud(from status: String) -> EstadoSolicitud {
        switch status.lowercased() {
        case "approved": return .aprobada
        case "rejected": return .rechazada
        case "resolved", "completed": return .completada
        default: return .pendiente
        }
    }
}
