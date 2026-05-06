import Foundation
import Observation

@Observable
final class LoginViewModel {
    var numeroEmpleado = ""
    var nip = ""
    var isLoading = false
    var errorMessage: String?

    private let authService = AuthService()

    var canSubmit: Bool {
        !numeroEmpleado.isEmpty && !nip.isEmpty && !isLoading
    }

    @MainActor
    func login() async -> AuthResult? {
        guard canSubmit else { return nil }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            return try await authService.login(numero: numeroEmpleado, nip: nip)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func loginDemo() -> Empleado {
        authService.loginDemo()
    }

    func loginDemoEmpleado() -> Empleado {
        MockDataService.empleadoActual
    }

    func loginDemoRH() -> Empleado {
        MockDataService.agenteRH
    }
}
