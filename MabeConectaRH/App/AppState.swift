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
    var pendingChatPrompt: String?
    var requestedMainTab: MainTab?

    var flow: AppFlow {
        guard currentUser != nil else { return .login }
        return hasCompletedOnboarding ? .main : .onboarding
    }

    init() {
        hasCompletedOnboarding = Self.loadOnboardingState()
        restoreSession()
    }

    func restoreSession() {
        guard let session = SessionService.load() else { return }

        if session.empleadoId == "99001" || session.rol == "rh" {
            currentUser = MockDataService.agenteRH
            userRole = .agenteRH
        } else {
            currentUser = MockDataService.empleadoActual
            userRole = .empleado
        }
        isDemoMode = session.isDemoMode
    }

    func signIn(user: Empleado, role: UserRole, isDemo: Bool) {
        currentUser = user
        userRole = role
        isDemoMode = isDemo
        SessionService.save(empleadoId: user.id, rol: role, isDemoMode: isDemo)
    }

    func signOut() {
        SessionService.clear()
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

    func openAssistant(prefill prompt: String) {
        pendingChatPrompt = prompt
        requestedMainTab = .assistant
    }

    func consumeRequestedMainTab() {
        requestedMainTab = nil
    }

    func consumePendingChatPrompt() -> String? {
        defer { pendingChatPrompt = nil }
        return pendingChatPrompt
    }

    func toggleDemoRole() {
        userRole = userRole == .empleado ? .agenteRH : .empleado
        if let currentUser {
            SessionService.save(empleadoId: currentUser.id, rol: userRole, isDemoMode: isDemoMode)
        }
        showToast("👤 Rol: \(userRole.displayName)")
    }

    private static func loadOnboardingState() -> Bool {
        guard let data = UserDefaults.standard.data(forKey: "mabe.userPreferences"),
              let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data)
        else { return false }
        return preferences.onboardingCompletado
    }
}
