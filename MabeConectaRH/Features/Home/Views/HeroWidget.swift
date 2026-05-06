import SwiftUI

struct HeroWidget: View {
    let empleado: Empleado
    let preferencias: UserPreferences
    @State private var appeared = false
    @State private var featureIndex = 0

    var featureActiva: HeroFeature {
        HeroFeature.from(preferencias.interesesSeleccionados.first ?? "vacaciones")
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(featureActiva.gradient)
                .animation(.easeInOut(duration: 0.25), value: featureActiva.id)

            GeometryReader { geo in
                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: 140, height: 140)
                    .offset(x: geo.size.width - 60, y: -40)

                Circle()
                    .fill(.white.opacity(0.04))
                    .frame(width: 90, height: 90)
                    .offset(x: geo.size.width - 20, y: 60)
            }
            .clipped()
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(saludo())
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.75))
                        Text(empleado.nombre)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
                    .animation(.spring(response: 0.5, dampingFraction: 0.82).delay(0.08), value: appeared)

                    Spacer()

                    HStack(spacing: 10) {
                        ZStack(alignment: .topTrailing) {
                            Circle()
                                .fill(.white.opacity(0.15))
                                .frame(width: 36, height: 36)
                            Image(systemName: "bell.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            Circle()
                                .fill(Color(hex: "#F03E3E"))
                                .frame(width: 8, height: 8)
                                .offset(x: 1, y: -1)
                        }
                        .accessibilityLabel("Notificaciones")

                        NavigationLink(destination: PerfilEmpleadoView(empleado: empleado)) {
                            ZStack {
                                Circle()
                                    .fill(.white.opacity(0.25))
                                    .frame(width: 36, height: 36)
                                Text(empleado.iniciales)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .overlay {
                                Circle().strokeBorder(.white.opacity(0.5), lineWidth: 1.5)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Abrir perfil")
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
                    .animation(.spring(response: 0.5, dampingFraction: 0.82).delay(0.16), value: appeared)
                }

                Spacer()

                NavigationLink(destination: destinationView) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.white.opacity(0.18))
                                .frame(width: 44, height: 44)
                            Image(systemName: featureActiva.icon)
                                .font(.system(size: 19, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text(featureActiva.valorPrincipal(empleado))
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .contentTransition(.numericText())
                                if !featureActiva.unidad.isEmpty {
                                    Text(featureActiva.unidad)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            Text(featureActiva.subtitulo(empleado))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.65))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }

                        Spacer()

                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(14)
                    .background(.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .animation(.spring(response: 0.5, dampingFraction: 0.82).delay(0.24), value: appeared)
                .animation(.easeInOut(duration: 0.25), value: featureActiva.id)
            }
            .padding(18)
        }
        .frame(height: 170)
        .shadow(color: featureActiva.shadowColor, radius: 20, x: 0, y: 8)
        .onAppear {
            appeared = false
            withAnimation {
                appeared = true
            }
        }
        .onChange(of: featureActiva.id) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                featureIndex += 1
                appeared = true
            }
        }
    }

    @ViewBuilder
    private var destinationView: some View {
        switch featureActiva.id {
        case "vacaciones":
            VacacionesView(empleado: empleado)
        case "prestaciones":
            PrestacionesView()
        default:
            PrestacionesView()
        }
    }

    func saludo() -> String {
        let hora = Calendar.current.component(.hour, from: Date())
        switch hora {
        case 6..<12:
            return "Buenos días ☀️"
        case 12..<19:
            return "Buenas tardes 🌤️"
        default:
            return "Buenas noches 🌙"
        }
    }
}

struct RotatingHeroCarousel: View {
    let empleado: Empleado
    let preferencias: UserPreferences

    @State private var currentIndex = 0
    @State private var dragOffset: CGFloat = 0
    @State private var timer: Timer?
    private let autoScrollInterval: TimeInterval = 5.0
    private let heroHeight: CGFloat = 170

    var features: [HeroFeature] {
        var selected = preferencias.interesesSeleccionados.map { HeroFeature.features[$0] ?? HeroFeature.features["prestaciones"]! }
        if selected.isEmpty {
            selected = [HeroFeature.features["prestaciones"]!, HeroFeature.features["vacaciones"]!]
        } else if selected.count == 1, let nomina = HeroFeature.features["nomina"], selected.first?.id != nomina.id {
            selected.append(nomina)
        } else if selected.count == 1, let vacaciones = HeroFeature.features["vacaciones"], selected.first?.id != vacaciones.id {
            selected.append(vacaciones)
        }
        return Array(selected.prefix(4))
    }

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                ForEach(features.indices.reversed(), id: \.self) { index in
                    HeroCard(
                        feature: features[index],
                        empleado: empleado,
                        isCurrent: index == currentIndex
                    )
                    .frame(height: heroHeight)
                    .offset(x: cardOffset(for: index))
                    .scaleEffect(cardScale(for: index))
                    .opacity(cardOpacity(for: index))
                    .zIndex(Double(index == currentIndex ? 1 : 0))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentIndex)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: heroHeight)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            if value.translation.width < -50 {
                                goToNext()
                            } else if value.translation.width > 50 {
                                goToPrevious()
                            }
                            dragOffset = 0
                        }
                    }
            )

            if features.count > 1 {
                HStack(spacing: 6) {
                    ForEach(features.indices, id: \.self) { index in
                        Capsule()
                            .fill(index == currentIndex ? Color(hex: "#003087") : Color(hex: "#9AA5BE").opacity(0.4))
                            .frame(width: index == currentIndex ? 20 : 6, height: 6)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
                    }
                }
                .frame(height: 12)
            } else {
                Color.clear.frame(height: 12)
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            startAutoScroll()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    private func cardOffset(for index: Int) -> CGFloat {
        let diff = index - currentIndex
        if diff == 0 { return dragOffset }
        if diff == 1 || (currentIndex == features.count - 1 && index == 0) { return 20 }
        return -20
    }

    private func cardScale(for index: Int) -> CGFloat {
        index == currentIndex ? 1.0 : 0.92
    }

    private func cardOpacity(for index: Int) -> Double {
        let diff = abs(index - currentIndex)
        return diff == 0 ? 1.0 : diff == 1 ? 0.5 : 0.0
    }

    private func goToNext() {
        guard features.count > 1 else { return }
        currentIndex = (currentIndex + 1) % features.count
        Haptics.impact(.light)
    }

    private func goToPrevious() {
        guard features.count > 1 else { return }
        currentIndex = (currentIndex - 1 + features.count) % features.count
        Haptics.impact(.light)
    }

    private func startAutoScroll() {
        guard features.count > 1, timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: true) { _ in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                goToNext()
            }
        }
    }
}

private struct HeroCard: View {
    let feature: HeroFeature
    let empleado: Empleado
    let isCurrent: Bool
    @Environment(RewardService.self) private var rewardService

    @State private var appeared = false
    @State private var particle1Offset: CGSize = .zero
    @State private var particle2Offset: CGSize = .zero
    @State private var shimmerOffset: CGFloat = -260

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(feature.gradient)

            MabeIndustrialPattern(opacity: 0.075, color: .white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            Circle()
                .fill(.white.opacity(0.07))
                .frame(width: 160, height: 160)
                .offset(x: 180, y: -40)
                .offset(particle1Offset)
                .blur(radius: 2)
                .onAppear {
                    withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                        particle1Offset = CGSize(width: 40, height: -30)
                    }
                }

            Circle()
                .fill(.white.opacity(0.05))
                .frame(width: 90, height: 90)
                .offset(x: 260, y: 90)
                .offset(particle2Offset)
                .onAppear {
                    withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true).delay(1.0)) {
                        particle2Offset = CGSize(width: -30, height: 20)
                    }
                }

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.1), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 70, height: 260)
                .rotationEffect(.degrees(28))
                .offset(x: shimmerOffset, y: -55)
                .blendMode(.screen)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .onAppear {
                    withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false).delay(0.6)) {
                        shimmerOffset = 420
                    }
                }

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(saludo())
                            .font(.mabeLabelMd)
                            .foregroundColor(.white.opacity(0.75))
                            .fixedSize()
                        Text(empleado.nombre)
                            .font(.mabeH3)
                            .foregroundColor(.white)
                            .fixedSize()
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        if rewardService.profile.tier >= .oro {
                            HStack(spacing: 4) {
                                Text(rewardService.profile.tier.emoji)
                                    .font(.system(size: 11))
                                Text(rewardService.profile.tier.nombre)
                                    .font(.mabeLabelSm)
                            }
                            .foregroundColor(rewardService.profile.tier.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(rewardService.profile.tier.backgroundColor.opacity(0.92))
                            .clipShape(Capsule())
                        }
                        notificationButton
                        avatarButton
                    }
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 5)
                .frame(maxWidth: .infinity)

                Spacer()
                    .frame(minHeight: 8, maxHeight: 20)

                NavigationLink(destination: destinationView) {
                    featureDataCard
                }
                .buttonStyle(.plain)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 8)
            }
            .padding(18)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: feature.shadowColor, radius: 18, x: 0, y: 8)
        .onChange(of: isCurrent) { _, current in
            if current {
                appeared = false
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)) {
                    appeared = true
                }
            }
        }
        .onAppear {
            if isCurrent {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.15)) {
                    appeared = true
                }
            }
        }
    }

    private var notificationButton: some View {
        ZStack(alignment: .topTrailing) {
            Circle()
                .fill(.white.opacity(0.15))
                .frame(width: 34, height: 34)
            Image(systemName: "bell.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
            PulsingDot(color: Color(hex: "#F03E3E"))
                .scaleEffect(0.6)
                .offset(x: 2, y: -2)
        }
        .accessibilityLabel("Notificaciones")
    }

    private var avatarButton: some View {
        NavigationLink(destination: PerfilEmpleadoView(empleado: empleado)) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 34, height: 34)
                Text(empleado.iniciales)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            .overlay {
                Circle().strokeBorder(.white.opacity(0.4), lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Abrir perfil")
    }

    private var featureDataCard: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(.white.opacity(0.18))
                    .frame(width: 40, height: 40)
                Image(systemName: feature.icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(feature.valorPrincipal(empleado))
                        .font(.mabeDisplaySm)
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                    if !feature.unidad.isEmpty {
                        Text(feature.unidad)
                            .font(.mabeLabelMd)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                Text(feature.contextoTemporal)
                    .font(.mabeLabelSm)
                    .foregroundColor(.white.opacity(0.65))
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
                    .minimumScaleFactor(0.8)
            }

            Spacer()

            Image(systemName: "arrow.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.55))
        }
        .padding(12)
        .background(.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(.white.opacity(0.15), lineWidth: 1)
        }
    }

    @ViewBuilder
    private var destinationView: some View {
        switch feature.id {
        case "vacaciones":
            VacacionesView(empleado: empleado)
        case "prestaciones":
            PrestacionesView()
        case "historial", "constancias", "permisos", "incapacidades", "nomina":
            SolicitudesView()
        default:
            PrestacionesView()
        }
    }

    private func saludo() -> String {
        let hora = Calendar.current.component(.hour, from: Date())
        switch hora {
        case 6..<12:
            return "Buenos días ☀️"
        case 12..<19:
            return "Buenas tardes 🌤️"
        default:
            return "Buenas noches 🌙"
        }
    }
}

private struct BottomRoundedShape: Shape {
    var radius: CGFloat = 28

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.width - radius, y: rect.height),
            control: CGPoint(x: rect.width, y: rect.height)
        )
        path.addLine(to: CGPoint(x: radius, y: rect.height))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.height - radius),
            control: CGPoint(x: 0, y: rect.height)
        )
        path.closeSubpath()
        return path
    }
}

private extension UIApplication {
    var mabeSafeAreaTop: CGFloat {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .safeAreaInsets.top ?? 0
    }
}
