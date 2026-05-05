import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(UserPreferencesStore.self) private var preferencesStore
    @State private var viewModel: HomeViewModel
    @State private var selectedDestination: HomeQuickAccessDestination?
    @State private var isCustomizingHome = false
    @State private var showWellbeingCheckIn = false
    let selectTab: (MainTab) -> Void

    init(empleado: Empleado, selectTab: @escaping (MainTab) -> Void = { _ in }) {
        _viewModel = State(initialValue: HomeViewModel(empleado: empleado))
        self.selectTab = selectTab
    }

    var body: some View {
        Group {
            if appState.userRole == .agenteRH {
                RHDashboardView(empleado: viewModel.empleado)
            } else {
                ScrollView {
                    compactHomeContent
                }
            }
        }
        .refreshable {}
        .tint(.mabeBlue)
        .background(Color.mabeBackground)
        .navigationBarHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if appState.userRole != .agenteRH {
                    Button {
                        isCustomizingHome = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .accessibilityLabel("Personalizar inicio")
                }
            }
        }
        .navigationDestination(item: $selectedDestination) { destination in
            switch destination {
            case .chat:
                ChatView()
            case .benefits:
                BenefitsView()
            case .vacaciones:
                VacacionesView(empleado: viewModel.empleado)
            case .solicitudes:
                SolicitudesView()
            case .bienestar:
                BienestarView()
            case .tramite:
                SolicitudesView()
            }
        }
        .sheet(isPresented: $isCustomizingHome) {
            HomeCustomizationSheet(preferences: preferencesStore.preferences) { updated in
                preferencesStore.save(updated)
            }
        }
        .sheet(isPresented: $showWellbeingCheckIn) {
            WellbeingCheckInView()
        }
    }

    private var compactHomeContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            RotatingHeroCarousel(empleado: viewModel.empleado, preferencias: preferencesStore.preferences)

            ImpactSummaryCard()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    CompactActionCard(
                        icon: "calendar.badge.clock",
                        title: "Vacaciones",
                        badge: "\(viewModel.empleado.diasVacacionesDisponibles) días",
                        badgeColor: Color(hex: "#1976FF"),
                        action: { open(.vacaciones) }
                    )
                    CompactActionCard(
                        icon: "doc.text.fill",
                        title: "Solicitudes",
                        badge: "1 pend.",
                        badgeColor: Color(hex: "#D97706"),
                        action: { open(.solicitudes) }
                    )
                    CompactActionCard(
                        icon: "ticket.fill",
                        title: "Cupones",
                        badge: "6 activos",
                        badgeColor: Color(hex: "#7C5CFC"),
                        action: { open(.benefits) }
                    )
                    CompactActionCard(
                        icon: "heart.fill",
                        title: "Bienestar",
                        badge: nil,
                        badgeColor: Color(hex: "#00C27C"),
                        action: { showWellbeingCheckIn = true }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
            .padding(.horizontal, -20)

            compactRecentRequests

            PredictiveRecommendationsView(recommendations: MockDataService.recomendacionesHome) { destination in
                openRecommendation(destination)
            }

            BienestarBannerCompact {
                showWellbeingCheckIn = true
            }

            rhValueSection
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 100)
    }

    private var compactRecentRequests: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Solicitudes recientes")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color(hex: "#0D1B3E"))
                Spacer()
                Button {
                    open(.solicitudes)
                } label: {
                    Text("Ver todas")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#1976FF"))
                }
            }

            ForEach(viewModel.solicitudes.prefix(2)) { solicitud in
                SolicitudRowCompact(solicitud: solicitud)
            }
        }
    }

    @ViewBuilder
    private func homeWidget(_ widget: String) -> some View {
        switch widget {
        case "vacaciones":
            VStack(spacing: 12) {
                vacationSummaryCard
                ImpactSummaryCard()
            }
        case "accesos":
            quickAccessSection
        case "bienestar":
            wellnessBanner
        case "solicitudes":
            recentRequestsSection
        default:
            EmptyView()
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
                ForEach(viewModel.accesos(for: preferencesStore.preferences)) { item in
                    QuickAccessCard(item: item) {
                        open(item.destination)
                    }
                }
            }
        }
    }

    private var vacationSummaryCard: some View {
        MabeCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient.mabeHero)
                        .frame(width: 48, height: 48)
                    Image(systemName: "beach.umbrella.fill")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Vacaciones disponibles")
                        .font(.mabeSub.weight(.semibold))
                        .foregroundStyle(Color.mabeGray900)
                    Text("Próximo corte: 15 ene 2025")
                        .font(.mabeCaption)
                        .foregroundStyle(Color.mabeGray400)
                }

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    AnimatedCounter(value: viewModel.empleado.diasVacacionesDisponibles)
                    Text("días")
                        .font(.mabeCaption.weight(.semibold))
                        .foregroundStyle(Color.mabeGray600)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                open(.vacaciones)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Vacaciones disponibles, \(viewModel.empleado.diasVacacionesDisponibles) días")
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
                    showWellbeingCheckIn = true
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
        } else if destination == .benefits {
            selectTab(.benefits)
        } else {
            selectedDestination = destination
        }
    }

    private func openRecommendation(_ destination: HomeRecommendationDestination) {
        switch destination {
        case .vacaciones:
            open(.vacaciones)
        case .benefits:
            open(.benefits)
        case .solicitudes:
            open(.solicitudes)
        case .bienestar:
            showWellbeingCheckIn = true
        }
    }

    private var rhValueSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Avisos de RH")
                .font(.mabeHeadline)
                .foregroundStyle(Color.mabeGray900)

            MabeCard {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(MockDataService.avisosRH, id: \.self) { aviso in
                        HStack(spacing: 10) {
                            Image(systemName: "megaphone.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.mabeBlue)
                                .frame(width: 28, height: 28)
                                .background(Color.mabeBlue.opacity(0.1))
                                .clipShape(Circle())
                            Text(aviso)
                                .font(.mabeCaption)
                                .foregroundStyle(Color.mabeGray600)
                            Spacer()
                        }
                    }

                    Divider()

                    HStack(spacing: 0) {
                        miniOperationalMetric(value: "3 min", label: "Respuesta RH")
                        Divider().frame(height: 36)
                        miniOperationalMetric(value: "72%", label: "Automatizados")
                    }
                }
            }
        }
    }

    private func miniOperationalMetric(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.mabeBlue)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.mabeGray500)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct HomeCustomizationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: UserPreferences
    let onSave: (UserPreferences) -> Void

    private let widgetIDs = ["vacaciones", "accesos", "bienestar", "solicitudes"]
    private let shortcutIDs = QuickAccessItem.defaultOrder

    init(preferences: UserPreferences, onSave: @escaping (UserPreferences) -> Void) {
        _draft = State(initialValue: preferences)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Widgets de inicio") {
                    ForEach(orderedWidgets, id: \.self) { id in
                        PreferenceOrderRow(
                            title: widgetTitle(id),
                            subtitle: widgetSubtitle(id),
                            icon: widgetIcon(id),
                            isActive: Binding(
                                get: { draft.widgetsActivos.contains(id) },
                                set: { setWidgetActive($0, id: id) }
                            ),
                            canMoveUp: canMove(id, in: orderedWidgets, direction: -1),
                            canMoveDown: canMove(id, in: orderedWidgets, direction: 1),
                            moveUp: { move(id, in: &draft.widgetsOrden, allIDs: widgetIDs, direction: -1) },
                            moveDown: { move(id, in: &draft.widgetsOrden, allIDs: widgetIDs, direction: 1) }
                        )
                    }
                }

                Section("Accesos rápidos") {
                    ForEach(orderedShortcuts, id: \.self) { id in
                        PreferenceOrderRow(
                            title: shortcutTitle(id),
                            subtitle: shortcutSubtitle(id),
                            icon: shortcutIcon(id),
                            isActive: Binding(
                                get: { draft.shortcutsActivos.contains(id) },
                                set: { setShortcutActive($0, id: id) }
                            ),
                            canMoveUp: canMove(id, in: orderedShortcuts, direction: -1),
                            canMoveDown: canMove(id, in: orderedShortcuts, direction: 1),
                            moveUp: { move(id, in: &draft.shortcutsOrden, allIDs: shortcutIDs, direction: -1) },
                            moveDown: { move(id, in: &draft.shortcutsOrden, allIDs: shortcutIDs, direction: 1) }
                        )
                    }
                }
            }
            .navigationTitle("Personalizar inicio")
            .mabeNavigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSave(normalized(draft))
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private var orderedWidgets: [String] {
        ordered(draft.widgetsOrden, allIDs: widgetIDs)
    }

    private var orderedShortcuts: [String] {
        ordered(draft.shortcutsOrden, allIDs: shortcutIDs)
    }

    private func ordered(_ order: [String], allIDs: [String]) -> [String] {
        let validOrder = order.filter { allIDs.contains($0) }
        return validOrder + allIDs.filter { !validOrder.contains($0) }
    }

    private func setWidgetActive(_ isActive: Bool, id: String) {
        if isActive {
            if !draft.widgetsActivos.contains(id) {
                draft.widgetsActivos.append(id)
            }
            if !draft.widgetsOrden.contains(id) {
                draft.widgetsOrden.append(id)
            }
        } else {
            draft.widgetsActivos.removeAll { $0 == id }
        }
        Haptics.impact(.light)
    }

    private func setShortcutActive(_ isActive: Bool, id: String) {
        if isActive {
            if !draft.shortcutsActivos.contains(id) {
                draft.shortcutsActivos.append(id)
            }
            if !draft.shortcutsOrden.contains(id) {
                draft.shortcutsOrden.append(id)
            }
        } else {
            draft.shortcutsActivos.removeAll { $0 == id }
        }
        Haptics.impact(.light)
    }

    private func canMove(_ id: String, in order: [String], direction: Int) -> Bool {
        guard let index = order.firstIndex(of: id) else { return false }
        return order.indices.contains(index + direction)
    }

    private func move(_ id: String, in order: inout [String], allIDs: [String], direction: Int) {
        var normalizedOrder = ordered(order, allIDs: allIDs)
        guard let index = normalizedOrder.firstIndex(of: id) else { return }
        let newIndex = index + direction
        guard normalizedOrder.indices.contains(newIndex) else { return }
        normalizedOrder.swapAt(index, newIndex)
        order = normalizedOrder
        Haptics.impact(.light)
    }

    private func normalized(_ preferences: UserPreferences) -> UserPreferences {
        var updated = preferences
        updated.widgetsOrden = ordered(preferences.widgetsOrden, allIDs: widgetIDs)
        updated.shortcutsOrden = ordered(preferences.shortcutsOrden, allIDs: shortcutIDs)
        updated.widgetsActivos = updated.widgetsActivos.filter { widgetIDs.contains($0) }
        updated.shortcutsActivos = updated.shortcutsActivos.filter { shortcutIDs.contains($0) }
        return updated
    }

    private func widgetTitle(_ id: String) -> String {
        switch id {
        case "vacaciones": "Vacaciones"
        case "accesos": "Acceso rápido"
        case "bienestar": "Bienestar"
        case "solicitudes": "Solicitudes recientes"
        default: id
        }
    }

    private func widgetSubtitle(_ id: String) -> String {
        switch id {
        case "vacaciones": "Saldo y próximo corte"
        case "accesos": "Shortcuts personalizados"
        case "bienestar": "Check-in emocional"
        case "solicitudes": "Últimos trámites"
        default: ""
        }
    }

    private func widgetIcon(_ id: String) -> String {
        switch id {
        case "vacaciones": "beach.umbrella.fill"
        case "accesos": "square.grid.2x2.fill"
        case "bienestar": "heart.fill"
        case "solicitudes": "doc.text.fill"
        default: "square.fill"
        }
    }

    private func shortcutTitle(_ id: String) -> String {
        QuickAccessItem.item(for: id)?.titulo ?? id
    }

    private func shortcutSubtitle(_ id: String) -> String {
        QuickAccessItem.item(for: id)?.subtitulo ?? ""
    }

    private func shortcutIcon(_ id: String) -> String {
        QuickAccessItem.item(for: id)?.icono ?? "link"
    }
}

private struct PreferenceOrderRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isActive: Bool
    let canMoveUp: Bool
    let canMoveDown: Bool
    let moveUp: () -> Void
    let moveDown: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.mabeBlue)
                .frame(width: 34, height: 34)
                .background(Color.mabeBlue.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.mabeSub.weight(.semibold))
                    .foregroundStyle(Color.mabeGray900)
                Text(subtitle)
                    .font(.mabeCaption)
                    .foregroundStyle(Color.mabeGray400)
            }

            Spacer()

            HStack(spacing: 4) {
                Button(action: moveUp) {
                    Image(systemName: "chevron.up")
                        .frame(width: 30, height: 30)
                }
                .disabled(!canMoveUp)
                .accessibilityLabel("Subir \(title)")

                Button(action: moveDown) {
                    Image(systemName: "chevron.down")
                        .frame(width: 30, height: 30)
                }
                .disabled(!canMoveDown)
                .accessibilityLabel("Bajar \(title)")
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(Color.mabeGray600)

            Toggle("", isOn: $isActive)
                .labelsHidden()
                .tint(.mabeBlue)
        }
        .padding(.vertical, 4)
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
                        .fill(Color.mabeBlue)
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

private struct CompactActionCard: View {
    let icon: String
    let title: String
    let badge: String?
    let badgeColor: Color
    let action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button {
            Haptics.impact(.light)
            action()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    Circle()
                        .fill(badgeColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(badgeColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#0D1B3E"))
                    if let badge {
                        Text(badge)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(badgeColor)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
            .frame(width: 110, height: 112, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color(hex: "#0D1B3E").opacity(0.06), radius: 10, x: 0, y: 3)
            .scaleEffect(pressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.spring(response: 0.2)) { pressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.3)) { pressed = false } }
        )
    }
}

private struct SolicitudRowCompact: View {
    let solicitud: Solicitud

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(LinearGradient.mabeHero)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(solicitud.tipo)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#0D1B3E"))
                    .lineLimit(1)
                Text(solicitud.fecha.mabeShortDate)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#9AA5BE"))
            }

            Spacer()

            MabeStatusBadge(status: solicitud.estado.rawValue, color: solicitud.estado.color)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color(hex: "#0D1B3E").opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

private struct BienestarBannerCompact: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "#00C27C"))
                    .frame(width: 38, height: 38)
                    .background(Color(hex: "#00C27C").opacity(0.12))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("¿Cómo estás hoy?")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(hex: "#0D1B3E"))
                    Text("Registra tu bienestar en menos de un minuto")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "#9AA5BE"))
                        .lineLimit(1)
                }

                Spacer()

                Text("Registrar")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "#1976FF"))
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color(hex: "#0D1B3E").opacity(0.06), radius: 10, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}
