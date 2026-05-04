import SwiftUI
import Observation

@Observable
final class AppRouterViewModel {
    var empleado: Empleado?

    var isAuthenticated: Bool {
        empleado != nil
    }

    func setEmpleado(_ empleado: Empleado) {
        withAnimation(.easeInOut(duration: 0.25)) {
            self.empleado = empleado
        }
    }
}

struct AppRouter: View {
    @State private var viewModel = AppRouterViewModel()

    var body: some View {
        Group {
            if let empleado = viewModel.empleado {
                MainTabView(empleado: empleado)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                LoginView { empleado in
                    viewModel.setEmpleado(empleado)
                }
                .transition(.opacity)
            }
        }
    }
}

struct MainTabView: View {
    let empleado: Empleado

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(empleado: empleado)
            }
            .tabItem {
                Label("Inicio", systemImage: "house.fill")
            }

            NavigationStack {
                ChatView()
            }
            .tabItem {
                Label("Chat RH", systemImage: "bubble.left.and.bubble.right.fill")
            }

            NavigationStack {
                VacacionesView(empleado: empleado)
            }
            .tabItem {
                Label("Vacaciones", systemImage: "calendar")
            }

            NavigationStack {
                SolicitudesView()
            }
            .tabItem {
                Label("Solicitudes", systemImage: "doc.text.fill")
            }

            NavigationStack {
                BienestarView()
            }
            .tabItem {
                Label("Bienestar", systemImage: "heart.fill")
            }
        }
    }
}
