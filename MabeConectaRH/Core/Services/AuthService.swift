import Foundation

enum LoginMode {
    case demo
    case empleado
    case rh
}

struct AuthService {
    func login(numero: String, nip: String) async throws -> (Empleado, UserRole) {
        try await Task.sleep(for: .milliseconds(450))

        switch (numero, nip) {
        case ("12345", "0000"):
            return (MockDataService.empleadoActual, .empleado)
        case ("99001", "1234"):
            return (MockDataService.agenteRH, .agenteRH)
        default:
            throw AuthError.credencialesInvalidas
        }
    }

    func loginDemo() -> Empleado {
        return MockDataService.empleadoActual
    }
}

enum AuthError: LocalizedError {
    case credencialesInvalidas

    var errorDescription: String? {
        "Número de empleado o NIP incorrecto."
    }
}
