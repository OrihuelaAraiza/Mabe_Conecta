import SwiftUI

struct MiRHView: View {
    @Environment(AppState.self) private var appState
    @Environment(UserPreferencesStore.self) private var preferencesStore
    @Environment(RewardService.self) private var rewardService
    @State private var showingLogoutAlert = false
    @State private var showingOnboardingAlert = false

    var body: some View {
        Group {
            if appState.userRole == .agenteRH {
                MiRHViewAgente()
            } else {
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

                            NavigationLink {
                                PrestacionesView()
                            } label: {
                                MenuRow(icon: "gift.fill", title: "Mis Prestaciones", color: Color(hex: "#003087"))
                            }

                            NavigationLink {
                                RecompensasView()
                            } label: {
                                MenuRow(
                                    icon: "star.fill",
                                    title: "Mis Recompensas",
                                    color: Color(hex: "#D97706"),
                                    badge: "\(rewardService.profile.puntosDisponibles) pts"
                                )
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

                                Button {
                                    rewardService.resetToDemoProfile()
                                    appState.showToast("⭐ Recompensas demo restauradas")
                                } label: {
                                    MenuRow(icon: "star.circle", title: "Reset recompensas demo", color: .mabeWarning)
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

struct MiRHViewAgente: View {
    @Environment(AppState.self) private var appState
    @Environment(UserPreferencesStore.self) private var preferencesStore
    @State private var showingEvaluacion = false
    @State private var showingDirectorio = false
    @State private var showingInsights = false
    @State private var showingSolicitudes = false
    @State private var showingBienestar = false
    @State private var showingRanking = false
    @State private var showingPreferences = false
    @State private var showingLogout = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                section("GESTIÓN") {
                    agenteRow(icon: "person.2.fill", label: "Directorio de empleados", color: Color(hex: "#003087")) {
                        showingDirectorio = true
                    }
                    agenteRow(icon: "chart.bar.fill", label: "Cargar evaluación cuatrimestral", color: Color(hex: "#00875A")) {
                        showingEvaluacion = true
                    }
                    agenteRow(icon: "doc.text.fill", label: "Solicitudes pendientes", color: Color(hex: "#D97706"), badge: "\(MockDataService.solicitudesUrgentes.count)") {
                        showingSolicitudes = true
                    }
                }

                section("ANÁLISIS") {
                    agenteRow(icon: "sparkles", label: "Insights de IA del equipo", color: Color(hex: "#7C5CFC")) {
                        showingInsights = true
                    }
                    agenteRow(icon: "chart.line.uptrend.xyaxis", label: "Reporte de bienestar", color: Color(hex: "#0EA5E9")) {
                        showingBienestar = true
                    }
                    agenteRow(icon: "trophy.fill", label: "Ranking de recompensas", color: Color(hex: "#D97706")) {
                        showingRanking = true
                    }
                }

                section("CUENTA") {
                    agenteRow(icon: "gearshape.fill", label: "Preferencias", color: Color(hex: "#9AA5BE")) {
                        showingPreferences = true
                    }

                    Button {
                        showingLogout = true
                    } label: {
                        rowContent(icon: "rectangle.portrait.and.arrow.right", label: "Cerrar sesión", color: .mabeDanger, badge: nil)
                    }
                    .buttonStyle(.plain)
                }

                if appState.isDemoMode {
                    section("DEV TOOLS") {
                        agenteRow(icon: "arrow.2.circlepath", label: "Cambiar rol (Demo)", color: Color(hex: "#D97706")) {
                            appState.toggleDemoRole()
                        }
                        agenteRow(icon: "wrench.fill", label: "Reset onboarding", color: Color(hex: "#D97706")) {
                            preferencesStore.reset()
                            appState.hasCompletedOnboarding = false
                        }
                    }
                }
            }
            .padding(MabeTheme.horizontalPadding)
            .padding(.bottom, 100)
        }
        .navigationBarHidden(true)
        .background(Color.mabeBase)
        .sheet(isPresented: $showingEvaluacion) {
            CargarEvaluacionSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .sheet(isPresented: $showingDirectorio) {
            DirectorioEmpleadosSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .sheet(isPresented: $showingInsights) {
            RHInsightsFullSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .sheet(isPresented: $showingSolicitudes) {
            RHSolicitudesPendientesSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .sheet(isPresented: $showingBienestar) {
            RHWellbeingReportSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .sheet(isPresented: $showingRanking) {
            RHRankingRecompensasSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .sheet(isPresented: $showingPreferences) {
            RHPreferencesSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .alert("¿Cerrar sesión?", isPresented: $showingLogout) {
            Button("Cancelar", role: .cancel) {}
            Button("Salir", role: .destructive) { appState.signOut() }
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "#B45309"), Color(hex: "#D97706")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 50, height: 50)
                Text(appState.currentUser?.iniciales ?? "RH")
                    .font(.mabeH3)
                    .foregroundColor(.white)
            }
            .shadow(color: Color(hex: "#D97706").opacity(0.3), radius: 8, x: 0, y: 3)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(appState.currentUser?.nombreCompleto ?? "Agente RH")
                        .font(.mabeH3)
                        .foregroundColor(.mabeText1)
                    Text("RH")
                        .font(.mabeLabelSm)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: "#D97706"))
                        .clipShape(Capsule())
                }
                Text(appState.currentUser?.puesto ?? "Recursos Humanos")
                    .font(.mabeLabelMd)
                    .foregroundColor(.mabeText3)
            }
            Spacer()
        }
        .padding(.top, 4)
        .padding(.bottom, 4)
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.mabeLabelSm)
                .foregroundColor(.mabeText3)
                .tracking(0.5)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.mabeSurface0)
            .clipShape(RoundedRectangle(cornerRadius: MabeTheme.cardRadius, style: .continuous))
            .mabeCardShadow()
        }
    }

    private func agenteRow(icon: String, label: String, color: Color, badge: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            rowContent(icon: icon, label: label, color: color, badge: badge)
        }
        .buttonStyle(.plain)
    }

    private func rowContent(icon: String, label: String, color: Color, badge: String?) -> some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color.opacity(0.1))
                .frame(width: 34, height: 34)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                }
            Text(label)
                .font(.mabeBody)
                .foregroundColor(color == .mabeDanger ? .mabeDanger : .mabeText1)
            Spacer()
            if let badge {
                Text(badge)
                    .font(.mabeLabelSm)
                    .foregroundColor(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(color)
                    .clipShape(Capsule())
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.mabeText4)
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 58)
        .contentShape(Rectangle())
    }
}

private struct MenuRow: View {
    let icon: String
    let title: String
    var color: Color = .mabeBlue
    var badge: String?

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

            if let badge {
                Text(badge)
                    .font(.mabeLabelSm)
                    .foregroundStyle(color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.1))
                    .clipShape(Capsule())
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.mabeGray200)
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 58)
        .contentShape(Rectangle())
    }
}
