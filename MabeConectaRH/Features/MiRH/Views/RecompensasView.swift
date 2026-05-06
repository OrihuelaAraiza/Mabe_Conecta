import SwiftUI

struct RecompensasView: View {
    @Environment(RewardService.self) private var rewardService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    private var profile: RewardProfile { rewardService.profile }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 16) {
                    TierCardPrincipal(profile: profile)
                        .padding(.horizontal, 20)

                    ProximaRecompensaCard(profile: profile)
                        .padding(.horizontal, 20)

                    RewardSegmentedControl(
                        options: ["Cómo ganar", "Historial", "Logros"],
                        selected: $selectedTab
                    )
                    .padding(.horizontal, 20)

                    Group {
                        switch selectedTab {
                        case 0:
                            ComoGanarSection()
                        case 1:
                            HistorialSection(eventos: profile.eventos)
                        default:
                            LogrosSection(desbloqueados: profile.logrosDesbloqueados)
                        }
                    }
                    .padding(.horizontal, 20)
                    .transition(.opacity)
                }
                .padding(.top, 16)
                .padding(.bottom, 100)
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
            }
        }
        .navigationBarHidden(true)
        .background(Color.mabeBase)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.mabePrimary)
                    .frame(width: 34, height: 34)
                    .background(Color.mabeSurface0)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Text("Mis Recompensas")
                .font(.mabeH2)
                .foregroundColor(.mabeText1)

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 11))
                Text("\(profile.puntosDisponibles)")
                    .font(.mabeLabelLg)
            }
            .foregroundColor(Color(hex: "#D97706"))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(hex: "#FAEEDA"))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.mabeBase)
    }
}

private struct RewardSegmentedControl: View {
    let options: [String]
    @Binding var selected: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(options.indices, id: \.self) { index in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selected = index
                    }
                    Haptics.impact(.light)
                } label: {
                    Text(options[index])
                        .font(.mabeLabelMd)
                        .foregroundColor(selected == index ? .white : .mabeText2)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(selected == index ? Color.mabePrimary : Color.clear)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.mabeSurface2)
        .clipShape(Capsule())
    }
}

private struct TierCardPrincipal: View {
    let profile: RewardProfile
    @State private var progressAnimated: Double = 0
    @State private var appeared = false

    private var tier: RewardTier { profile.tier }

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [tier.color, tier.color.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            MabeIndustrialPattern(opacity: 0.08, color: .white)

            Text(tier.emoji)
                .font(.system(size: 100))
                .opacity(0.1)
                .offset(x: 220, y: -20)

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    HStack(spacing: 6) {
                        Text(tier.emoji)
                            .font(.system(size: 20))
                        Text(tier.nombre.uppercased())
                            .font(.mabeLabelLg)
                            .foregroundColor(.white)
                            .tracking(1)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())

                    Spacer()

                    VStack(alignment: .trailing, spacing: 1) {
                        Text("×\(tier.multiplicador, specifier: "%.2g")")
                            .font(.mabeDisplaySm)
                            .foregroundColor(.white)
                        Text("en puntos de app")
                            .font(.mabeLabelSm)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(profile.puntosAcumulados)")
                        .font(.mabeDisplay)
                        .foregroundColor(.white)
                        .contentTransition(.numericText(value: Double(profile.puntosAcumulados)))
                    Text("pts totales")
                        .font(.mabeLabelMd)
                        .foregroundColor(.white.opacity(0.7))
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 8)

                if tier != .platino {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Siguiente: \(tier.next.nombre) \(tier.next.emoji)")
                                .font(.mabeLabelMd)
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text("\(profile.puntosParaSiguienteTier) pts más")
                                .font(.mabeLabelMd)
                                .foregroundColor(.white.opacity(0.8))
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(.white.opacity(0.2))
                                    .frame(height: 8)

                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(.white)
                                    .frame(width: geo.size.width * progressAnimated, height: 8)
                            }
                        }
                        .frame(height: 8)
                    }
                    .opacity(appeared ? 1 : 0)
                }
            }
            .padding(20)
        }
        .frame(height: tier == .platino ? 160 : 200)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: tier.color.opacity(0.35), radius: 20, x: 0, y: 8)
        .onAppear {
            withAnimation(.spring(response: 0.6)) {
                appeared = true
            }
            withAnimation(.spring(response: 1.2, dampingFraction: 0.8).delay(0.25)) {
                progressAnimated = profile.progresoSiguienteTier
            }
        }
        .onChange(of: profile.progresoSiguienteTier) { _, newValue in
            withAnimation(.spring(response: 1.0, dampingFraction: 0.85)) {
                progressAnimated = newValue
            }
        }
    }
}

private struct ProximaRecompensaCard: View {
    let profile: RewardProfile

    private var accionSugerida: (titulo: String, puntos: Int, icon: String, color: Color) {
        let hizoCheckinHoy = profile.fechaUltimoCheckin.map { Calendar.current.isDateInToday($0) } ?? false

        if !hizoCheckinHoy {
            return (
                "Haz tu check-in de bienestar de hoy",
                Int((10 * profile.tier.multiplicador).rounded()),
                "face.smiling.fill",
                Color(hex: "#7C5CFC")
            )
        }

        let rachaFaltante = 7 - (profile.rachaActual % 7)
        if rachaFaltante <= 2 {
            return (
                "Faltan \(rachaFaltante) días para bono de racha",
                50,
                "flame.fill",
                Color(hex: "#D97706")
            )
        }

        return (
            "Explora y canjea un cupón",
            Int((15 * profile.tier.multiplicador).rounded()),
            "ticket.fill",
            Color(hex: "#EC4899")
        )
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(accionSugerida.color.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: accionSugerida.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(accionSugerida.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Gana puntos ahora")
                    .font(.mabeLabelSm)
                    .foregroundColor(.mabeText3)
                    .tracking(0.4)
                Text(accionSugerida.titulo)
                    .font(.mabeLabelLg)
                    .foregroundColor(.mabeText1)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                    Text("+\(accionSugerida.puntos)")
                        .font(.mabeH3)
                }
                .foregroundColor(Color(hex: "#D97706"))

                if profile.tier.multiplicador > 1 {
                    Text("×\(profile.tier.multiplicador, specifier: "%.2g")")
                        .font(.mabeLabelSm)
                        .foregroundColor(profile.tier.color)
                }
            }
        }
        .padding(16)
        .background(Color.mabeSurface0)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(accionSugerida.color.opacity(0.2), lineWidth: 1)
        }
        .mabeElevation(.low)
    }
}

private struct ComoGanarSection: View {
    private let accionesApp: [(titulo: String, pts: Int, icon: String)] = [
        ("Check-in de bienestar diario", 10, "face.smiling.fill"),
        ("Racha de 7 días", 50, "flame.fill"),
        ("Solicitud completada", 25, "checkmark.circle.fill"),
        ("Cupón canjeado", 15, "ticket.fill"),
        ("Primera consulta al asistente diaria", 5, "bubble.left.fill"),
        ("Completar onboarding", 50, "sparkles")
    ]

    private let accionesDesempeno: [(titulo: String, pts: Int, icon: String)] = [
        ("Evaluación Excelente (90-100%)", 500, "star.fill"),
        ("Evaluación Buena (75-89%)", 300, "chart.bar.fill"),
        ("Asistencia perfecta cuatrimestral", 200, "calendar.badge.checkmark"),
        ("Capacitación completada", 75, "graduationcap.fill"),
        ("Reconocimiento de pares o supervisor", 30, "hand.thumbsup.fill")
    ]

    var body: some View {
        VStack(spacing: 12) {
            rewardGroupHeader(icon: "iphone", title: "USANDO LA APP", color: .mabePrimary)

            ForEach(accionesApp, id: \.titulo) { accion in
                GanarRow(accion: accion, esApp: true)
            }

            Divider().opacity(0.3).padding(.vertical, 4)

            rewardGroupHeader(icon: "chart.bar.fill", title: "DESEMPEÑO CUATRIMESTRAL", color: Color(hex: "#00875A"))

            Text("Cargado por RH al cierre de cada cuatrimestre: abril, agosto y diciembre.")
                .font(.mabeLabelMd)
                .foregroundColor(.mabeText3)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(accionesDesempeno, id: \.titulo) { accion in
                GanarRow(accion: accion, esApp: false)
            }

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.mabeText3)
                Text("Los puntos de app se multiplican según tu tier. Los puntos de desempeño conservan su valor base.")
                    .font(.mabeLabelMd)
                    .foregroundColor(.mabeText3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .background(Color.mabeSurface1)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private func rewardGroupHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            Text(title)
                .font(.mabeLabelSm)
                .tracking(0.6)
        }
        .foregroundColor(color)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct GanarRow: View {
    let accion: (titulo: String, pts: Int, icon: String)
    let esApp: Bool

    private var color: Color {
        esApp ? Color.mabePrimary : Color(hex: "#00875A")
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(color.opacity(0.1))
                    .frame(width: 34, height: 34)
                Image(systemName: accion.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }

            Text(accion.titulo)
                .font(.mabeBody)
                .foregroundColor(.mabeText1)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .font(.system(size: 9))
                Text("+\(accion.pts)")
                    .font(.mabeLabelLg)
            }
            .foregroundColor(Color(hex: "#D97706"))
        }
        .padding(10)
        .background(Color.mabeSurface0)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.mabeBorder1, lineWidth: 0.5)
        }
    }
}

private struct HistorialSection: View {
    let eventos: [RewardEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if eventos.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "star.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.mabeText4)
                    Text("Aún no tienes actividad de recompensas")
                        .font(.mabeLabelLg)
                        .foregroundColor(.mabeText3)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(eventos.prefix(20)) { evento in
                    HistorialRow(evento: evento)
                }
            }
        }
    }
}

private struct HistorialRow: View {
    let evento: RewardEvent

    private var color: Color {
        evento.fuente == .desempeno ? Color(hex: "#00875A") : Color.mabePrimary
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: evento.tipo.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(evento.descripcion)
                    .font(.mabeLabelLg)
                    .foregroundColor(.mabeText1)
                    .lineLimit(2)
                HStack(spacing: 6) {
                    Text(evento.fecha.formatted(.relative(presentation: .named)))
                        .font(.mabeLabelMd)
                        .foregroundColor(.mabeText3)
                    if evento.fuente == .desempeno {
                        Text("· Desempeño")
                            .font(.mabeLabelMd)
                            .foregroundColor(Color(hex: "#00875A"))
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                    Text("+\(evento.puntosFinales)")
                        .font(.mabeH3)
                }
                .foregroundColor(Color(hex: "#D97706"))

                if evento.puntos != evento.puntosFinales {
                    Text("base: \(evento.puntos)")
                        .font(.mabeLabelSm)
                        .foregroundColor(.mabeText4)
                }
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
}

private struct LogrosSection: View {
    let desbloqueados: Set<String>
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("\(desbloqueados.count) de \(LogrosCatalogo.todos.count) desbloqueados")
                .font(.mabeLabelLg)
                .foregroundColor(.mabeText2)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(LogrosCatalogo.todos) { logro in
                    LogroBadge(logro: logro, desbloqueado: desbloqueados.contains(logro.id))
                }
            }
        }
    }
}

private struct LogroBadge: View {
    let logro: Logro
    let desbloqueado: Bool
    @State private var showDetail = false

    var body: some View {
        Button {
            showDetail = true
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(desbloqueado ? logro.color.opacity(0.12) : Color.mabeSurface1)
                        .frame(width: 56, height: 56)
                        .overlay {
                            Circle()
                                .strokeBorder(desbloqueado ? logro.color.opacity(0.3) : Color.mabeBorder1, lineWidth: 1)
                        }

                    Image(systemName: logro.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(desbloqueado ? logro.color : Color.mabeText4)
                        .opacity(desbloqueado ? 1 : 0.45)
                }

                Text(logro.nombre)
                    .font(.mabeLabelSm)
                    .foregroundColor(desbloqueado ? .mabeText1 : .mabeText4)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(logro.rareza.rawValue)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(desbloqueado ? logro.rareza.color : Color.mabeText4)
            }
            .padding(8)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetail) {
            LogroDetailSheet(logro: logro, desbloqueado: desbloqueado)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
    }
}

private struct LogroDetailSheet: View {
    let logro: Logro
    let desbloqueado: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 18) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.mabeBorder2)
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            ZStack {
                Circle()
                    .fill((desbloqueado ? logro.color : Color.mabeText4).opacity(0.12))
                    .frame(width: 90, height: 90)
                Image(systemName: logro.icon)
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundColor(desbloqueado ? logro.color : Color.mabeText4)
            }

            VStack(spacing: 6) {
                Text(logro.nombre)
                    .font(.mabeH2)
                    .foregroundColor(.mabeText1)
                Text(logro.descripcion)
                    .font(.mabeBody)
                    .foregroundColor(.mabeText2)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)

            Text(desbloqueado ? "Desbloqueado" : "Aún bloqueado")
                .font(.mabeLabelLg)
                .foregroundColor(desbloqueado ? logro.color : Color.mabeText3)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background((desbloqueado ? logro.color : Color.mabeText4).opacity(0.1))
                .clipShape(Capsule())

            Spacer()

            Button("Cerrar") {
                dismiss()
            }
            .font(.mabeLabelLg)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.mabePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }
}

struct PuntosToast: View {
    let evento: RewardEvent
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#D97706").opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: evento.tipo.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "#D97706"))
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(evento.descripcion)
                    .font(.mabeLabelLg)
                    .foregroundColor(.mabeText1)
                    .lineLimit(1)
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                    Text("+\(evento.puntosFinales) puntos")
                        .font(.mabeLabelMd)
                    if evento.puntos != evento.puntosFinales {
                        Text("(base \(evento.puntos))")
                            .font(.mabeLabelSm)
                            .foregroundColor(.mabeText3)
                    }
                }
                .foregroundColor(Color(hex: "#D97706"))
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.mabeSurface0)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(hex: "#D97706").opacity(0.25), lineWidth: 1)
        }
        .shadow(color: Color(hex: "#D97706").opacity(0.15), radius: 20, x: 0, y: 4)
        .padding(.horizontal, 20)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : -20)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                appeared = true
            }
        }
    }
}

struct CargarEvaluacionButton: View {
    @Environment(RewardService.self) private var rewardService
    @State private var porcentaje: Double = 82

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Cargar evaluación cuatrimestral")
                    .font(.mabeH3)
                    .foregroundColor(.mabeText1)
                Spacer()
                Text("\(Int(porcentaje))%")
                    .font(.mabeH2)
                    .foregroundColor(Color(hex: "#00875A"))
            }

            Slider(value: $porcentaje, in: 0...100, step: 1)
                .tint(Color(hex: "#00875A"))

            Button {
                rewardService.cargarEvaluacionCuatrimestral(porcentaje: Int(porcentaje))
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                    Text("Cargar puntos de desempeño")
                }
                .font(.mabeLabelLg)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Color(hex: "#00875A"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
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
}
