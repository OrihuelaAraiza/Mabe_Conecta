import Charts
import SwiftUI

struct RHDashboardView: View {
    let empleado: Empleado
    @State private var solicitudes = MockDataService.solicitudesUrgentes
    @State private var solicitudesResueltas: [SolicitudRH] = []
    @State private var showingDirectorio = false
    @State private var showingEvaluacion = false
    @State private var showingInsights = false
    @State private var showingAlertas = false
    @State private var selectedChat: ChatEscalado?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                RHHeroWidget(empleado: empleado)

                RHQuickActions(
                    onDirectorio: { showingDirectorio = true },
                    onEvaluacion: { showingEvaluacion = true },
                    onInsights: { showingInsights = true },
                    onAlertas: { showingAlertas = true }
                )
                .padding(.horizontal, 20)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    KPICard(valor: solicitudes.count,  label: "Pendientes",    icon: "clock.fill",                        accentColor: Color(hex: "#D97706"))
                    KPICard(valor: solicitudesResueltas.count + 12, label: "Resueltos hoy", icon: "checkmark.circle.fill",             accentColor: Color(hex: "#00C27C"))
                    KPICard(valor: 5,  label: "Chats activos", icon: "bubble.left.and.bubble.right.fill", accentColor: Color(hex: "#1976FF"))
                    KPICard(valor: 94, label: "Satisfacción %",icon: "star.fill",                         accentColor: Color(hex: "#7C5CFC"))
                }
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Requieren atención")
                            .font(.mabeH3)
                            .foregroundColor(.mabeText1)
                        Spacer()
                        let urgentCount = solicitudes.filter { $0.urgencia == .alta }.count
                        if urgentCount > 0 {
                            PulsingDot(color: Color(hex: "#F03E3E"))
                            Text("\(urgentCount) urgentes")
                                .font(.mabeLabelMd)
                                .foregroundColor(Color(hex: "#F03E3E"))
                        }
                    }

                    if solicitudes.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(Color(hex: "#00C27C"))
                            Text("Todo al día")
                                .font(.mabeH3)
                                .foregroundColor(.mabeText1)
                            Text("No hay solicitudes pendientes")
                                .font(.mabeLabelLg)
                                .foregroundColor(.mabeText3)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(Color.mabeSurface0)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    } else {
                        ForEach(solicitudes) { solicitud in
                            RHSolicitudRow(
                                solicitud: solicitud,
                                onAprobar: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                                        solicitudesResueltas.append(solicitud)
                                        solicitudes.removeAll { $0.id == solicitud.id }
                                    }
                                },
                                onRechazar: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                                        if let index = solicitudes.firstIndex(where: { $0.id == solicitud.id }) {
                                            solicitudes[index] = SolicitudRH(
                                                id: solicitud.id,
                                                empleadoNombre: solicitud.empleadoNombre,
                                                empleadoId: solicitud.empleadoId,
                                                ultimoMensaje: "Escalado - \(solicitud.ultimoMensaje)",
                                                urgencia: .alta,
                                                tiempoRelativo: "ahora"
                                            )
                                        }
                                    }
                                },
                                onVerDetalle: { selectedChat = solicitud.chatEscalado }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)

                RHInsightsCard()
                    .padding(.horizontal, 20)

                RHActivityChart()
                    .padding(.horizontal, 20)
            }
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
        .background(Color.mabeBase)
        .sheet(isPresented: $showingDirectorio) {
            DirectorioEmpleadosSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .sheet(isPresented: $showingEvaluacion) {
            CargarEvaluacionSheet()
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
        .sheet(isPresented: $showingAlertas) {
            RHAlertsSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .sheet(item: $selectedChat) { chat in
            RHChatDetailSheet(chat: chat)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
    }
}

private struct RHHeroWidget: View {
    let empleado: Empleado
    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [Color(hex: "#92400E"), Color(hex: "#D97706")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            GeometryReader { geo in
                Circle().fill(.white.opacity(0.05)).frame(width: 160).offset(x: geo.size.width - 50, y: -50)
                Circle().fill(.white.opacity(0.04)).frame(width: 100).offset(x: geo.size.width, y: 60)
            }
            .clipped()
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                            Text("MODO ADMINISTRADOR")
                                .font(.mabeLabelSm)
                                .foregroundColor(.white.opacity(0.8))
                                .tracking(1)
                        }
                        Text(empleado.nombreCompleto)
                            .font(.mabeH3)
                            .foregroundColor(.white)
                        Text("\(empleado.puesto) · \(empleado.planta)")
                            .font(.mabeLabelMd)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    ZStack {
                        Circle().fill(.white.opacity(0.2)).frame(width: 42, height: 42)
                        Text(empleado.iniciales)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .overlay(Circle().strokeBorder(.white.opacity(0.4), lineWidth: 1.5))
                }

                Spacer()

                HStack(spacing: 0) {
                    miniStat(valor: "3", label: "Urgentes")
                    Divider().frame(height: 30).opacity(0.3)
                    miniStat(valor: "12", label: "Resueltos")
                    Divider().frame(height: 30).opacity(0.3)
                    miniStat(valor: "5", label: "En chat")
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(18)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
        }
        .frame(height: 170)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color(hex: "#D97706").opacity(0.35), radius: 20, x: 0, y: 8)
        .padding(.horizontal, 20)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                appeared = true
            }
        }
    }

    private func miniStat(valor: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(valor)
                .font(.mabeH3)
                .foregroundColor(.white)
            Text(label)
                .font(.mabeLabelSm)
                .foregroundColor(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct KPICard: View {
    let valor: Int
    let label: String
    let icon: String
    let accentColor: Color
    @State private var displayedValue: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(accentColor)
                    .frame(width: 34, height: 34)
                    .background(accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                Spacer()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(Int(displayedValue))")
                    .font(.mabeDisplaySm)
                    .foregroundColor(.mabeText1)
                    .contentTransition(.numericText(value: displayedValue))
                Text(label)
                    .font(.mabeLabelMd)
                    .foregroundColor(.mabeText3)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mabeSurface0)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.mabeBorder1, lineWidth: 0.5)
        }
        .mabeElevation(.low)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.2)) {
                displayedValue = Double(valor)
            }
        }
    }
}

private struct RHActivityChart: View {
    let data: [(dia: String, solicitudes: Int)] = [
        ("L", 8), ("M", 12), ("M", 6), ("J", 14), ("V", 10), ("S", 3), ("D", 1)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Solicitudes esta semana")
                .font(.mabeH3)
                .foregroundColor(.mabeText1)

            Chart(data, id: \.dia) { item in
                BarMark(
                    x: .value("Día", item.dia),
                    y: .value("Solicitudes", item.solicitudes)
                )
                .foregroundStyle(LinearGradient(
                    colors: [Color(hex: "#003087"), Color(hex: "#1976FF")],
                    startPoint: .bottom,
                    endPoint: .top
                ))
                .cornerRadius(6)
                .annotation(position: .top) {
                    if item.solicitudes > 10 {
                        Text("\(item.solicitudes)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "#003087"))
                    }
                }
            }
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let str = value.as(String.self) {
                            Text(str)
                                .font(.mabeLabelMd)
                                .foregroundColor(.mabeText3)
                        }
                    }
                }
            }
            .frame(height: 120)
        }
        .padding(16)
        .background(Color.mabeSurface0)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.mabeBorder1, lineWidth: 0.5)
        }
        .mabeElevation(.low)
    }
}

private struct RHSolicitudRow: View {
    let solicitud: SolicitudRH
    var onAprobar: (() -> Void)?
    var onRechazar: (() -> Void)?
    var onVerDetalle: (() -> Void)?
    @State private var showingAcciones = false

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                    showingAcciones.toggle()
                }
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(solicitud.urgencia == .alta ? Color(hex: "#F03E3E").opacity(0.1) : Color(hex: "#EFF3FA"))
                            .frame(width: 44, height: 44)
                        Text(solicitud.iniciales)
                            .font(.mabeLabelLg)
                            .foregroundColor(solicitud.urgencia == .alta ? Color(hex: "#F03E3E") : Color(hex: "#003087"))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(solicitud.empleadoNombre)
                            .font(.mabeLabelLg)
                            .foregroundColor(.mabeText1)
                        Text(solicitud.ultimoMensaje)
                            .font(.mabeBody)
                            .foregroundColor(.mabeText3)
                            .lineLimit(1)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(solicitud.tiempoRelativo)
                            .font(.mabeLabelSm)
                            .foregroundColor(.mabeText4)
                        if solicitud.urgencia == .alta {
                            PulsingDot(color: Color(hex: "#F03E3E"))
                        }
                    }

                    Image(systemName: showingAcciones ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.mabeText4)
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if showingAcciones {
                Divider().opacity(0.3).padding(.horizontal, 14)

                HStack(spacing: 8) {
                    Button {
                        onVerDetalle?()
                        showingAcciones = false
                    } label: {
                        Label("Ver chat", systemImage: "bubble.left.fill")
                            .font(.mabeLabelLg)
                            .foregroundColor(Color(hex: "#003087"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(Color(hex: "#EFF3FA"))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button {
                        withAnimation { showingAcciones = false }
                        onAprobar?()
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } label: {
                        Label("Resolver", systemImage: "checkmark")
                            .font(.mabeLabelLg)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(Color(hex: "#00875A"))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button {
                        withAnimation { showingAcciones = false }
                        onRechazar?()
                        UINotificationFeedbackGenerator().notificationOccurred(.warning)
                    } label: {
                        Label("Escalar", systemImage: "exclamationmark.triangle.fill")
                            .font(.mabeLabelLg)
                            .foregroundColor(Color(hex: "#C62828"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(Color(hex: "#FBEAEA"))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(Color.mabeSurface0)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    solicitud.urgencia == .alta ? Color(hex: "#F03E3E").opacity(0.3) : Color.mabeBorder1,
                    lineWidth: 1
                )
        }
        .shadow(color: Color(hex: "#0D1B3E").opacity(0.04), radius: 8, x: 0, y: 2)
        .animation(.spring(response: 0.3, dampingFraction: 0.82), value: showingAcciones)
    }
}

struct RHQuickActions: View {
    let onDirectorio: () -> Void
    let onEvaluacion: () -> Void
    let onInsights: () -> Void
    let onAlertas: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            rhQuickButton(icon: "person.2.fill", label: "Directorio", color: Color(hex: "#003087"), action: onDirectorio)
            rhQuickButton(icon: "chart.bar.fill", label: "Evaluación", color: Color(hex: "#00875A"), action: onEvaluacion)
            rhQuickButton(icon: "sparkles", label: "Insights IA", color: Color(hex: "#7C5CFC"), action: onInsights)
            rhQuickButton(icon: "bell.badge.fill", label: "Alertas", color: Color(hex: "#D97706"), action: onAlertas)
        }
    }

    private func rhQuickButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(color.opacity(0.10))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(color)
                }
                Text(label)
                    .font(.mabeLabelSm)
                    .foregroundColor(.mabeText2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

struct DirectorioEmpleadosSheet: View {
    @State private var busqueda = ""
    @Environment(\.dismiss) private var dismiss

    private var empleadosFiltrados: [Empleado] {
        let empleados = MockDataService.directorioEmpleados
        guard !busqueda.isEmpty else { return empleados }
        return empleados.filter {
            $0.nombreCompleto.localizedCaseInsensitiveContains(busqueda)
                || $0.id.localizedCaseInsensitiveContains(busqueda)
                || $0.departamento.localizedCaseInsensitiveContains(busqueda)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.mabeBorder1)
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            HStack {
                Text("Directorio")
                    .font(.mabeH2)
                    .foregroundColor(.mabeText1)
                Spacer()
                Button("Listo") { dismiss() }
                    .font(.mabeLabelLg)
                    .foregroundColor(Color(hex: "#003087"))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.mabeText3)
                    .font(.system(size: 15))
                TextField("Nombre, número o departamento", text: $busqueda)
                    .font(.mabeBody)
                if !busqueda.isEmpty {
                    Button { busqueda = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.mabeText4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.mabeSurface1)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            Divider().opacity(0.3)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(empleadosFiltrados) { empleado in
                        DirectorioEmpleadoRow(empleado: empleado)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
        .background(Color.mabeBase)
    }
}

struct DirectorioEmpleadoRow: View {
    let empleado: Empleado
    @State private var showingPerfil = false

    var body: some View {
        Button { showingPerfil = true } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color(hex: "#003087"), Color(hex: "#1976FF")], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 42, height: 42)
                    Text(empleado.iniciales)
                        .font(.mabeLabelLg)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(empleado.nombreCompleto)
                        .font(.mabeLabelLg)
                        .foregroundColor(.mabeText1)
                    Text("\(empleado.puesto) · \(empleado.departamento)")
                        .font(.mabeLabelMd)
                        .foregroundColor(.mabeText3)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Emp. \(empleado.id)")
                        .font(.mabeLabelSm)
                        .foregroundColor(.mabeText4)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.mabeText4)
                }
            }
            .padding(12)
            .background(Color.mabeSurface0)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.mabeBorder1, lineWidth: 0.5)
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingPerfil) {
            PerfilEmpleadoView(empleado: empleado)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
    }
}

struct CargarEvaluacionSheet: View {
    @Environment(RewardService.self) private var rewardService
    @Environment(\.dismiss) private var dismiss
    @State private var empleadoSeleccionado: Empleado?
    @State private var porcentaje: Double = 80
    @State private var periodo = "Q2/2026"
    @State private var isLoading = false
    @State private var enviado = false

    private var puntosAOtorgar: Int {
        if porcentaje >= 90 { return 500 }
        if porcentaje >= 75 { return 300 }
        return 100
    }

    private var categoriaColor: Color {
        if porcentaje >= 90 { return Color(hex: "#00875A") }
        if porcentaje >= 75 { return Color(hex: "#D97706") }
        return Color(hex: "#9AA5BE")
    }

    private var categoriaLabel: String {
        if porcentaje >= 90 { return "Excelente" }
        if porcentaje >= 75 { return "Buena" }
        return "Satisfactoria"
    }

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.mabeBorder1)
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            if enviado {
                successView
            } else {
                formView
            }
        }
        .background(Color.mabeBase)
    }

    private var successView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(Color(hex: "#00875A"))
            Text("Evaluación cargada")
                .font(.mabeH2)
                .foregroundColor(.mabeText1)
            Text("\(empleadoSeleccionado?.nombre ?? "Empleado") recibió \(puntosAOtorgar) puntos por su evaluación \(categoriaLabel.lowercased()) del \(periodo)")
                .font(.mabeBody)
                .foregroundColor(.mabeText2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            Spacer()
            Button("Listo") { dismiss() }
                .font(.mabeLabelLg)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color(hex: "#00875A"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
        }
    }

    private var formView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Cargar evaluación")
                        .font(.mabeH2)
                        .foregroundColor(.mabeText1)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                    empleadoSelector
                    periodoSelector
                    calificacionSection
                }
                .padding(.bottom, 20)
            }

            Button {
                guard empleadoSeleccionado != nil else { return }
                isLoading = true
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(700))
                    rewardService.cargarEvaluacionCuatrimestral(porcentaje: Int(porcentaje))
                    isLoading = false
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                        enviado = true
                    }
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            } label: {
                Group {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(empleadoSeleccionado == nil ? "Selecciona un empleado" : "Cargar evaluación")
                    }
                }
                .font(.mabeLabelLg)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(empleadoSeleccionado == nil ? Color.mabeText4 : Color(hex: "#00875A"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .disabled(empleadoSeleccionado == nil || isLoading)
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }

    private var empleadoSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Empleado")
                .font(.mabeLabelLg)
                .foregroundColor(.mabeText2)
                .padding(.horizontal, 20)

            if let empleado = empleadoSeleccionado {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(hex: "#003087"))
                        .frame(width: 38, height: 38)
                        .overlay {
                            Text(empleado.iniciales)
                                .font(.mabeLabelLg)
                                .foregroundColor(.white)
                        }
                    VStack(alignment: .leading, spacing: 1) {
                        Text(empleado.nombreCompleto)
                            .font(.mabeLabelLg)
                            .foregroundColor(.mabeText1)
                        Text(empleado.puesto)
                            .font(.mabeLabelMd)
                            .foregroundColor(.mabeText3)
                    }
                    Spacer()
                    Button { empleadoSeleccionado = nil } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.mabeText4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .background(Color.mabeSurface0)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.mabeBorder1, lineWidth: 0.5)
                }
                .padding(.horizontal, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(MockDataService.directorioEmpleados) { empleado in
                            Button { empleadoSeleccionado = empleado } label: {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Color(hex: "#003087").opacity(0.1))
                                        .frame(width: 30, height: 30)
                                        .overlay {
                                            Text(empleado.iniciales)
                                                .font(.mabeLabelSm)
                                                .foregroundColor(Color(hex: "#003087"))
                                        }
                                    Text(empleado.nombre)
                                        .font(.mabeLabelLg)
                                        .foregroundColor(.mabeText1)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.mabeSurface0)
                                .clipShape(Capsule())
                                .overlay(Capsule().strokeBorder(Color.mabeBorder1, lineWidth: 0.5))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    private var periodoSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Periodo")
                .font(.mabeLabelLg)
                .foregroundColor(.mabeText2)
            HStack(spacing: 8) {
                ForEach(["Q1/2026", "Q2/2026", "Q3/2026"], id: \.self) { item in
                    Button { periodo = item } label: {
                        Text(item)
                            .font(.mabeLabelLg)
                            .foregroundColor(periodo == item ? .white : .mabeText1)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(periodo == item ? Color(hex: "#003087") : Color.mabeSurface1)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var calificacionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Calificación")
                .font(.mabeLabelLg)
                .foregroundColor(.mabeText2)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(Int(porcentaje))")
                    .font(.mabeDisplay)
                    .foregroundColor(categoriaColor)
                    .contentTransition(.numericText(value: porcentaje))
                Text("%")
                    .font(.mabeH2)
                    .foregroundColor(categoriaColor)
                Spacer()
                Text(categoriaLabel)
                    .font(.mabeLabelLg)
                    .foregroundColor(categoriaColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(categoriaColor.opacity(0.1))
                    .clipShape(Capsule())
            }

            Slider(value: $porcentaje, in: 50...100, step: 1)
                .tint(categoriaColor)

            HStack {
                Text("50%").font(.mabeLabelSm).foregroundColor(.mabeText4)
                Spacer()
                Text("100%").font(.mabeLabelSm).foregroundColor(.mabeText4)
            }

            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#D97706"))
                Text("Otorgará")
                    .font(.mabeLabelLg)
                    .foregroundColor(.mabeText2)
                Text("+\(puntosAOtorgar) puntos")
                    .font(.mabeH3)
                    .foregroundColor(Color(hex: "#D97706"))
                Spacer()
            }
            .padding(12)
            .background(Color(hex: "#FAEEDA"))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(.horizontal, 20)
    }
}

private struct RHInsightsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Insights IA", systemImage: "sparkles")
                    .font(.mabeH3)
                    .foregroundColor(.mabeText1)
                Spacer()
                Text("Hoy")
                    .font(.mabeLabelSm)
                    .foregroundColor(.mabeText3)
            }

            VStack(alignment: .leading, spacing: 8) {
                insightRow("Aumentaron las consultas sobre nómina en Línea A", color: Color(hex: "#D97706"))
                insightRow("Bienestar estable: 82% de check-ins positivos", color: Color(hex: "#00875A"))
                insightRow("2 solicitudes requieren seguimiento antes del cierre", color: Color(hex: "#F03E3E"))
            }
        }
        .padding(16)
        .background(Color.mabeSurface0)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.mabeBorder1, lineWidth: 0.5)
        }
        .mabeElevation(.low)
    }

    private func insightRow(_ text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
                .padding(.top, 6)
            Text(text)
                .font(.mabeBody)
                .foregroundColor(.mabeText2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct RHInsightsFullSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.mabeBorder1)
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            HStack {
                Text("Insights IA")
                    .font(.mabeH2)
                    .foregroundColor(.mabeText1)
                Spacer()
                Button("Listo") { dismiss() }
                    .font(.mabeLabelLg)
                    .foregroundColor(Color(hex: "#003087"))
            }
            .padding(20)

            ScrollView {
                VStack(spacing: 12) {
                    RHInsightsCard()
                    RHActivityChart()
                }
                .padding(20)
            }
        }
        .background(Color.mabeBase)
    }
}

struct RHSolicitudesPendientesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var solicitudes = MockDataService.solicitudesUrgentes
    @State private var resueltas: [SolicitudRH] = []
    @State private var selectedChat: ChatEscalado?

    var body: some View {
        VStack(spacing: 0) {
            SheetHandle()

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Solicitudes pendientes")
                        .font(.mabeH2)
                        .foregroundColor(.mabeText1)
                    Text("\(solicitudes.count) abiertas · \(resueltas.count) resueltas")
                        .font(.mabeLabelMd)
                        .foregroundColor(.mabeText3)
                }
                Spacer()
                Button("Listo") { dismiss() }
                    .font(.mabeLabelLg)
                    .foregroundColor(Color(hex: "#003087"))
            }
            .padding(20)

            ScrollView {
                LazyVStack(spacing: 10) {
                    if solicitudes.isEmpty {
                        RHEmptyState(
                            icon: "checkmark.circle.fill",
                            title: "Todo al día",
                            subtitle: "No quedan solicitudes pendientes por revisar.",
                            color: Color(hex: "#00875A")
                        )
                    } else {
                        ForEach(solicitudes) { solicitud in
                            RHSolicitudRow(
                                solicitud: solicitud,
                                onAprobar: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                        resueltas.append(solicitud)
                                        solicitudes.removeAll { $0.id == solicitud.id }
                                    }
                                },
                                onRechazar: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                        guard let index = solicitudes.firstIndex(where: { $0.id == solicitud.id }) else { return }
                                        solicitudes[index] = SolicitudRH(
                                            id: solicitud.id,
                                            empleadoNombre: solicitud.empleadoNombre,
                                            empleadoId: solicitud.empleadoId,
                                            ultimoMensaje: "Escalado - \(solicitud.ultimoMensaje)",
                                            urgencia: .alta,
                                            tiempoRelativo: "ahora"
                                        )
                                    }
                                },
                                onVerDetalle: { selectedChat = solicitud.chatEscalado }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .background(Color.mabeBase)
        .sheet(item: $selectedChat) { chat in
            RHChatDetailSheet(chat: chat)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
    }
}

struct RHAlertsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var alerts: [RHAlertItem] = RHAlertItem.demo

    var body: some View {
        VStack(spacing: 0) {
            SheetHandle()

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Alertas")
                        .font(.mabeH2)
                        .foregroundColor(.mabeText1)
                    Text("\(alerts.filter { !$0.isRead }.count) requieren seguimiento")
                        .font(.mabeLabelMd)
                        .foregroundColor(.mabeText3)
                }
                Spacer()
                Button("Listo") { dismiss() }
                    .font(.mabeLabelLg)
                    .foregroundColor(Color(hex: "#003087"))
            }
            .padding(20)

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(alerts) { alert in
                        HStack(alignment: .top, spacing: 12) {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(alert.color.opacity(0.12))
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Image(systemName: alert.icon)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(alert.color)
                                }

                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(alert.title)
                                        .font(.mabeLabelLg)
                                        .foregroundColor(.mabeText1)
                                    if !alert.isRead {
                                        Circle()
                                            .fill(alert.color)
                                            .frame(width: 7, height: 7)
                                    }
                                }
                                Text(alert.detail)
                                    .font(.mabeBody)
                                    .foregroundColor(.mabeText2)
                                    .fixedSize(horizontal: false, vertical: true)
                                Button(alert.isRead ? "Atendida" : "Marcar atendida") {
                                    guard let index = alerts.firstIndex(where: { $0.id == alert.id }) else { return }
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                                        alerts[index].isRead = true
                                    }
                                }
                                .font(.mabeLabelLg)
                                .foregroundColor(alert.isRead ? .mabeText4 : alert.color)
                                .disabled(alert.isRead)
                                .buttonStyle(.plain)
                                .padding(.top, 3)
                            }

                            Spacer()
                        }
                        .padding(14)
                        .background(Color.mabeSurface0)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(alert.isRead ? Color.mabeBorder1 : alert.color.opacity(0.25), lineWidth: 0.8)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .background(Color.mabeBase)
    }
}

struct RHWellbeingReportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var departamento = "Todos"

    private let departamentos = ["Todos", "Línea A", "Línea B", "Control de Calidad", "Mantenimiento"]
    private let rows: [WellbeingReportRow] = [
        .init(area: "Línea A", positivos: 78, tendencia: "Bajó 4%", color: Color(hex: "#D97706")),
        .init(area: "Línea B", positivos: 86, tendencia: "Subió 3%", color: Color(hex: "#00875A")),
        .init(area: "Control de Calidad", positivos: 91, tendencia: "Estable", color: Color(hex: "#00875A")),
        .init(area: "Mantenimiento", positivos: 74, tendencia: "Revisar carga", color: Color(hex: "#F03E3E")),
    ]

    private var filteredRows: [WellbeingReportRow] {
        departamento == "Todos" ? rows : rows.filter { $0.area == departamento }
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHandle()

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Reporte de bienestar")
                        .font(.mabeH2)
                        .foregroundColor(.mabeText1)
                    Text("Check-ins agregados del equipo")
                        .font(.mabeLabelMd)
                        .foregroundColor(.mabeText3)
                }
                Spacer()
                Button("Listo") { dismiss() }
                    .font(.mabeLabelLg)
                    .foregroundColor(Color(hex: "#003087"))
            }
            .padding(20)

            Picker("Departamento", selection: $departamento) {
                ForEach(departamentos, id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(.menu)
            .tint(Color(hex: "#003087"))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            ScrollView {
                VStack(spacing: 12) {
                    HStack(spacing: 10) {
                        reportMetric("82%", "positivos", Color(hex: "#00875A"))
                        reportMetric("11%", "cansancio", Color(hex: "#D97706"))
                        reportMetric("7%", "difícil", Color(hex: "#F03E3E"))
                    }

                    ForEach(filteredRows) { row in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(row.area)
                                    .font(.mabeLabelLg)
                                    .foregroundColor(.mabeText1)
                                Spacer()
                                Text(row.tendencia)
                                    .font(.mabeLabelMd)
                                    .foregroundColor(row.color)
                            }

                            ProgressView(value: Double(row.positivos), total: 100)
                                .tint(row.color)

                            Text("\(row.positivos)% de check-ins positivos esta semana")
                                .font(.mabeLabelMd)
                                .foregroundColor(.mabeText3)
                        }
                        .padding(14)
                        .background(Color.mabeSurface0)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.mabeBorder1, lineWidth: 0.5)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .background(Color.mabeBase)
    }

    private func reportMetric(_ value: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.mabeH2)
                .foregroundColor(color)
            Text(label)
                .font(.mabeLabelSm)
                .foregroundColor(.mabeText3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.mabeSurface0)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.mabeBorder1, lineWidth: 0.5)
        }
    }
}

struct RHRankingRecompensasSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var periodo = "Mes"
    @State private var recognizedIDs: Set<String> = []

    private let periodos = ["Semana", "Mes", "Cuatrimestre"]
    private let ranking: [RankingRewardRow] = [
        .init(employee: MockDataService.directorioEmpleados[2], points: 1840, tier: .oro),
        .init(employee: MockDataService.directorioEmpleados[4], points: 1210, tier: .plata),
        .init(employee: MockDataService.directorioEmpleados[1], points: 980, tier: .plata),
        .init(employee: MockDataService.directorioEmpleados[3], points: 720, tier: .plata),
        .init(employee: MockDataService.directorioEmpleados[0], points: 540, tier: .bronce),
    ]

    var body: some View {
        VStack(spacing: 0) {
            SheetHandle()

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ranking de recompensas")
                        .font(.mabeH2)
                        .foregroundColor(.mabeText1)
                    Text("Reconoce participación y desempeño")
                        .font(.mabeLabelMd)
                        .foregroundColor(.mabeText3)
                }
                Spacer()
                Button("Listo") { dismiss() }
                    .font(.mabeLabelLg)
                    .foregroundColor(Color(hex: "#003087"))
            }
            .padding(20)

            Picker("Periodo", selection: $periodo) {
                ForEach(periodos, id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 10) {
                    ForEach(ranking.indices, id: \.self) { index in
                        let item = ranking[index]
                        HStack(spacing: 12) {
                            Text("#\(index + 1)")
                                .font(.mabeH3)
                                .foregroundColor(index == 0 ? Color(hex: "#D97706") : .mabeText3)
                                .frame(width: 34)

                            Circle()
                                .fill(item.tier.backgroundColor)
                                .frame(width: 42, height: 42)
                                .overlay {
                                    Text(item.employee.iniciales)
                                        .font(.mabeLabelLg)
                                        .foregroundColor(item.tier.color)
                                }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.employee.nombreCompleto)
                                    .font(.mabeLabelLg)
                                    .foregroundColor(.mabeText1)
                                Text("\(item.tier.emoji) \(item.tier.nombre) · \(item.points) pts")
                                    .font(.mabeLabelMd)
                                    .foregroundColor(.mabeText3)
                            }

                            Spacer()

                            Button(recognizedIDs.contains(item.employee.id) ? "Reconocido" : "Reconocer") {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                                    _ = recognizedIDs.insert(item.employee.id)
                                }
                            }
                            .font(.mabeLabelSm)
                            .foregroundColor(recognizedIDs.contains(item.employee.id) ? .mabeText4 : Color(hex: "#D97706"))
                            .disabled(recognizedIDs.contains(item.employee.id))
                            .buttonStyle(.plain)
                        }
                        .padding(12)
                        .background(Color.mabeSurface0)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.mabeBorder1, lineWidth: 0.5)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .background(Color.mabeBase)
    }
}

struct RHPreferencesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("rh.pref.urgentPush") private var urgentPush = true
    @AppStorage("rh.pref.dailyDigest") private var dailyDigest = true
    @AppStorage("rh.pref.autoEscalation") private var autoEscalation = false
    @AppStorage("rh.pref.compactDashboard") private var compactDashboard = false

    var body: some View {
        VStack(spacing: 0) {
            SheetHandle()

            HStack {
                Text("Preferencias RH")
                    .font(.mabeH2)
                    .foregroundColor(.mabeText1)
                Spacer()
                Button("Listo") { dismiss() }
                    .font(.mabeLabelLg)
                    .foregroundColor(Color(hex: "#003087"))
            }
            .padding(20)

            VStack(spacing: 0) {
                preferenceToggle("Alertas urgentes", "Notificar casos de nómina, permisos y bienestar crítico.", isOn: $urgentPush)
                preferenceToggle("Resumen diario", "Enviar corte diario de solicitudes y chats activos.", isOn: $dailyDigest)
                preferenceToggle("Escalamiento automático", "Marcar como urgente si una solicitud pasa 24 horas sin respuesta.", isOn: $autoEscalation)
                preferenceToggle("Dashboard compacto", "Reducir altura de métricas para revisión rápida.", isOn: $compactDashboard)
            }
            .background(Color.mabeSurface0)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.mabeBorder1, lineWidth: 0.5)
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .background(Color.mabeBase)
    }

    private func preferenceToggle(_ title: String, _ subtitle: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.mabeLabelLg)
                    .foregroundColor(.mabeText1)
                Text(subtitle)
                    .font(.mabeLabelMd)
                    .foregroundColor(.mabeText3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .tint(Color(hex: "#003087"))
        .padding(14)
    }
}

struct RHChatDetailSheet: View {
    let chat: ChatEscalado
    @Environment(\.dismiss) private var dismiss
    @State private var respuesta = ""
    @State private var resuelto = false
    @State private var mensajes: [RHChatMessage] = []

    var body: some View {
        VStack(spacing: 0) {
            SheetHandle()

            HStack(spacing: 12) {
                Circle()
                    .fill(chat.urgencia == .alta ? Color(hex: "#F03E3E").opacity(0.12) : Color(hex: "#003087").opacity(0.10))
                    .frame(width: 42, height: 42)
                    .overlay {
                        Text(chat.iniciales)
                            .font(.mabeLabelLg)
                            .foregroundColor(chat.urgencia == .alta ? Color(hex: "#F03E3E") : Color(hex: "#003087"))
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(chat.empleadoNombre)
                        .font(.mabeH3)
                        .foregroundColor(.mabeText1)
                    Text(chat.urgencia.rawValue)
                        .font(.mabeLabelMd)
                        .foregroundColor(chat.urgencia == .alta ? Color(hex: "#F03E3E") : .mabeText3)
                }

                Spacer()

                Button("Listo") { dismiss() }
                    .font(.mabeLabelLg)
                    .foregroundColor(Color(hex: "#003087"))
            }
            .padding(20)

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(mensajes) { mensaje in
                        HStack {
                            if mensaje.isRH { Spacer(minLength: 40) }
                            Text(mensaje.text)
                                .font(.mabeBody)
                                .foregroundColor(mensaje.isRH ? .white : .mabeText1)
                                .padding(12)
                                .background(mensaje.isRH ? Color(hex: "#003087") : Color.mabeSurface0)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay {
                                    if !mensaje.isRH {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .strokeBorder(Color.mabeBorder1, lineWidth: 0.5)
                                    }
                                }
                            if !mensaje.isRH { Spacer(minLength: 40) }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }

            VStack(spacing: 10) {
                if resuelto {
                    Label("Chat marcado como resuelto", systemImage: "checkmark.circle.fill")
                        .font(.mabeLabelLg)
                        .foregroundColor(Color(hex: "#00875A"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                HStack(spacing: 8) {
                    TextField("Responder al empleado", text: $respuesta, axis: .vertical)
                        .font(.mabeBody)
                        .lineLimit(1...4)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.mabeSurface1)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    Button {
                        sendReply()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 42, height: 42)
                            .background(respuesta.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.mabeText4 : Color(hex: "#003087"))
                            .clipShape(Circle())
                    }
                    .disabled(respuesta.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(.plain)
                }

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                        resuelto = true
                    }
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } label: {
                    Label("Marcar resuelto", systemImage: "checkmark")
                        .font(.mabeLabelLg)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(Color(hex: "#00875A"))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(resuelto)
                .opacity(resuelto ? 0.55 : 1)
                .buttonStyle(.plain)
            }
            .padding(20)
            .background(Color.mabeBase)
        }
        .background(Color.mabeBase)
        .onAppear {
            guard mensajes.isEmpty else { return }
            mensajes = [
                RHChatMessage(text: chat.ultimoMensaje, isRH: false),
                RHChatMessage(text: "Hola, soy Laura de RH. Ya estoy revisando tu caso.", isRH: true),
            ]
        }
    }

    private func sendReply() {
        let clean = respuesta.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
            mensajes.append(RHChatMessage(text: clean, isRH: true))
            respuesta = ""
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

private struct SheetHandle: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.mabeBorder1)
            .frame(width: 40, height: 5)
            .padding(.top, 12)
    }
}

private struct RHEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 38))
                .foregroundColor(color)
            Text(title)
                .font(.mabeH3)
                .foregroundColor(.mabeText1)
            Text(subtitle)
                .font(.mabeLabelLg)
                .foregroundColor(.mabeText3)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .background(Color.mabeSurface0)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct RHAlertItem: Identifiable {
    let id: String
    let title: String
    let detail: String
    let icon: String
    let color: Color
    var isRead: Bool

    static let demo: [RHAlertItem] = [
        RHAlertItem(id: "nomina", title: "Nómina en Línea A", detail: "3 empleados reportaron dudas sobre descuentos esta mañana.", icon: "exclamationmark.triangle.fill", color: Color(hex: "#D97706"), isRead: false),
        RHAlertItem(id: "permiso", title: "Permiso urgente", detail: "Roberto Sosa solicitó seguimiento por enfermedad familiar.", icon: "heart.text.square.fill", color: Color(hex: "#F03E3E"), isRead: false),
        RHAlertItem(id: "bienestar", title: "Bienestar estable", detail: "Control de Calidad se mantiene arriba de 90% positivo.", icon: "chart.line.uptrend.xyaxis", color: Color(hex: "#00875A"), isRead: true),
    ]
}

private struct WellbeingReportRow: Identifiable {
    let id = UUID()
    let area: String
    let positivos: Int
    let tendencia: String
    let color: Color
}

private struct RankingRewardRow {
    let employee: Empleado
    let points: Int
    let tier: RewardTier
}

private struct RHChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isRH: Bool
}

private extension SolicitudRH {
    var chatEscalado: ChatEscalado {
        ChatEscalado(
            empleadoNombre: empleadoNombre,
            empleadoId: empleadoId,
            ultimoMensaje: ultimoMensaje,
            fecha: Date(),
            urgencia: urgencia == .alta ? .alta : .normal
        )
    }
}
