import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(UserPreferencesStore.self) private var preferencesStore
    @State private var viewModel: HomeViewModel
    @State private var selectedDestination: HomeQuickAccessDestination?
    let selectTab: (MainTab) -> Void

    init(empleado: Empleado, selectTab: @escaping (MainTab) -> Void = { _ in }) {
        _viewModel = State(initialValue: HomeViewModel(empleado: empleado))
        self.selectTab = selectTab
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HomeHeader(empleado: viewModel.empleado, role: appState.userRole)
                    .padding(.top, 8)

                if appState.userRole == .agenteRH {
                    rhPanelCard
                }
                if preferencesStore.isWidgetActive("accesos") {
                    quickAccessSection
                }
                if preferencesStore.isWidgetActive("bienestar") {
                    wellnessBanner
                }
                if preferencesStore.isWidgetActive("solicitudes") {
                    recentRequestsSection
                }
            }
            .padding(.horizontal, MabeTheme.horizontalPadding)
            .padding(.bottom, 28)
        }
        .refreshable {}
        .tint(.mabeBlue)
        .background(Color.mabeBackground)
        .mabeNavigationBarTitleDisplayMode(.large)
        .navigationDestination(item: $selectedDestination) { destination in
            switch destination {
            case .chat:
                ChatView()
            case .vacaciones:
                VacacionesView(empleado: viewModel.empleado)
            case .solicitudes:
                SolicitudesView()
            case .bienestar:
                BienestarView()
            }
        }
    }

    private var rhPanelCard: some View {
        MabeCard(padding: 0) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Panel RH")
                        .font(.mabeHeadline)
                        .foregroundStyle(.white)
                    Text("3 solicitudes pendientes de revisión")
                        .font(.mabeSub)
                        .foregroundStyle(.white.opacity(0.88))
                }

                Spacer()

                Button("Ver todas") {
                    open(.solicitudes)
                }
                    .font(.mabeCaption.weight(.semibold))
                    .foregroundStyle(Color.mabeBlue)
                    .padding(.horizontal, 14)
                    .frame(height: 36)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .accessibilityLabel("Ver todas las solicitudes pendientes")
            }
            .padding(18)
            .background(LinearGradient.mabeHero)
        }
    }

    private var quickAccessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Acceso rápido")
                .font(.mabeHeadline)
                .foregroundStyle(Color.mabeGray900)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.accesos) { item in
                    QuickAccessCard(item: item) {
                        open(item.destination)
                    }
                }
            }
        }
    }

    private var wellnessBanner: some View {
        MabeCard(padding: 0) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("¿Cómo estás hoy?")
                        .font(.mabeHeadline)
                        .foregroundStyle(.white)
                    Text("Registra tu bienestar y recibe apoyo oportuno.")
                        .font(.mabeSub)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Spacer()

                Button("Registrar") {
                    open(.bienestar)
                }
                    .font(.mabeCaption.weight(.semibold))
                    .foregroundStyle(Color.mabeBlue)
                    .padding(.horizontal, 14)
                    .frame(height: 36)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .accessibilityLabel("Registrar bienestar")
            }
            .padding(18)
            .background(LinearGradient.mabeHeroSoft)
        }
    }

    private var recentRequestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mis solicitudes recientes")
                .font(.mabeHeadline)
                .foregroundStyle(Color.mabeGray900)

            ForEach(viewModel.solicitudes) { solicitud in
                MabeCard {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.white)
                            .frame(width: 42, height: 42)
                            .background(LinearGradient.mabeHero)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(solicitud.tipo)
                                .font(.mabeBody.weight(.medium))
                                .foregroundStyle(Color.mabeGray900)
                            Text(solicitud.fecha.mabeShortDate)
                                .font(.mabeCaption)
                                .foregroundStyle(Color.mabeGray400)
                        }

                        Spacer()
                        MabeStatusBadge(status: solicitud.estado.rawValue, color: solicitud.estado.color)
                    }
                }
            }
        }
    }

    private func open(_ destination: HomeQuickAccessDestination) {
        if destination == .chat {
            selectTab(.assistant)
        } else {
            selectedDestination = destination
        }
    }
}

private struct HomeHeader: View {
    let empleado: Empleado
    let role: UserRole

    var body: some View {
        ZStack {
            LinearGradient.mabeCard
            Image("MabeHomeBrand")
                .resizable()
                .scaledToFill()
                .opacity(0.055)
                .offset(x: 70, y: 12)
                .accessibilityHidden(true)

            VStack(spacing: 18) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 8) {
                            Text("\(greeting.text), \(greeting.emoji)")
                                .font(.mabeHeadline)
                                .foregroundStyle(Color.mabeGray900)
                            if role == .agenteRH {
                                Text("RH")
                                    .font(.mabeLabel)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(LinearGradient.mabeHero)
                                    .clipShape(Capsule())
                            }
                        }

                        Text(empleado.nombreCompleto)
                            .font(.mabeSub)
                            .foregroundStyle(Color.mabeGray900)
                        Text("\(empleado.puesto) · \(empleado.planta)")
                            .font(.mabeCaption)
                            .foregroundStyle(Color.mabeGray400)
                    }

                    Spacer()

                    Button {} label: {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.mabeGray600)
                            .frame(width: 42, height: 42)
                            .background(Color.mabeSurface)
                            .clipShape(Circle())
                            .overlay(alignment: .topTrailing) {
                                Circle()
                                    .fill(Color.mabeDanger)
                                    .frame(width: 8, height: 8)
                                    .offset(x: -7, y: 7)
                            }
                    }
                    .accessibilityLabel("Notificaciones")

                    Text(empleado.iniciales)
                        .font(.mabeSub.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(LinearGradient.mabeHero)
                        .clipShape(Circle())
                        .overlay {
                            Circle().strokeBorder(Color.white, lineWidth: 2)
                        }
                        .shadow(color: Color.mabeElectric.opacity(0.24), radius: 10, x: 0, y: 4)
                        .accessibilityLabel("Foto de perfil")
                }

                MabeGlassCard {
                    HStack(spacing: 18) {
                        HStack(alignment: .center, spacing: 10) {
                            Text("🏖️")
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    AnimatedCounter(value: empleado.diasVacacionesDisponibles)
                                    Text("días")
                                        .font(.mabeSub)
                                        .foregroundStyle(Color.mabeGray600)
                                }
                                Text("disponibles")
                                    .font(.mabeCaption)
                                    .foregroundStyle(Color.mabeGray400)
                            }
                        }

                        Spacer()

                        VStack(alignment: .leading, spacing: 4) {
                            Label("Próx. corte", systemImage: "calendar")
                                .font(.mabeCaption)
                                .foregroundStyle(Color.mabeGray600)
                            Text("15 ene 2025")
                                .font(.mabeSub.weight(.semibold))
                                .foregroundStyle(Color.mabeGray900)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color.mabeSurface)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.mabeGray900.opacity(0.08), radius: 24, x: 0, y: 8)
    }

    private var greeting: (text: String, emoji: String) {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:
            return ("Buenos días", "☀️")
        case 12..<19:
            return ("Buenas tardes", "🌤️")
        default:
            return ("Buenas noches", "🌙")
        }
    }
}

private struct QuickAccessCard: View {
    let item: QuickAccessItem
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button {
            Haptics.impact(.light)
            action()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient.mabeHero)
                        .frame(width: 44, height: 44)
                    Image(systemName: item.icono)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.titulo)
                        .font(.mabeSub)
                        .foregroundStyle(Color.mabeGray900)
                        .lineLimit(2)
                    Text(item.subtitulo)
                        .font(.mabeCaption)
                        .foregroundStyle(Color.mabeGray400)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
            .padding(14)
            .background(Color.mabeSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.mabeGray900.opacity(0.06), radius: 12, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.96 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.spring(response: 0.2)) { isPressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.3)) { isPressed = false } }
        )
        .accessibilityLabel(item.titulo)
    }
}
