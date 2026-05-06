import SwiftUI

struct BienestarView: View {
    @State private var vm = BienestarViewModel()
    @State private var showingCheckIn = false
    @State private var showSupport = false
    @Environment(\.dismiss) private var dismiss
    @Environment(RewardService.self) private var rewardService

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 16) {
                    CheckInEmocionalCard(
                        selectedMood: $vm.todayMood,
                        alreadyCheckedIn: vm.alreadyCheckedInToday,
                        onMoodSelected: { mood in
                            let shouldAward = !vm.alreadyCheckedInToday
                            vm.registerMood(mood)
                            if shouldAward {
                                rewardService.registrarCheckinBienestar(moodLabel: mood.label)
                            }
                            if mood == .dificil || mood == .cansado {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                                    vm.showingSupportBanner = true
                                }
                            }
                        },
                        onGuiadoTap: { showingCheckIn = true }
                    )

                    if vm.showingSupportBanner {
                        SupportBannerCard(onContactRH: { showSupport = true })
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    RachaCard(racha: vm.rachaActual, historialSemana: vm.historialSemana)
                    RespirationCard()
                    MoodHistoryCard(historial: vm.historialCompleto)
                    RecursosSection(moodActual: vm.todayMood, onContactRH: { showSupport = true })
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 100)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarHidden(true)
        .background(Color(hex: "#F8F9FC"))
        .sheet(isPresented: $showingCheckIn) {
            CheckInGuiadoSheet { resultado in
                let shouldAward = !vm.alreadyCheckedInToday
                vm.saveCheckInResult(resultado)
                if shouldAward {
                    rewardService.registrarCheckinBienestar(moodLabel: resultado.mood.label)
                }
                showingCheckIn = false
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
        .sheet(isPresented: $vm.showingHistory) {
            MoodHistoryFullView(historial: vm.historialCompleto)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .sheet(isPresented: $showSupport) {
            HRSupportSheet(context: "Solicitud desde bienestar")
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.showingSupportBanner)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#003087"))
                    .frame(width: 36, height: 36)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Regresar")

            Text("Mi Bienestar")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "#0D1B3E"))

            Spacer()

            Button {
                vm.showingHistory = true
            } label: {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#003087"))
                    .frame(width: 36, height: 36)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Ver historial")
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(Color(hex: "#F8F9FC"))
    }
}

struct CheckInEmocionalCard: View {
    @Binding var selectedMood: MoodOption?
    let alreadyCheckedIn: Bool
    let onMoodSelected: (MoodOption) -> Void
    let onGuiadoTap: () -> Void

    @State private var hoveredMood: MoodOption?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("¿Cómo estás hoy?")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#0D1B3E"))
                    Text(alreadyCheckedIn ? "Ya registraste cómo te sientes" : "Toca un emoji para registrar tu estado")
                        .font(.system(size: 13))
                        .foregroundColor(alreadyCheckedIn ? Color(hex: "#00C27C") : Color(hex: "#9AA5BE"))
                }

                Spacer()

                if alreadyCheckedIn {
                    Text("Hoy")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "#00C27C"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#00C27C").opacity(0.1))
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 0) {
                ForEach(MoodOption.allCases, id: \.self) { mood in
                    EmojiSelector(
                        mood: mood,
                        isSelected: selectedMood == mood,
                        isHovered: hoveredMood == mood,
                        isDisabled: alreadyCheckedIn && selectedMood != mood,
                        onTap: { onMoodSelected(mood) }
                    )
                    .frame(maxWidth: .infinity)
                    .onHover { hovering in
                        hoveredMood = hovering ? mood : nil
                    }
                }
            }
            .padding(.vertical, 2)

            if let selectedMood {
                HStack(spacing: 8) {
                    Text(selectedMood.emoji)
                        .font(.system(size: 16))
                    Text(selectedMood.descripcion)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(selectedMood.color)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selectedMood.color.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            Divider().opacity(0.3)

            Button(action: onGuiadoTap) {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 15, weight: .semibold))
                    Text(alreadyCheckedIn ? "Actualizar check-in guiado" : "Check-in guiado (2 min)")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(Color(hex: "#003087"))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(hex: "#EFF3FA"))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color(hex: "#0D1B3E").opacity(0.07), radius: 14, x: 0, y: 4)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedMood)
    }
}

struct EmojiSelector: View {
    let mood: MoodOption
    let isSelected: Bool
    let isHovered: Bool
    let isDisabled: Bool
    let onTap: () -> Void

    @State private var bounced = false

    var body: some View {
        Button {
            guard !isDisabled else { return }
            bounced = false
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                bounced = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                bounced = false
            }
            onTap()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    if isSelected || isHovered {
                        Circle()
                            .fill(mood.color.opacity(isSelected ? 0.15 : 0.08))
                            .frame(width: 52, height: 52)
                            .scaleEffect(bounced ? 1.2 : 1.0)
                    }
                    Text(mood.emoji)
                        .font(.system(size: isSelected ? 30 : 26))
                        .scaleEffect(bounced ? 1.15 : (isSelected ? 1.1 : 1.0))
                        .opacity(isDisabled ? 0.35 : 1.0)
                }
                .frame(height: 52)

                Text(mood.label)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? mood.color : Color(hex: "#9AA5BE"))
                    .opacity(isDisabled ? 0.4 : 1.0)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

struct CheckInGuiadoSheet: View {
    let onComplete: (CheckInResultado) -> Void

    @State private var step = 0
    @State private var selectedMood: MoodOption = .regular
    @State private var energyLevel: Double = 5
    @State private var selectedFactores: Set<FactorBienestar> = []
    @State private var nota = ""

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color(hex: "#EFF3FA")).frame(height: 3)
                    Rectangle()
                        .fill(LinearGradient(colors: [Color(hex: "#003087"), Color(hex: "#1976FF")], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(step + 1) / 4, height: 3)
                        .animation(.spring(response: 0.4), value: step)
                }
            }
            .frame(height: 3)

            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: "#DDE3F0"))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 8)

            Group {
                switch step {
                case 0: pasoEstado
                case 1: pasoEnergia
                case 2: pasoFactores
                default: pasoNota
                }
            }
            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: step)
        }
        .background(Color.white)
    }

    private var pasoEstado: some View {
        VStack(spacing: 24) {
            pasoHeader(numero: "1 de 4", titulo: "¿Cómo describes tu estado de ánimo ahora?", subtitulo: "Sin juzgarte. Solo observa cómo estás.")

            HStack(spacing: 12) {
                ForEach(MoodOption.allCases, id: \.self) { mood in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedMood = mood
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        VStack(spacing: 8) {
                            Text(mood.emoji)
                                .font(.system(size: selectedMood == mood ? 38 : 30))
                                .scaleEffect(selectedMood == mood ? 1.1 : 1.0)
                                .shadow(color: selectedMood == mood ? mood.color.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                            Text(mood.label)
                                .font(.system(size: 11, weight: selectedMood == mood ? .bold : .medium))
                                .foregroundColor(selectedMood == mood ? mood.color : Color(hex: "#9AA5BE"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)

            VStack(spacing: 6) {
                Text(selectedMood.descripcion)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(selectedMood.color)
                    .multilineTextAlignment(.center)
                Text(selectedMood.consejo)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#9AA5BE"))
                    .multilineTextAlignment(.center)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(selectedMood.color.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.horizontal, 20)

            Spacer()
            pasoBoton("Continuar") { step = 1 }
        }
        .padding(.top, 8)
    }

    private var pasoEnergia: some View {
        VStack(spacing: 24) {
            pasoHeader(numero: "2 de 4", titulo: "¿Cuánta energía tienes ahora?", subtitulo: "Considera cómo te sientes físicamente.")

            VStack(spacing: 16) {
                Text(energyEmoji)
                    .font(.system(size: 52))
                    .animation(.spring(response: 0.3), value: energyLevel)

                Text(energyLabel)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(energyColor)

                Slider(value: $energyLevel, in: 1...10, step: 1)
                    .tint(energyColor)
                    .padding(.horizontal, 20)

                HStack {
                    Text("Sin energía")
                    Spacer()
                    Text("Lleno de energía")
                }
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "#9AA5BE"))
                .padding(.horizontal, 20)

                HStack(spacing: 0) {
                    ForEach(1...10, id: \.self) { n in
                        Text("\(n)")
                            .font(.system(size: 10, weight: Int(energyLevel) == n ? .bold : .regular))
                            .foregroundColor(Int(energyLevel) == n ? energyColor : Color(hex: "#DDE3F0"))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 20)
            }
            .onChange(of: energyLevel) {
                UISelectionFeedbackGenerator().selectionChanged()
            }

            Spacer()
            pasoBoton("Continuar") { step = 2 }
        }
        .padding(.top, 8)
    }

    private var pasoFactores: some View {
        VStack(spacing: 20) {
            pasoHeader(numero: "3 de 4", titulo: "¿Qué está influyendo en cómo te sientes?", subtitulo: "Selecciona todos los que apliquen.")

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(FactorBienestar.allCases, id: \.self) { factor in
                    FactorChip(
                        factor: factor,
                        isSelected: selectedFactores.contains(factor),
                        onTap: {
                            withAnimation(.spring(response: 0.25)) {
                                if selectedFactores.contains(factor) {
                                    selectedFactores.remove(factor)
                                } else {
                                    selectedFactores.insert(factor)
                                }
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    )
                }
            }
            .padding(.horizontal, 20)

            Text("Puedes continuar aunque no selecciones ninguno.")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#9AA5BE"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Spacer()
            pasoBoton("Continuar") { step = 3 }
        }
        .padding(.top, 8)
    }

    private var pasoNota: some View {
        VStack(spacing: 20) {
            pasoHeader(numero: "4 de 4", titulo: "¿Quieres agregar algo más?", subtitulo: "Una nota personal o algo que quieras recordar.")

            TextEditor(text: $nota)
                .frame(height: 120)
                .padding(12)
                .background(Color(hex: "#F8F9FC"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color(hex: "#DDE3F0"), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if nota.isEmpty {
                        Text("\"Hoy fue un día difícil por el ruido en la planta...\"")
                            .foregroundColor(Color(hex: "#9AA5BE"))
                            .font(.system(size: 14))
                            .padding(18)
                            .allowsHitTesting(false)
                    }
                }
                .padding(.horizontal, 20)

            Text("Esta nota es privada y solo tú puedes verla.")
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "#9AA5BE"))
                .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 8) {
                Text("Tu registro de hoy")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#0D1B3E"))
                HStack(spacing: 16) {
                    Label("\(selectedMood.emoji) \(selectedMood.label)", systemImage: "face.smiling")
                        .foregroundColor(selectedMood.color)
                    Label("Energía \(Int(energyLevel))/10", systemImage: "bolt.fill")
                        .foregroundColor(energyColor)
                }
                .font(.system(size: 12))

                if !selectedFactores.isEmpty {
                    Text(selectedFactores.map(\.label).joined(separator: " · "))
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#4B5675"))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "#EFF3FA"))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.horizontal, 20)

            Spacer()
            pasoBoton("Guardar mi check-in") {
                onComplete(CheckInResultado(mood: selectedMood, energia: Int(energyLevel), factores: Array(selectedFactores), nota: nota.isEmpty ? nil : nota))
            }
        }
        .padding(.top, 8)
    }

    private var energyEmoji: String {
        switch Int(energyLevel) {
        case 1...2: "😴"
        case 3...4: "😓"
        case 5...6: "😐"
        case 7...8: "😊"
        default: "⚡"
        }
    }

    private var energyLabel: String {
        switch Int(energyLevel) {
        case 1...2: "Muy baja"
        case 3...4: "Baja"
        case 5...6: "Moderada"
        case 7...8: "Buena"
        default: "Excelente"
        }
    }

    private var energyColor: Color {
        switch Int(energyLevel) {
        case 1...3: Color(hex: "#F03E3E")
        case 4...6: Color(hex: "#D97706")
        case 7...8: Color(hex: "#00C27C")
        default: Color(hex: "#1976FF")
        }
    }

    private func pasoHeader(numero: String, titulo: String, subtitulo: String) -> some View {
        VStack(spacing: 8) {
            Text(numero)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: "#9AA5BE"))
                .tracking(1)
            Text(titulo)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "#0D1B3E"))
                .multilineTextAlignment(.center)
            Text(subtitulo)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#9AA5BE"))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func pasoBoton(_ title: String, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                action()
            }
        } label: {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color(hex: "#003087"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: Color(hex: "#1976FF").opacity(0.3), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }
}

struct FactorChip: View {
    let factor: FactorBienestar
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: factor.icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(factor.label)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundColor(isSelected ? .white : factor.color)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(isSelected ? factor.color : factor.color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct RachaCard: View {
    let racha: Int
    let historialSemana: [MoodEntry?]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Text("🔥")
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.18))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("Racha de \(racha) días")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Text("Mantén tu registro de bienestar")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.78))
                }
                Spacer()
            }

            HStack(spacing: 8) {
                ForEach(Array(historialSemana.enumerated()), id: \.offset) { _, entry in
                    VStack(spacing: 5) {
                        Text(entry?.mood.emoji ?? "•")
                            .font(.system(size: entry == nil ? 18 : 20))
                            .foregroundColor(.white.opacity(0.55))
                            .frame(width: 30, height: 30)
                            .background(Color.white.opacity(entry == nil ? 0.16 : 0.95))
                            .clipShape(Circle())
                        Circle()
                            .fill(entry == nil ? Color.white.opacity(0.25) : Color.white)
                            .frame(width: 5, height: 5)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(20)
        .background(LinearGradient(colors: [Color(hex: "#003087"), Color(hex: "#1976FF")], startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color(hex: "#1976FF").opacity(0.24), radius: 18, x: 0, y: 8)
    }
}

struct RespirationCard: View {
    @State private var isActive = false
    @State private var phase: BreathPhase = .inhale
    @State private var circleScale: CGFloat = 0.6
    @State private var countdown = 4
    @State private var totalSeconds = 0
    @State private var timer: Timer?

    enum BreathPhase {
        case inhale
        case hold
        case exhale
        case rest

        var label: String {
            switch self {
            case .inhale: "Inhala"
            case .hold: "Mantén"
            case .exhale: "Exhala"
            case .rest: "Descansa"
            }
        }

        var duration: Int {
            switch self {
            case .inhale: 4
            case .hold: 4
            case .exhale: 6
            case .rest: 2
            }
        }

        var color: Color {
            switch self {
            case .inhale: Color(hex: "#1976FF")
            case .hold: Color(hex: "#7C5CFC")
            case .exhale: Color(hex: "#00C27C")
            case .rest: Color(hex: "#9AA5BE")
            }
        }

        var targetScale: CGFloat {
            switch self {
            case .inhale, .hold: 1.0
            case .exhale, .rest: 0.6
            }
        }

        var next: BreathPhase {
            switch self {
            case .inhale: .hold
            case .hold: .exhale
            case .exhale: .rest
            case .rest: .inhale
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Respiración consciente")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(hex: "#0D1B3E"))
                    Text("Reduce el estrés en 2 minutos")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#9AA5BE"))
                }
                Spacer()
                Image(systemName: "wind")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#1976FF"))
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 16)

            if isActive {
                VStack(spacing: 20) {
                    ZStack {
                        ForEach([0.8, 0.9, 1.0], id: \.self) { scale in
                            Circle()
                                .fill(phase.color.opacity(0.06))
                                .frame(width: 120, height: 120)
                                .scaleEffect(circleScale * scale)
                        }

                        Circle()
                            .fill(RadialGradient(colors: [phase.color.opacity(0.3), phase.color.opacity(0.1)], center: .center, startRadius: 0, endRadius: 55))
                            .frame(width: 110, height: 110)
                            .scaleEffect(circleScale)
                            .overlay(Circle().strokeBorder(phase.color, lineWidth: 2).scaleEffect(circleScale))

                        VStack(spacing: 4) {
                            Text(phase.label)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(phase.color)
                            Text("\(countdown)")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(Color(hex: "#0D1B3E"))
                                .contentTransition(.numericText())
                        }
                    }
                    .frame(height: 130)

                    Text("\(totalSeconds / 60):\(String(format: "%02d", totalSeconds % 60))")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "#9AA5BE"))

                    Button("Detener") {
                        stopBreathing()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#F03E3E"))
                    .padding(.bottom, 16)
                }
            } else {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#1976FF").opacity(0.1))
                            .frame(width: 56, height: 56)
                        Image(systemName: "lungs.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "#1976FF"))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Técnica 4-4-6")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#0D1B3E"))
                        Text("Inhala 4s · Mantén 4s · Exhala 6s")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#9AA5BE"))
                    }

                    Spacer()

                    Button("Iniciar") {
                        startBreathing()
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#1976FF"))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 16)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color(hex: "#0D1B3E").opacity(0.07), radius: 14, x: 0, y: 4)
        .animation(.easeInOut(duration: 0.3), value: isActive)
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    private func startBreathing() {
        isActive = true
        phase = .inhale
        countdown = phase.duration
        totalSeconds = 0
        animatePhase()
        startTimer()
    }

    private func stopBreathing() {
        timer?.invalidate()
        timer = nil
        withAnimation(.easeOut(duration: 0.4)) {
            isActive = false
            circleScale = 0.6
        }
    }

    private func animatePhase() {
        withAnimation(.easeInOut(duration: Double(phase.duration))) {
            circleScale = phase.targetScale
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            totalSeconds += 1
            if countdown > 1 {
                countdown -= 1
            } else {
                phase = phase.next
                countdown = phase.duration
                animatePhase()
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
        }
    }
}

struct MoodHistoryCard: View {
    let historial: [MoodEntry]

    private var last7Days: [(label: String, value: Double, mood: MoodOption?)] {
        let cal = Calendar.current
        return (0..<7).reversed().map { daysAgo in
            let date = cal.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
            let entry = historial.first { cal.isDate($0.fecha, inSameDayAs: date) }
            let label = daysAgo == 0 ? "Hoy" : date.formatted(.dateTime.weekday(.abbreviated))
            return (label, Double(entry?.mood.numericValue ?? 0), entry?.mood)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Tu semana")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "#0D1B3E"))
                Spacer()
                Text("Últimos 7 días")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#9AA5BE"))
            }

            HStack(spacing: 0) {
                ForEach(last7Days, id: \.label) { day in
                    VStack(spacing: 6) {
                        if let mood = day.mood {
                            Text(mood.emoji)
                                .font(.system(size: 20))
                        } else {
                            Circle()
                                .fill(Color(hex: "#EFF3FA"))
                                .frame(width: 24, height: 24)
                        }
                        Text(day.label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(hex: "#9AA5BE"))
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            let values = last7Days.filter { $0.value > 0 }.map(\.value)
            if !values.isEmpty {
                let promedio = values.reduce(0, +) / Double(values.count)
                Text(tendenciaTexto(promedio: promedio))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(tendenciaColor(promedio: promedio))
                    .padding(.top, 2)
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color(hex: "#0D1B3E").opacity(0.07), radius: 14, x: 0, y: 4)
    }

    private func tendenciaTexto(promedio: Double) -> String {
        switch promedio {
        case 4.5...: "Has tenido una excelente semana"
        case 3.5...: "Tu semana ha ido bien"
        case 2.5...: "Semana regular. Una pausa puede ayudar"
        default: "Ha sido una semana difícil. Recuerda pedir apoyo"
        }
    }

    private func tendenciaColor(promedio: Double) -> Color {
        switch promedio {
        case 4.0...: Color(hex: "#00C27C")
        case 3.0...: Color(hex: "#1976FF")
        case 2.0...: Color(hex: "#D97706")
        default: Color(hex: "#F03E3E")
        }
    }
}

struct RecursosSection: View {
    let moodActual: MoodOption?
    let onContactRH: () -> Void

    private var recursosOrdenados: [RecursoBienestar] {
        let todos = MockDataService.recursosBienestar
        if moodActual == .dificil || moodActual == .cansado {
            return todos.sorted { left, right in
                left.prioridad == .alta && right.prioridad != .alta
            }
        }
        return todos
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recursos para ti")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color(hex: "#0D1B3E"))

            ForEach(recursosOrdenados.prefix(3)) { recurso in
                RecursoRow(recurso: recurso, onContactRH: onContactRH)
            }
        }
    }
}

struct RecursoRow: View {
    let recurso: RecursoBienestar
    let onContactRH: () -> Void

    var body: some View {
        Button {
            if recurso.tipoIcon == "phone" {
                onContactRH()
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(recurso.color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: recurso.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(recurso.color)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(recurso.titulo)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#0D1B3E"))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        if recurso.prioridad == .alta {
                            Text("Recomendado")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(recurso.color)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(recurso.color.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }

                    HStack(spacing: 6) {
                        Image(systemName: recurso.tipoIcon)
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "#9AA5BE"))
                        Text(recurso.duracion)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#9AA5BE"))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "#DDE3F0"))
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color(hex: "#0D1B3E").opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(MabePressButtonStyle(scale: 0.98))
    }
}

struct SupportBannerCard: View {
    let onContactRH: () -> Void

    var body: some View {
        Button(action: onContactRH) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#003087"))
                        .frame(width: 44, height: 44)
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Estamos aquí para ti")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("Tu caso puede canalizarse con un especialista de RH.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "phone.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            .padding(16)
            .background(Color(hex: "#003087"))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color(hex: "#1976FF").opacity(0.3), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct MoodHistoryFullView: View {
    let historial: [MoodEntry]
    @Environment(\.dismiss) private var dismiss

    private var sortedHistorial: [MoodEntry] {
        historial.sorted { $0.fecha > $1.fecha }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Historial de bienestar")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#0D1B3E"))
                Spacer()
                Button("Listo") { dismiss() }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "#1976FF"))
            }
            .padding(20)

            ScrollView {
                VStack(spacing: 12) {
                    MoodHistoryCard(historial: historial)

                    ForEach(sortedHistorial) { entry in
                        HStack(spacing: 12) {
                            Text(entry.mood.emoji)
                                .font(.system(size: 28))
                                .frame(width: 46, height: 46)
                                .background(entry.mood.color.opacity(0.1))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.mood.label)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color(hex: "#0D1B3E"))
                                Text(entry.fecha.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "#9AA5BE"))
                                if let nota = entry.nota {
                                    Text(nota)
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "#4B5675"))
                                        .lineLimit(2)
                                }
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
        }
        .background(Color(hex: "#F8F9FC"))
    }
}
