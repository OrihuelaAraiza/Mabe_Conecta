import Foundation

struct AuthService {
    func login(numeroEmpleado: String, nip: String) async throws -> Empleado {
        try await Task.sleep(for: .milliseconds(450))
        guard numeroEmpleado == "12345", nip == "0000" else {
            throw AuthError.credencialesInvalidas
        }
        return MockDataService.empleadoActual
    }
}

enum AuthError: LocalizedError {
    case credencialesInvalidas

    var errorDescription: String? {
        "Número de empleado o NIP incorrecto."
    }
}
