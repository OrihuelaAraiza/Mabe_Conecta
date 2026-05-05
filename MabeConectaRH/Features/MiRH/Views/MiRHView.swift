import SwiftUI

struct MiRHView: View {
    @Environment(AppState.self) private var appState
    @Environment(UserPreferencesStore.self) private var preferencesStore
    @State private var showingLogoutAlert = false
    @State private var showingOnboardingAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                menuSection("TRÁMITES") {
                    if let empleado = appState.currentUser {
                        NavigationLink {
                            VacacionesView(empleado: empleado)
                        } label: {
                            MenuRow(icon: "calendar", title: "Mis Vacaciones")
                        }
                    }

                    NavigationLink {
                        SolicitudesView()
                    } label: {
                        MenuRow(icon: "doc.text", title: "Mis Solicitudes")
                    }
                }

                menuSection("BENEFICIOS") {
                    NavigationLink {
                        CuponesView()
                    } label: {
                        MenuRow(icon: "ticket.fill", title: "Mis Cupones", color: Color(hex: "#7C5CFC"))
                    }
                }

                menuSection("BIENESTAR") {
                    NavigationLink {
                        BienestarView()
                    } label: {
                        MenuRow(icon: "heart", title: "Mi Bienestar")
                    }
                }

                menuSection("CUENTA") {
                    MenuRow(icon: "bell", title: "Notificaciones")
                    MenuRow(icon: "gearshape", title: "Preferencias")

                    Button {
                        showingOnboardingAlert = true
                    } label: {
                        MenuRow(icon: "arrow.clockwise", title: "Repetir Onboarding")
                    }
                    .buttonStyle(.plain)

                    Button {
                        showingLogoutAlert = true
                    } label: {
                        MenuRow(icon: "rectangle.portrait.and.arrow.right", title: "Cerrar sesión", color: .mabeDanger)
                    }
                    .buttonStyle(.plain)
                }

                if appState.isDemoMode {
                    menuSection("DEV TOOLS", headerColor: .mabeWarning) {
                        Button {
                            preferencesStore.reset()
                            appState.hasCompletedOnboarding = false
                            appState.showToast("🔁 Onboarding reseteado")
                        } label: {
                            MenuRow(icon: "wrench.adjustable", title: "Reset onboarding", color: .mabeWarning)
                        }
                        .buttonStyle(.plain)

                        Button {
                            appState.toggleDemoRole()
                        } label: {
                            MenuRow(icon: "person.crop.circle.badge.checkmark", title: "Cambiar rol (Demo)", color: .mabeWarning)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(MabeTheme.horizontalPadding)
            .padding(.bottom, 28)
        }
        .background(Color.mabeBackground)
        .navigationTitle("Mi RH")
        .mabeNavigationBarTitleDisplayMode(.large)
        .alert("¿Cerrar sesión?", isPresented: $showingLogoutAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Sí, salir", role: .destructive) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    appState.signOut()
                }
            }
        }
        .alert("¿Repetir configuración inicial?", isPresented: $showingOnboardingAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Sí, configurar") {
                preferencesStore.reset()
                withAnimation(.easeInOut(duration: 0.25)) {
                    appState.hasCompletedOnboarding = false
                }
            }
        }
    }

    private func menuSection<Content: View>(
        _ title: String,
        headerColor: Color = .mabeGray500,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(headerColor)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.mabeSurface)
            .clipShape(RoundedRectangle(cornerRadius: MabeTheme.cardRadius, style: .continuous))
            .mabeCardShadow()
        }
    }
}

private struct MenuRow: View {
    let icon: String
    let title: String
    var color: Color = .mabeBlue

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 38, height: 38)
                .background(color.opacity(0.1))
                .clipShape(Circle())

            Text(title)
                .font(.body)
                .foregroundStyle(color == .mabeDanger ? Color.mabeDanger : Color.mabeGray900)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.mabeGray200)
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 58)
        .contentShape(Rectangle())
    }
}
