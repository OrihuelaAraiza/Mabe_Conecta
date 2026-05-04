import Foundation
import Observation
import SwiftUI

enum UserRole: String, Codable {
    case empleado
    case agenteRH

    var displayName: String {
        switch self {
        case .empleado:
            "Empleado"
        case .agenteRH:
            "Agente RH"
        }
    }
}

enum AppFlow: Equatable {
    case login
    case onboarding
    case main
}

@Observable
final class AppState {
    var currentUser: Empleado?
    var userRole: UserRole = .empleado
    var isDemoMode = false
    var hasCompletedOnboarding = false
    var toastMessage: String?

    var flow: AppFlow {
        guard currentUser != nil else { return .login }
        return hasCompletedOnboarding ? .main : .onboarding
    }

    func signIn(user: Empleado, role: UserRole, isDemo: Bool) {
        currentUser = user
        userRole = role
        isDemoMode = isDemo
    }

    func signOut() {
        currentUser = nil
        userRole = .empleado
        isDemoMode = false
        toastMessage = nil
    }

    func showToast(_ message: String) {
        withAnimation(.easeInOut(duration: 0.25)) {
            toastMessage = message
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.5))
            if toastMessage == message {
                withAnimation(.easeInOut(duration: 0.25)) {
                    toastMessage = nil
                }
            }
        }
    }

    func toggleDemoRole() {
        userRole = userRole == .empleado ? .agenteRH : .empleado
        showToast("👤 Rol: \(userRole.displayName)")
    }
}
