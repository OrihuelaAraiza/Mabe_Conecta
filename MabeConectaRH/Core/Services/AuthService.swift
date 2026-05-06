import Foundation
import SwiftUI

enum LoginMode {
    case demo
    case empleado
    case rh
}

struct AuthResult {
    let empleado: Empleado
    let role: UserRole
    let token: String
}

struct AuthService {
    private let api = BackendAPI()

    func login(numero: String, nip: String) async throws -> AuthResult {
        do {
            let response = try await api.login(employeeNumber: numero, nip: nip)
            let empleado = response.employee.toEmpleado()
            let role: UserRole = numero == "99001" ? .agenteRH : .empleado
            return AuthResult(empleado: empleado, role: role, token: response.token)
        } catch let error as BackendError {
            throw AuthError.backend(error.localizedDescription)
        } catch {
            throw AuthError.backend("No fue posible iniciar sesión con el servidor.")
        }
    }

    func loginDemo() -> Empleado {
        return MockDataService.empleadoActual
    }
}

enum AuthError: LocalizedError {
    case backend(String)

    var errorDescription: String? {
        switch self {
        case .backend(let message):
            return message
        }
    }
}

enum BackendConfig {
    static let baseURL = URL(string: "http://localhost:4000")!
}

enum BackendError: LocalizedError {
    case invalidResponse
    case server(Int, String)
    case decoding

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Respuesta inválida del backend."
        case .server(_, let message):
            return message
        case .decoding:
            return "No se pudo interpretar la respuesta del backend."
        }
    }
}

struct BackendAPI {
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    func login(employeeNumber: String, nip: String) async throws -> LoginResponseData {
        let body = LoginRequest(employee_id: employeeNumber, nip: nip)
        let response: Envelope<LoginResponseData> = try await send(
            path: "/api/auth/login", method: "POST", body: body, authToken: nil)
        return response.data
    }

    func chat(prompt: String, sessionID: String?, authToken: String) async throws -> AgentChatData {
        let body = AgentChatRequest(prompt: prompt, session_id: sessionID)
        let response: Envelope<AgentChatData> = try await send(
            path: "/api/agent/chat", method: "POST", body: body, authToken: authToken)
        return response.data
    }

    func listCoupons(authToken: String) async throws -> [BackendCoupon] {
        let response: Envelope<[BackendCoupon]> = try await send(
            path: "/api/coupons", method: "GET", body: Optional<String>.none, authToken: authToken)
        return response.data
    }

    func listBoughtCoupons(authToken: String) async throws -> [BackendEmployeeCoupon] {
        let response: Envelope<[BackendEmployeeCoupon]> = try await send(
            path: "/api/coupons/buy", method: "GET", body: Optional<String>.none,
            authToken: authToken)
        return response.data
    }

    func buyCoupon(couponID: String, authToken: String) async throws -> BackendEmployeeCoupon {
        let body = BuyCouponRequest(coupon_id: couponID)
        let response: Envelope<BackendEmployeeCoupon> = try await send(
            path: "/api/coupons/buy", method: "POST", body: body, authToken: authToken)
        return response.data
    }

    func vacationBalance(authToken: String) async throws -> VacationBalanceData {
        let response: Envelope<VacationBalanceData> = try await send(
            path: "/api/hr/vacations/balance", method: "GET", body: Optional<String>.none,
            authToken: authToken)
        return response.data
    }

    func listVacationRequests(authToken: String) async throws -> [VacationRequestData] {
        let response: Envelope<[VacationRequestData]> = try await send(
            path: "/api/hr/vacations/requests", method: "GET", body: Optional<String>.none,
            authToken: authToken)
        return response.data
    }

    func createVacationRequest(startDate: Date, endDate: Date, reason: String, authToken: String)
        async throws -> VacationRequestData
    {
        let body = CreateVacationRequest(
            start_date: Self.dayFormatter.string(from: startDate),
            end_date: Self.dayFormatter.string(from: endDate), reason: reason)
        let response: Envelope<VacationRequestData> = try await send(
            path: "/api/hr/vacations/requests", method: "POST", body: body, authToken: authToken)
        return response.data
    }

    func listHRRequests(authToken: String) async throws -> [HRRequestData] {
        let response: Envelope<[HRRequestData]> = try await send(
            path: "/api/hr/requests", method: "GET", body: Optional<String>.none,
            authToken: authToken)
        return response.data
    }

    func createHRRequest(
        kind: String, subject: String, detail: String, priority: String, authToken: String
    ) async throws -> HRRequestData {
        let body = CreateHRRequest(kind: kind, subject: subject, detail: detail, priority: priority)
        let response: Envelope<HRRequestData> = try await send(
            path: "/api/hr/requests", method: "POST", body: body, authToken: authToken)
        return response.data
    }

    func createEscalationTicket(title: String, detail: String, urgency: String, authToken: String)
        async throws -> EscalationTicketData
    {
        let body = CreateEscalationTicket(title: title, detail: detail, urgency: urgency)
        let response: Envelope<EscalationTicketData> = try await send(
            path: "/api/hr/escalations", method: "POST", body: body, authToken: authToken)
        return response.data
    }

    func createDocumentRequest(
        documentType: String, includeSalary: Bool, notes: String, authToken: String
    ) async throws -> DocumentRequestData {
        let body = CreateDocumentRequest(
            document_type: documentType, include_salary: includeSalary, notes: notes)
        let response: Envelope<DocumentRequestData> = try await send(
            path: "/api/hr/documents", method: "POST", body: body, authToken: authToken)
        return response.data
    }

    func listNotifications(authToken: String) async throws -> [NotificationData] {
        let response: Envelope<[NotificationData]> = try await send(
            path: "/api/hr/notifications", method: "GET", body: Optional<String>.none,
            authToken: authToken)
        return response.data
    }

    func listWellbeingEntries(authToken: String) async throws -> [WellbeingEntryData] {
        let response: Envelope<[WellbeingEntryData]> = try await send(
            path: "/api/hr/wellbeing/entries", method: "GET", body: Optional<String>.none,
            authToken: authToken)
        return response.data
    }

    func createWellbeingEntry(
        mood: String, energyLevel: Int?, stressLevel: Int?, note: String?, factors: [String],
        authToken: String
    ) async throws -> WellbeingEntryData {
        let body = CreateWellbeingEntry(
            mood: mood, energy_level: energyLevel, stress_level: stressLevel, note: note,
            factors: factors)
        let response: Envelope<WellbeingEntryData> = try await send(
            path: "/api/hr/wellbeing/entries", method: "POST", body: body, authToken: authToken)
        return response.data
    }

    private func send<RequestBody: Encodable, ResponseBody: Decodable>(
        path: String, method: String, body: RequestBody?, authToken: String?
    ) async throws -> ResponseBody {
        let url = BackendConfig.baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let authToken {
            request.setValue(authToken, forHTTPHeaderField: "x-auth")
        }

        if let body {
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw BackendError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            if let apiError = try? decoder.decode(APIErrorEnvelope.self, from: data) {
                throw BackendError.server(http.statusCode, apiError.errors.detail)
            }
            throw BackendError.server(http.statusCode, "Error del servidor (\(http.statusCode)).")
        }

        do {
            return try decoder.decode(ResponseBody.self, from: data)
        } catch {
            throw BackendError.decoding
        }
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

struct Envelope<T: Decodable>: Decodable {
    let data: T
}

struct APIErrorEnvelope: Decodable {
    struct ErrorDetail: Decodable {
        let detail: String
    }

    let errors: ErrorDetail
}

struct LoginRequest: Encodable {
    let employee_id: String
    let nip: String
}

struct LoginResponseData: Decodable {
    let token: String
    let token_type: String
    let employee: BackendEmployee
}

struct BackendEmployee: Decodable {
    let id: String
    let employee_id: String
    let name: String
    let apellidos: String
    let puesto: String
    let departamento: String
    let planta: String
    let dias_vacaciones_disponibles: Int
    let dias_vacaciones_totales: Int
    let points: Int
}

struct AgentChatRequest: Encodable {
    let prompt: String
    let session_id: String?
}

struct AgentChatData: Decodable {
    let response: String
    let session_id: String
    let timestamp: Date
}

struct BuyCouponRequest: Encodable {
    let coupon_id: String
}

struct BackendCoupon: Decodable {
    let coupon_id: String
    let code: String
    let brand: String?
    let category: String
    let description: String
    let title: String
    let points_value: Int
    let expiry_date: String?
}

struct BackendCouponDetail: Decodable {
    let coupon_id: String
    let code: String
    let brand: String?
    let category: String
    let title: String
    let description: String
    let points_value: Int
    let expiry_date: String?
}

struct BackendEmployeeCoupon: Decodable {
    let employee_coupon_id: String
    let employee_id: String
    let coupon_id: String
    let purchased_at: Date?
    let used: Bool
    let expiry_date: String?
    let coupon: BackendCouponDetail?
}

struct VacationBalanceData: Decodable {
    let dias_vacaciones_disponibles: Int
    let dias_vacaciones_totales: Int
    let dias_vacaciones_usados: Int
}

struct VacationRequestData: Decodable {
    let id: String
    let employee_id: String
    let start_date: String
    let end_date: String
    let reason: String?
    let status: String
    let inserted_at: Date?
}

struct CreateVacationRequest: Encodable {
    let start_date: String
    let end_date: String
    let reason: String
}

struct HRRequestData: Decodable {
    let id: String
    let employee_id: String
    let kind: String
    let subject: String
    let detail: String?
    let status: String
    let priority: String
    let inserted_at: Date?
}

struct CreateHRRequest: Encodable {
    let kind: String
    let subject: String
    let detail: String
    let priority: String
}

struct EscalationTicketData: Decodable {
    let id: String
    let employee_id: String
    let title: String
    let detail: String
    let urgency: String
    let status: String
    let inserted_at: Date?
}

struct CreateEscalationTicket: Encodable {
    let title: String
    let detail: String
    let urgency: String
}

struct DocumentRequestData: Decodable {
    let id: String
    let employee_id: String
    let document_type: String
    let include_salary: Bool
    let notes: String?
    let status: String
    let inserted_at: Date?
}

struct CreateDocumentRequest: Encodable {
    let document_type: String
    let include_salary: Bool
    let notes: String
}

struct NotificationData: Decodable {
    let id: String
    let employee_id: String
    let title: String
    let body: String
    let kind: String
    let read: Bool
    let inserted_at: Date?
}

struct WellbeingEntryData: Decodable {
    let id: String
    let employee_id: String
    let mood: String
    let energy_level: Int?
    let stress_level: Int?
    let note: String?
    let factors: [String]
    let inserted_at: Date?
}

struct CreateWellbeingEntry: Encodable {
    let mood: String
    let energy_level: Int?
    let stress_level: Int?
    let note: String?
    let factors: [String]
}

extension BackendEmployee {
    func toEmpleado() -> Empleado {
        Empleado(
            id: id,
            nombre: name,
            apellidos: apellidos,
            puesto: puesto,
            departamento: departamento,
            planta: planta,
            diasVacacionesDisponibles: dias_vacaciones_disponibles,
            diasVacacionesTotales: dias_vacaciones_totales
        )
    }
}

extension BackendCoupon {
    func toCupon() -> Cupon {
        Cupon(
            id: coupon_id,
            titulo: title,
            empresa: brand ?? "Mabe",
            descripcion: description,
            icon: iconForCategory(category),
            gradient: gradientForCategory(category),
            categoria: cuponCategoryForBackend(category),
            puntosCosto: points_value,
            vencimiento: shortExpiration(expiry_date),
            codigoPromo: code,
            terminos: [
                "Sujeto a disponibilidad",
                "Válido para colaboradores activos",
                "Uso personal e intransferible",
            ]
        )
    }
}

func iconForCategory(_ category: String) -> String {
    switch category.lowercased() {
    case "food": return "fork.knife"
    case "transportation": return "car.fill"
    case "wellness": return "cross.case.fill"
    case "shopping": return "bag.fill"
    default: return "ticket.fill"
    }
}

func gradientForCategory(_ category: String) -> LinearGradient {
    switch category.lowercased() {
    case "food":
        return LinearGradient(
            colors: [Color(hex: "#FF441F"), Color(hex: "#FF7043")], startPoint: .topLeading,
            endPoint: .bottomTrailing)
    case "transportation":
        return LinearGradient(
            colors: [Color(hex: "#1C1C1E"), Color(hex: "#3A3A3C")], startPoint: .topLeading,
            endPoint: .bottomTrailing)
    case "wellness":
        return LinearGradient(
            colors: [Color(hex: "#00704A"), Color(hex: "#00C27C")], startPoint: .topLeading,
            endPoint: .bottomTrailing)
    case "shopping":
        return LinearGradient(
            colors: [Color(hex: "#D97706"), Color(hex: "#F59E0B")], startPoint: .topLeading,
            endPoint: .bottomTrailing)
    default:
        return LinearGradient(
            colors: [Color(hex: "#003087"), Color(hex: "#1976FF")], startPoint: .topLeading,
            endPoint: .bottomTrailing)
    }
}

func cuponCategoryForBackend(_ category: String) -> CuponCategory {
    switch category.lowercased() {
    case "food": return .comida
    case "transportation": return .transporte
    case "wellness": return .salud
    case "shopping": return .tienda
    default: return .entretenimiento
    }
}

func shortExpiration(_ value: String?) -> String {
    guard let value,
        let date = BackendAPIDate.day.date(from: value)
    else { return "Sin fecha" }
    return date.formatted(.dateTime.day().month(.abbreviated))
}

enum BackendAPIDate {
    static let day: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
