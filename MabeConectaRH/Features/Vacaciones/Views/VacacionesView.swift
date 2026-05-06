import SwiftUI

struct VacacionesView: View {
    @State private var viewModel: VacacionesViewModel
    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var motivoSeleccionado: MotivoVacacion?
    @State private var showingMotivoQuickPick = false
    @Environment(\.dismiss) private var dismiss

    init(empleado: Empleado) {
        _viewModel = State(initialValue: VacacionesViewModel(empleado: empleado))
    }

    private var diasHabiles: Int {
        guard let startDate, let endDate else { return 0 }
        return calcularDiasHabiles(from: startDate, to: endDate)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 20) {
                    summaryCard

                    MabeCalendar(
                        startDate: $startDate,
                        endDate: $endDate,
                        onRangeSelected: { _, selectedEndDate in
                            if selectedEndDate == nil {
                                motivoSeleccionado = nil
                                showingMotivoQuickPick = false
                            } else {
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                if motivoSeleccionado == nil {
                                    withAnimation(.spring(response: 0.4)) {
                                        showingMotivoQuickPick = true
                                    }
                                }
                            }
                        }
                    )
                    .padding(.horizontal, 20)

                    if showingMotivoQuickPick || motivoSeleccionado != nil {
                        MotivoQuickPick(
                            selected: $motivoSeleccionado,
                            onSelect: {
                                withAnimation(.spring(response: 0.4)) {
                                    showingMotivoQuickPick = false
                                }
                            }
                        )
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    if let motivo = motivoSeleccionado, endDate != nil {
                        MotivacionSceneView(motivo: motivo, diasHabiles: diasHabiles, hasFullRange: endDate != nil)
                            .frame(height: 150)
                            .padding(.horizontal, 20)
                            .transition(.scale(scale: 0.92).combined(with: .opacity))
                    } else if startDate != nil && endDate != nil {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.tap.fill")
                                .foregroundColor(Color(hex: "#9AA5BE"))
                            Text("Elige un motivo para ver tu escena de vacaciones")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "#9AA5BE"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    }

                    if let startDate {
                        RangoSeleccionadoCard(
                            startDate: startDate,
                            endDate: endDate,
                            diasHabiles: diasHabiles,
                            empleado: viewModel.empleado,
                            onContinue: {
                                guard motivoSeleccionado != nil else {
                                    withAnimation(.spring(response: 0.4)) {
                                        showingMotivoQuickPick = true
                                    }
                                    Haptics.impact(.light)
                                    return
                                }
                                viewModel.showingSheet = true
                            }
                        )
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    historySection
                        .padding(.horizontal, 20)
                }
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
        }
        .navigationBarHidden(true)
        .background(Color(hex: "#F8F9FC"))
        .sheet(isPresented: $viewModel.showingSheet) {
            SolicitudVacacionesFlow(
                startDate: startDate,
                endDate: endDate,
                diasHabiles: diasHabiles,
                empleado: viewModel.empleado,
                motivoPreseleccionado: motivoSeleccionado
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
        .animation(.spring(response: 0.4), value: startDate != nil)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#003087"))
                    .frame(width: 34, height: 34)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Regresar")

            Text("Vacaciones")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "#0D1B3E"))
            Spacer()
            Button {
                viewModel.showingSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                    Text("Solicitar")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(hex: "#003087"))
                .clipShape(Capsule())
                .shadow(color: Color(hex: "#1976FF").opacity(0.3), radius: 8, x: 0, y: 3)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(Color(hex: "#F8F9FC"))
    }

    private var summaryCard: some View {
        MabeCard {
            HStack {
                SummaryMetric(title: "Disponibles", value: "\(viewModel.empleado.diasVacacionesDisponibles)")
                Divider().frame(height: 42)
                SummaryMetric(title: "Usados", value: "\(viewModel.diasUsados)")
                Divider().frame(height: 42)
                SummaryMetric(title: "Totales", value: "\(viewModel.empleado.diasVacacionesTotales)")
            }
        }
        .padding(.horizontal, 20)
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Historial")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.mabeGray900)

            ForEach(viewModel.historial) { solicitud in
                MabeCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(solicitud.tipo)
                                .font(.body.weight(.medium))
                                .foregroundStyle(Color.mabeGray900)
                            Text(solicitud.fecha.mabeShortDate)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.mabeGray500)
                        }
                        Spacer()
                        MabeStatusBadge(status: solicitud.estado.rawValue, color: solicitud.estado.color)
                    }
                }
            }
        }
    }

    private func calcularDiasHabiles(from start: Date, to end: Date) -> Int {
        var count = 0
        var current = start
        let calendar = Calendar.current

        while calendar.compare(current, to: end, toGranularity: .day) != .orderedDescending {
            let weekday = calendar.component(.weekday, from: current)
            if weekday != 1 && weekday != 7 {
                count += 1
            }
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }
        return count
    }
}

private struct SummaryMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.mabeBlue)
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.mabeGray500)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct MabeCalendar: View {
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    var onRangeSelected: ((Date, Date?) -> Void)?

    @State private var displayedMonth = Date()
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private let weekdayHeaders = ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"]

    private var daysInMonth: [Date?] {
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)),
              let range = calendar.range(of: .day, in: .month, for: displayedMonth)
        else { return [] }

        let weekday = calendar.component(.weekday, from: monthStart) - 1
        var days: [Date?] = Array(repeating: nil, count: weekday)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    var body: some View {
        VStack(spacing: 0) {
            monthHeader
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

            HStack(spacing: 0) {
                ForEach(weekdayHeaders, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor((day == "Dom" || day == "Sáb") ? Color(hex: "#F03E3E").opacity(0.5) : Color(hex: "#9AA5BE"))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)

            Divider().opacity(0.25).padding(.horizontal, 16)

            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(0..<daysInMonth.count, id: \.self) { index in
                    if let date = daysInMonth[index] {
                        AirbnbDayCell(
                            date: date,
                            startDate: startDate,
                            endDate: endDate,
                            isWeekend: isWeekend(date),
                            isPast: isPast(date),
                            onTap: { handleDayTap(date) }
                        )
                    } else {
                        Color.clear.frame(height: 52)
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.top, 4)
            .padding(.bottom, 8)

            HStack(spacing: 16) {
                legendItem(color: Color(hex: "#003087"), label: "Seleccionado")
                legendItem(color: Color(hex: "#1976FF").opacity(0.15), label: "Rango")
                legendItem(color: Color(hex: "#9AA5BE").opacity(0.3), label: "No disponible")
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color(hex: "#0D1B3E").opacity(0.07), radius: 16, x: 0, y: 4)
    }

    private var monthHeader: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.4)) {
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#003087"))
                    .frame(width: 34, height: 34)
                    .background(Color(hex: "#EFF3FA"))
                    .clipShape(Circle())
            }

            Spacer()

            Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "#0D1B3E"))
                .contentTransition(.numericText())

            Spacer()

            Button {
                withAnimation(.spring(response: 0.4)) {
                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#003087"))
                    .frame(width: 34, height: 34)
                    .background(Color(hex: "#EFF3FA"))
                    .clipShape(Circle())
            }
        }
        .padding(.top, 16)
    }

    private func handleDayTap(_ date: Date) {
        guard !isWeekend(date), !isPast(date) else { return }
        Haptics.impact(.light)

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if startDate == nil {
                startDate = date
                endDate = nil
                onRangeSelected?(date, nil)
            } else if endDate == nil, let startDate {
                if date < startDate {
                    self.startDate = date
                    onRangeSelected?(date, nil)
                } else if calendar.isDate(date, inSameDayAs: startDate) {
                    self.startDate = nil
                    self.endDate = nil
                    onRangeSelected?(date, nil)
                } else {
                    endDate = date
                    onRangeSelected?(startDate, date)
                    Haptics.impact(.medium)
                }
            } else {
                startDate = date
                endDate = nil
                onRangeSelected?(date, nil)
            }
        }
    }

    private func isWeekend(_ date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7
    }

    private func isPast(_ date: Date) -> Bool {
        calendar.compare(date, to: Date(), toGranularity: .day) == .orderedAscending
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 14, height: 14)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "#9AA5BE"))
        }
    }
}

private struct AirbnbDayCell: View {
    let date: Date
    let startDate: Date?
    let endDate: Date?
    let isWeekend: Bool
    let isPast: Bool
    let onTap: () -> Void

    @State private var bounced = false
    private let calendar = Calendar.current

    private var isStart: Bool { startDate.map { calendar.isDate(date, inSameDayAs: $0) } ?? false }
    private var isEnd: Bool { endDate.map { calendar.isDate(date, inSameDayAs: $0) } ?? false }
    private var isSelected: Bool { isStart || isEnd }
    private var isToday: Bool { calendar.isDateInToday(date) }
    private var isDisabled: Bool { isWeekend || isPast }
    private var dayNumber: String { "\(calendar.component(.day, from: date))" }

    private var isInRange: Bool {
        guard let startDate, let endDate else { return false }
        return date > startDate && date < endDate && !isWeekend
    }

    private var isWeekendInRange: Bool {
        guard let startDate, let endDate else { return false }
        return date > startDate && date < endDate && isWeekend
    }

    var body: some View {
        ZStack {
            if isInRange {
                Rectangle()
                    .fill(Color(hex: "#1976FF").opacity(0.12))
                    .frame(height: 40)
            }

            if isStart && endDate != nil {
                HStack(spacing: 0) {
                    Color.clear.frame(width: 10)
                    Rectangle()
                        .fill(Color(hex: "#1976FF").opacity(0.12))
                        .frame(maxWidth: .infinity)
                }
                .frame(height: 40)
            }

            if isEnd {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(hex: "#1976FF").opacity(0.12))
                        .frame(maxWidth: .infinity)
                    Color.clear.frame(width: 10)
                }
                .frame(height: 40)
            }

            if isWeekendInRange {
                Rectangle()
                    .fill(Color(hex: "#9AA5BE").opacity(0.08))
                    .frame(height: 40)
            }

            if isSelected {
                Circle()
                    .fill(Color(hex: "#003087"))
                    .frame(width: 40, height: 40)
                    .shadow(color: Color(hex: "#1976FF").opacity(0.4), radius: 8, x: 0, y: 3)
                    .scaleEffect(bounced ? 1.0 : 0.8)
                    .onAppear {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                            bounced = true
                        }
                    }
                    .onChange(of: isSelected) { _, selected in
                        if selected {
                            bounced = false
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                                bounced = true
                            }
                        }
                    }
            }

            if isToday && !isSelected {
                Circle()
                    .strokeBorder(Color(hex: "#1976FF"), lineWidth: 1.5)
                    .frame(width: 40, height: 40)
            }

            VStack(spacing: 1) {
                if (isInRange || isSelected) && !isWeekend {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(isSelected ? .yellow : Color(hex: "#D97706").opacity(0.7))
                } else {
                    Spacer().frame(height: 9)
                }

                Text(dayNumber)
                    .font(.system(size: 14, weight: isSelected ? .bold : isToday ? .semibold : .regular))
                    .foregroundColor(textColor)
                    .scaleEffect(isSelected ? 0.85 : 1.0)
            }
        }
        .frame(height: 52)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .opacity(isDisabled && !isWeekendInRange ? 0.35 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isInRange)
    }

    private var textColor: Color {
        if isSelected { return .white }
        if isToday { return Color(hex: "#1976FF") }
        if isInRange { return Color(hex: "#003087") }
        if isDisabled { return Color(hex: "#9AA5BE") }
        return Color(hex: "#0D1B3E")
    }
}

private struct RangoSeleccionadoCard: View {
    let startDate: Date
    let endDate: Date?
    let diasHabiles: Int
    let empleado: Empleado
    let onContinue: () -> Void

    private var diasDisponibles: Int { empleado.diasVacacionesDisponibles }
    private var tieneEndDate: Bool { endDate != nil }
    private var diasSuficientes: Bool { diasHabiles <= diasDisponibles }
    private var puedeEnviar: Bool { tieneEndDate && diasSuficientes && diasHabiles > 0 }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                dateSummary(label: "Inicio", value: startDate.formatted(.dateTime.day().month(.abbreviated)))

                VStack(spacing: 2) {
                    if tieneEndDate {
                        Text("\(diasHabiles) días")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(diasSuficientes ? Color(hex: "#1976FF") : Color(hex: "#F03E3E"))
                        Text("hábiles")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(Color(hex: "#9AA5BE"))
                    }
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "#9AA5BE"))
                }
                .frame(maxWidth: .infinity)

                dateSummary(label: "Fin", value: endDate.map { $0.formatted(.dateTime.day().month(.abbreviated)) } ?? "Selecciona...", alignment: .trailing)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            if tieneEndDate {
                Divider().opacity(0.3).padding(.horizontal, 16)

                VStack(spacing: 8) {
                    validationRow(
                        icon: diasSuficientes ? "checkmark.circle.fill" : "xmark.circle.fill",
                        color: diasSuficientes ? Color(hex: "#00C27C") : Color(hex: "#F03E3E"),
                        text: diasSuficientes
                            ? "Tienes \(diasDisponibles) días disponibles"
                            : "Solo tienes \(diasDisponibles) días; reduce \(diasHabiles - diasDisponibles)"
                    )
                    validationRow(
                        icon: "info.circle.fill",
                        color: Color(hex: "#1976FF"),
                        text: "Los fines de semana no cuentan como días hábiles"
                    )
                    if !diasSuficientes {
                        validationRow(
                            icon: "lightbulb.fill",
                            color: Color(hex: "#D97706"),
                            text: "Ajusta las fechas para usar máximo \(diasDisponibles) días hábiles"
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                Divider().opacity(0.3).padding(.horizontal, 16)

                Button(action: puedeEnviar ? onContinue : {}) {
                    HStack(spacing: 8) {
                        Text(puedeEnviar ? "Continuar solicitud" : "Ajusta las fechas")
                            .font(.system(size: 16, weight: .semibold))
                        if puedeEnviar {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(puedeEnviar ? AnyShapeStyle(Color(hex: "#003087")) : AnyShapeStyle(Color(hex: "#9AA5BE")))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: puedeEnviar ? Color(hex: "#1976FF").opacity(0.3) : .clear, radius: 10, x: 0, y: 4)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .disabled(!puedeEnviar)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color(hex: "#0D1B3E").opacity(0.07), radius: 16, x: 0, y: 4)
        .animation(.spring(response: 0.4), value: tieneEndDate)
    }

    private func dateSummary(label: String, value: String, alignment: HorizontalAlignment = .leading) -> some View {
        VStack(alignment: alignment, spacing: 3) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(hex: "#9AA5BE"))
                .tracking(0.5)
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(value == "Selecciona..." ? Color(hex: "#9AA5BE") : Color(hex: "#0D1B3E"))
        }
    }

    private func validationRow(icon: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 18)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#4B5675"))
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }
}

private struct SolicitudVacacionesFlow: View {
    let startDate: Date?
    let endDate: Date?
    let diasHabiles: Int
    let empleado: Empleado
    let motivoPreseleccionado: MotivoVacacion?

    @Environment(\.dismiss) private var dismiss
    @Environment(RewardService.self) private var rewardService
    @State private var step = 0
    @State private var motivo = ""
    @State private var tipoMotivo: MotivoVacacion
    @State private var isLoading = false
    @State private var showConfetti = false

    init(
        startDate: Date?,
        endDate: Date?,
        diasHabiles: Int,
        empleado: Empleado,
        motivoPreseleccionado: MotivoVacacion? = nil
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.diasHabiles = diasHabiles
        self.empleado = empleado
        self.motivoPreseleccionado = motivoPreseleccionado
        _tipoMotivo = State(initialValue: motivoPreseleccionado ?? .descanso)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: "#DDE3F0"))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                if step == 0 {
                    confirmStep
                } else if step == 1 {
                    motivoStep
                } else {
                    successStep
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: step)

            if showConfetti {
                VacationConfetti()
            }
        }
    }

    private var confirmStep: some View {
        VStack(spacing: 24) {
            Text("Confirma tu solicitud")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "#0D1B3E"))

            HStack(spacing: 0) {
                dateBlock(label: "Inicio", date: startDate?.formatted(.dateTime.day().month(.wide)) ?? "—")
                VStack(spacing: 4) {
                    Text("\(diasHabiles)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#003087"))
                        .contentTransition(.numericText())
                    Text("días hábiles")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#9AA5BE"))
                }
                .frame(maxWidth: .infinity)
                dateBlock(
                    label: "Regreso",
                    date: endDate.flatMap { Calendar.current.date(byAdding: .day, value: 1, to: $0) }?.formatted(.dateTime.day().month(.wide)) ?? "—"
                )
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(Color(hex: "#EFF3FA"))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 20)

            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(Color(hex: "#1976FF"))
                Text("Quedarán \(max(empleado.diasVacacionesDisponibles - diasHabiles, 0)) días disponibles tras esta solicitud")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#4B5675"))
            }
            .padding(.horizontal, 20)

            Spacer()

            VStack(spacing: 10) {
                Button {
                    withAnimation { step = 1 }
                } label: {
                    Text("Continuar")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(hex: "#003087"))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: Color(hex: "#1976FF").opacity(0.3), radius: 10, x: 0, y: 4)
                }
                .disabled(startDate == nil || endDate == nil || diasHabiles == 0)
                .opacity(startDate == nil || endDate == nil || diasHabiles == 0 ? 0.45 : 1)

                Button("Cancelar") { dismiss() }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "#9AA5BE"))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }

    private var motivoStep: some View {
        VStack(spacing: 20) {
            Text("¿Cuál es el motivo?")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "#0D1B3E"))
            Text("Opcional; ayuda a RH a gestionar tu solicitud")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#9AA5BE"))
                .multilineTextAlignment(.center)

            if let motivoPreseleccionado {
                SelectedMotivoSummary(motivo: motivoPreseleccionado)
                    .padding(.horizontal, 20)
            } else {
                MotivoSelectorGrid(selected: $tipoMotivo)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Nota adicional")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#4B5675"))
                TextEditor(text: $motivo)
                    .frame(height: 80)
                    .padding(10)
                    .background(Color(hex: "#F8F9FC"))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color(hex: "#DDE3F0"), lineWidth: 1)
                    }
                    .overlay(alignment: .topLeading) {
                        if motivo.isEmpty {
                            Text("Escribe algo si lo deseas...")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#9AA5BE"))
                                .padding(16)
                                .allowsHitTesting(false)
                        }
                    }
            }
            .padding(.horizontal, 20)

            Spacer()

            VStack(spacing: 10) {
                Button {
                    enviarSolicitud()
                } label: {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Enviar solicitud")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color(hex: "#003087"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: Color(hex: "#1976FF").opacity(0.3), radius: 10, x: 0, y: 4)

                Button("Atrás") { withAnimation { step = 0 } }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "#9AA5BE"))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }

    private var successStep: some View {
        VStack(spacing: 20) {
            Spacer()
            LottieView(name: "success_check", loopMode: .playOnce)
                .frame(width: 120, height: 120)

            Text("¡Solicitud enviada!")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#0D1B3E"))
            Text("Tu solicitud fue recibida por RH.\nTe notificaremos cuando sea aprobada.")
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "#4B5675"))
                .multilineTextAlignment(.center)

            VStack(spacing: 8) {
                resumenRow(label: "Período", value: "\(startDate?.formatted(.dateTime.day().month(.abbreviated)) ?? "—") – \(endDate?.formatted(.dateTime.day().month(.abbreviated)) ?? "—")")
                resumenRow(label: "Días hábiles", value: "\(diasHabiles)")
                resumenRow(label: "Motivo", value: tipoMotivo.label)
                resumenRow(label: "Estatus", value: "Pendiente de aprobación")
            }
            .padding(16)
            .background(Color(hex: "#EFF3FA"))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 20)

            Spacer()

            Button("Listo") { dismiss() }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color(hex: "#003087"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
        }
    }

    private func dateBlock(label: String, date: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(hex: "#9AA5BE"))
            Text(date)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(hex: "#0D1B3E"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private func resumenRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#9AA5BE"))
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "#0D1B3E"))
        }
    }

    private func enviarSolicitud() {
        isLoading = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            rewardService.ganarPuntos(
                tipo: .solicitudCompletada,
                descripcion: "Solicitud de vacaciones enviada"
            )
            withAnimation(.spring(response: 0.5)) {
                step = 2
                showConfetti = true
            }
        }
    }
}

private enum MotivoVacacion: CaseIterable {
    case descanso
    case viaje
    case familia
    case salud
    case tramites
    case otro

    var label: String {
        switch self {
        case .descanso: "Descanso"
        case .viaje: "Viaje"
        case .familia: "Familia"
        case .salud: "Salud"
        case .tramites: "Trámites"
        case .otro: "Otro"
        }
    }

    var icon: String {
        switch self {
        case .descanso: "moon.zzz.fill"
        case .viaje: "airplane"
        case .familia: "figure.2.and.child.holdinghands"
        case .salud: "cross.fill"
        case .tramites: "doc.text.fill"
        case .otro: "ellipsis.circle.fill"
        }
    }
}

private struct MotivoQuickPick: View {
    @Binding var selected: MotivoVacacion?
    let onSelect: () -> Void
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("¿Cuál es el motivo de tus vacaciones?")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "#0D1B3E"))

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(MotivoVacacion.allCases, id: \.self) { motivo in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                            selected = motivo
                        }
                        Haptics.impact(.medium)
                        onSelect()
                    } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(selected == motivo ? motivo.color : motivo.color.opacity(0.1))
                                    .frame(width: 44, height: 44)
                                Image(systemName: motivo.icon)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(selected == motivo ? .white : motivo.color)
                            }
                            .scaleEffect(selected == motivo ? 1.08 : 1.0)

                            Text(motivo.labelCorto)
                                .font(.system(size: 11, weight: selected == motivo ? .bold : .medium))
                                .foregroundColor(selected == motivo ? motivo.color : Color(hex: "#6B7280"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: selected)
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color(hex: "#0D1B3E").opacity(0.05), radius: 10, x: 0, y: 3)
    }
}

private struct SelectedMotivoSummary: View {
    let motivo: MotivoVacacion

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(motivo.color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: motivo.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(motivo.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Motivo seleccionado")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#9AA5BE"))
                Text(motivo.label)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "#0D1B3E"))
            }

            Spacer()
        }
        .padding(14)
        .background(motivo.color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(motivo.color.opacity(0.16), lineWidth: 1)
        }
    }
}

private struct MotivoSelectorGrid: View {
    @Binding var selected: MotivoVacacion
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(MotivoVacacion.allCases, id: \.self) { motivo in
                MotivoCard(
                    motivo: motivo,
                    isSelected: selected == motivo,
                    onTap: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            selected = motivo
                        }
                        Haptics.impact(.medium)
                    }
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct MotivoCard: View {
    let motivo: MotivoVacacion
    let isSelected: Bool
    let onTap: () -> Void

    @State private var iconAnimate = false
    @State private var particles: [ParticleData] = []

    var body: some View {
        Button {
            onTap()
            triggerAnimation()
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isSelected ? motivo.color : motivo.color.opacity(0.12))
                        .frame(width: 52, height: 52)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                        .shadow(color: isSelected ? motivo.color.opacity(0.5) : .clear, radius: 10, x: 0, y: 4)

                    Image(systemName: motivo.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isSelected ? .white : motivo.color)
                        .rotationEffect(motivo.iconRotation(animating: iconAnimate))
                        .scaleEffect(iconAnimate ? 1.2 : 1.0)

                    ForEach(particles) { particle in
                        Circle()
                            .fill(motivo.color)
                            .frame(width: particle.size, height: particle.size)
                            .offset(particle.offset)
                            .opacity(particle.opacity)
                    }
                }

                Text(motivo.label)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? motivo.color : Color(hex: "#4B5675"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? motivo.color.opacity(0.08) : Color(hex: "#F8F9FC"))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(isSelected ? motivo.color : Color(hex: "#DDE3F0"), lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isSelected)
    }

    private func triggerAnimation() {
        withAnimation(motivo.iconAnimation) {
            iconAnimate = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation { iconAnimate = false }
        }

        particles = (0..<6).map { _ in
            ParticleData(id: UUID(), offset: .zero, size: CGFloat.random(in: 3...6), opacity: 1)
        }

        withAnimation(.spring(response: 0.4)) {
            particles = particles.enumerated().map { index, particle in
                let angle = Double(index) * 60.0 * .pi / 180
                let distance = CGFloat.random(in: 20...35)
                return ParticleData(
                    id: particle.id,
                    offset: CGSize(width: cos(angle) * distance, height: sin(angle) * distance),
                    size: particle.size,
                    opacity: 0
                )
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            particles = []
        }
    }
}

private struct ParticleData: Identifiable {
    let id: UUID
    var offset: CGSize
    var size: CGFloat
    var opacity: Double
}

private extension MotivoVacacion {
    var labelCorto: String {
        switch self {
        case .descanso: "Descanso"
        case .viaje: "Viaje"
        case .familia: "Familia"
        case .salud: "Salud"
        case .tramites: "Trámites"
        case .otro: "Otro"
        }
    }

    var color: Color {
        switch self {
        case .descanso: Color(hex: "#7C5CFC")
        case .viaje: Color(hex: "#0EA5E9")
        case .familia: Color(hex: "#EC4899")
        case .salud: Color(hex: "#00C27C")
        case .tramites: Color(hex: "#D97706")
        case .otro: Color(hex: "#6B7280")
        }
    }

    var iconAnimation: Animation {
        switch self {
        case .descanso: .easeInOut(duration: 0.5)
        case .viaje: .spring(response: 0.3, dampingFraction: 0.4)
        case .familia: .easeInOut(duration: 0.4)
        case .salud: .spring(response: 0.25)
        case .tramites: .easeOut(duration: 0.3)
        case .otro: .default
        }
    }

    func iconRotation(animating: Bool) -> Angle {
        guard animating else { return .zero }
        switch self {
        case .descanso: return Angle.degrees(20)
        case .viaje: return Angle.degrees(-15)
        case .familia: return Angle.degrees(10)
        case .salud: return Angle.degrees(0)
        case .tramites: return Angle.degrees(5)
        case .otro: return Angle.degrees(0)
        }
    }
}

private struct MotivacionSceneView: View {
    let motivo: MotivoVacacion
    let diasHabiles: Int
    let hasFullRange: Bool

    var body: some View {
        ZStack {
            switch motivo {
            case .descanso:
                DescansoScene(dias: diasHabiles, full: hasFullRange)
            case .viaje:
                ViajeScene(dias: diasHabiles, full: hasFullRange)
            case .familia:
                FamiliaScene(dias: diasHabiles, full: hasFullRange)
            case .salud:
                SaludScene(dias: diasHabiles, full: hasFullRange)
            case .tramites:
                TramitesScene(dias: diasHabiles, full: hasFullRange)
            case .otro:
                DescansoScene(dias: diasHabiles, full: hasFullRange)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: motivo.color.opacity(0.18), radius: 12, x: 0, y: 5)
        .animation(.spring(response: 0.5), value: motivo)
    }
}

private struct DescansoScene: View {
    let dias: Int
    let full: Bool

    @State private var waveOffset: CGFloat = 0
    @State private var hamacaSway: Double = 0
    @State private var lunaY: CGFloat = 0
    @State private var starOpacity: [Double] = Array(repeating: 0, count: 8)

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(hex: "#0F1B3D"), Color(hex: "#1E3A5F"), Color(hex: "#2D6A8F")],
                startPoint: .top,
                endPoint: .bottom
            )

            if full {
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(Color.white)
                        .frame(width: CGFloat(2 + index % 3), height: CGFloat(2 + index % 3))
                        .offset(
                            x: CGFloat([-132, -92, -44, 0, 36, 76, 112, 148][index]),
                            y: CGFloat([-58, -72, -48, -65, -54, -42, -70, -50][index])
                        )
                        .opacity(starOpacity[index])
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.4 + Double(index % 3) * 0.4).repeatForever(autoreverses: true).delay(Double(index) * 0.18)) {
                                starOpacity[index] = 1
                            }
                        }
                }

                HamacaView(sway: hamacaSway)
                    .offset(y: -32)
            }

            Circle()
                .fill(Color(hex: "#FFF9C4"))
                .frame(width: 40, height: 40)
                .overlay {
                    Circle()
                        .fill(Color(hex: "#1E3A5F"))
                        .frame(width: 32, height: 32)
                        .offset(x: -6, y: -4)
                }
                .offset(x: 102, y: -lunaY - 58)
                .onAppear {
                    withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        lunaY = 8
                    }
                }

            SiluetaPalmera(side: .left)
            SiluetaPalmera(side: .right)

            WaveView(offset: waveOffset, color: Color(hex: "#1565C0").opacity(0.5))
                .frame(height: 30)
                .offset(y: -10)
            WaveView(offset: waveOffset * 0.6, color: Color(hex: "#0D47A1").opacity(0.4))
                .frame(height: 25)
                .offset(y: -6)

            Rectangle()
                .fill(Color(hex: "#8D7B6A"))
                .frame(height: 20)

            SceneDayCounter(dias: dias, color: .white, label: "días de descanso")
        }
        .onAppear {
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                waveOffset = -200
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                hamacaSway = 10
            }
        }
    }
}

private struct ViajeScene: View {
    let dias: Int
    let full: Bool

    @State private var airplaneX: CGFloat = -250
    @State private var waveOffset: CGFloat = 0
    @State private var cloudOffset1: CGFloat = 0
    @State private var cloudOffset2: CGFloat = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(hex: "#1565C0"), Color(hex: "#42A5F5"), Color(hex: "#90CAF9")],
                startPoint: .top,
                endPoint: .bottom
            )

            CloudShape()
                .fill(Color.white.opacity(0.85))
                .frame(width: 80, height: 35)
                .offset(x: -110 + cloudOffset1, y: -72)

            CloudShape()
                .fill(Color.white.opacity(0.7))
                .frame(width: 55, height: 25)
                .offset(x: 44 + cloudOffset2, y: -54)

            CiudadSilueta()
                .offset(y: -18)

            if full {
                Image(systemName: "airplane")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.18), radius: 4, x: 0, y: 2)
                    .offset(x: airplaneX, y: -66)
            }

            WaveView(offset: waveOffset, color: Color(hex: "#1976FF").opacity(0.6))
                .frame(height: 30)
                .offset(y: -10)
            WaveView(offset: waveOffset * 0.7, color: Color(hex: "#42A5F5").opacity(0.4))
                .frame(height: 25)
                .offset(y: -6)

            Rectangle()
                .fill(Color(hex: "#F5DEB3"))
                .frame(height: 20)

            SceneDayCounter(dias: dias, color: .white, label: "días para viajar")
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                waveOffset = -200
            }
            withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                cloudOffset1 = 350
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false).delay(3)) {
                cloudOffset2 = 350
            }
            withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: false)) {
                airplaneX = 250
            }
        }
    }
}

private struct FamiliaScene: View {
    let dias: Int
    let full: Bool

    @State private var waveOffset: CGFloat = 0
    @State private var sunY: CGFloat = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(hex: "#FF8A65"), Color(hex: "#FFB74D"), Color(hex: "#FFF9C4")],
                startPoint: .top,
                endPoint: .bottom
            )

            ZStack {
                ForEach(0..<8, id: \.self) { index in
                    Rectangle()
                        .fill(Color(hex: "#FFD700").opacity(0.55))
                        .frame(width: 2, height: 14)
                        .offset(y: -28)
                        .rotationEffect(.degrees(Double(index) * 45))
                }
                Circle()
                    .fill(Color(hex: "#FFD700"))
                    .frame(width: 36, height: 36)
            }
            .offset(x: -104, y: -sunY - 58)

            if full {
                HStack(spacing: 8) {
                    FiguraPersona(altura: 42, color: Color(hex: "#5C3BC1"))
                    FiguraPersona(altura: 28, color: Color(hex: "#EC4899"))
                    FiguraPersona(altura: 40, color: Color(hex: "#003087"))
                }
                .offset(y: -24)
            }

            BeachUmbrellaView()
                .frame(width: 60, height: 55)
                .offset(x: 82, y: -14)

            WaveView(offset: waveOffset, color: Color(hex: "#29B6F6").opacity(0.7))
                .frame(height: 35)
                .offset(y: -14)
            WaveView(offset: waveOffset * 0.6, color: Color(hex: "#0288D1").opacity(0.5))
                .frame(height: 28)
                .offset(y: -10)

            Rectangle()
                .fill(Color(hex: "#F5DEB3"))
                .frame(height: 24)

            SceneDayCounter(dias: dias, color: Color(hex: "#0D1B3E"), label: "días en familia")
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                waveOffset = -200
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                sunY = 5
            }
        }
    }
}

private struct SaludScene: View {
    let dias: Int
    let full: Bool

    @State private var birdOffset: CGFloat = -220
    @State private var waveOffset: CGFloat = 0
    @State private var treeScale: CGFloat = 0.85

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(hex: "#1B5E20"), Color(hex: "#388E3C"), Color(hex: "#81C784")],
                startPoint: .top,
                endPoint: .bottom
            )

            MountainSilhouette(x: -70, height: 78, color: Color(hex: "#2E7D32"))
            MountainSilhouette(x: 64, height: 64, color: Color(hex: "#388E3C"))
            MountainSilhouette(x: 0, height: 92, color: Color(hex: "#1B5E20"))

            if full {
                HStack(spacing: 10) {
                    ForEach(0..<4, id: \.self) { index in
                        Image(systemName: "bird")
                            .font(.system(size: 10 + CGFloat(index % 2) * 3))
                            .foregroundColor(.white.opacity(0.8))
                            .offset(y: CGFloat(index % 2 == 0 ? -5 : 0))
                    }
                }
                .offset(x: birdOffset, y: -62)
            }

            HStack(spacing: 20) {
                ArbolSimple(color: Color(hex: "#1B5E20"))
                ArbolSimple(color: Color(hex: "#2E7D32"))
                ArbolSimple(color: Color(hex: "#388E3C"))
            }
            .scaleEffect(treeScale)
            .offset(y: -14)

            WaveView(offset: waveOffset, color: Color(hex: "#29B6F6").opacity(0.5))
                .frame(height: 20)
                .offset(y: -8)

            Rectangle()
                .fill(Color(hex: "#33691E"))
                .frame(height: 20)

            SceneDayCounter(dias: dias, color: .white, label: "días para cuidarte")
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                waveOffset = -200
            }
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                birdOffset = 250
            }
            withAnimation(.spring(response: 1, dampingFraction: 0.65)) {
                treeScale = 1
            }
        }
    }
}

private struct TramitesScene: View {
    let dias: Int
    let full: Bool

    @State private var carOffset: CGFloat = -220

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(hex: "#4A148C"), Color(hex: "#7B1FA2"), Color(hex: "#CE93D8")],
                startPoint: .top,
                endPoint: .bottom
            )

            CiudadSilueta()
                .offset(y: -10)

            if full {
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color(hex: "#1565C0"))
                        .frame(width: 38, height: 14)
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color(hex: "#64B5F6"))
                        .frame(width: 18, height: 9)
                        .offset(x: 4, y: -9)
                    HStack(spacing: 20) {
                        Circle().fill(Color(hex: "#0D1B3E")).frame(width: 6, height: 6)
                        Circle().fill(Color(hex: "#0D1B3E")).frame(width: 6, height: 6)
                    }
                    .offset(y: 3)
                }
                .offset(x: carOffset, y: -20)
            }

            Rectangle()
                .fill(Color(hex: "#263238"))
                .frame(height: 22)

            HStack(spacing: 20) {
                ForEach(0..<6, id: \.self) { _ in
                    Rectangle()
                        .fill(Color(hex: "#FFD700").opacity(0.55))
                        .frame(width: 20, height: 3)
                }
            }
            .offset(y: -11)

            SceneDayCounter(dias: dias, color: .white, label: "días de trámite")
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                carOffset = 250
            }
        }
    }
}

private struct SceneDayCounter: View {
    let dias: Int
    let color: Color
    let label: String

    var body: some View {
        if dias > 0 {
            VStack(spacing: 1) {
                Text("\(dias)")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(color)
                    .shadow(color: .black.opacity(0.18), radius: 3, x: 0, y: 1)
                    .contentTransition(.numericText())
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(color.opacity(0.85))
                    .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 1)
            }
            .offset(x: -58, y: -76)
            .animation(.spring(response: 0.4), value: dias)
        }
    }
}

private struct HamacaView: View {
    let sway: Double

    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: -62, y: -20))
                path.addLine(to: CGPoint(x: -22, y: 10))
            }
            .stroke(Color(hex: "#8B6914"), lineWidth: 2)

            Path { path in
                path.move(to: CGPoint(x: 62, y: -20))
                path.addLine(to: CGPoint(x: 22, y: 10))
            }
            .stroke(Color(hex: "#8B6914"), lineWidth: 2)

            Path { path in
                path.move(to: CGPoint(x: -24, y: 10))
                path.addQuadCurve(to: CGPoint(x: 24, y: 10), control: CGPoint(x: 0, y: 26))
            }
            .stroke(Color(hex: "#E57373"), lineWidth: 10)
            .rotationEffect(.degrees(sway * 0.35), anchor: UnitPoint(x: 0.5, y: 0))
        }
    }
}

private enum PalmeraSide {
    case left
    case right
}

private struct SiluetaPalmera: View {
    let side: PalmeraSide

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color(hex: "#0D2137"))
                .frame(width: 6, height: 50)
                .rotationEffect(.degrees(side == .left ? -8 : 8), anchor: .bottom)

            ForEach(0..<4, id: \.self) { index in
                Ellipse()
                    .fill(Color(hex: "#0D2137"))
                    .frame(width: 28, height: 10)
                    .offset(
                        x: side == .left ? CGFloat(index % 2 == 0 ? 8 : -8) : CGFloat(index % 2 == 0 ? -8 : 8),
                        y: -46
                    )
                    .rotationEffect(.degrees(Double(index) * 40 - 60))
            }
        }
        .offset(x: side == .left ? -130 : 130, y: 10)
    }
}

private struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addEllipse(in: CGRect(x: rect.minX + 5, y: rect.midY, width: rect.width * 0.5, height: rect.height * 0.5))
            path.addEllipse(in: CGRect(x: rect.minX + 20, y: rect.minY + 4, width: rect.width * 0.45, height: rect.height * 0.6))
            path.addEllipse(in: CGRect(x: rect.midX, y: rect.midY, width: rect.width * 0.5, height: rect.height * 0.5))
        }
    }
}

private struct CiudadSilueta: View {
    private let edificios: [(width: CGFloat, height: CGFloat, x: CGFloat)] = [
        (12, 40, -120), (8, 55, -106), (16, 35, -96), (10, 65, -78),
        (14, 45, -62), (20, 30, -44), (10, 50, -22), (12, 42, -8),
        (18, 60, 12), (8, 38, 32), (14, 50, 48), (10, 35, 64),
        (16, 55, 80), (12, 40, 98), (8, 48, 112)
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            ForEach(edificios.indices, id: \.self) { index in
                let edificio = edificios[index]
                VStack(spacing: 0) {
                    if index % 3 == 0 {
                        Rectangle()
                            .fill(Color(hex: "#0D2137"))
                            .frame(width: 1.5, height: 8)
                    }
                    Rectangle()
                        .fill(Color(hex: "#0D2137").opacity(0.86))
                        .frame(width: edificio.width, height: edificio.height)
                        .overlay {
                            VStack(spacing: 4) {
                                ForEach(0..<max(Int(edificio.height / 12), 1), id: \.self) { row in
                                    HStack(spacing: 3) {
                                        ForEach(0..<max(Int(edificio.width / 6), 1), id: \.self) { column in
                                            Rectangle()
                                                .fill(Color(hex: "#FFD700").opacity((row + column + index).isMultiple(of: 2) ? 0.75 : 0.28))
                                                .frame(width: 2, height: 2)
                                        }
                                    }
                                }
                            }
                        }
                }
                .offset(x: edificio.x)
            }
        }
    }
}

private struct FiguraPersona: View {
    let altura: CGFloat
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Circle()
                .fill(color)
                .frame(width: altura * 0.35, height: altura * 0.35)
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(color)
                .frame(width: altura * 0.28, height: altura * 0.5)
        }
    }
}

private struct MountainSilhouette: View {
    let x: CGFloat
    let height: CGFloat
    let color: Color

    var body: some View {
        Triangle()
            .fill(color)
            .frame(width: height * 1.4, height: height)
            .offset(x: x, y: -height / 2 + 15)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

private struct ArbolSimple: View {
    let color: Color

    var body: some View {
        VStack(spacing: 0) {
            Triangle()
                .fill(color)
                .frame(width: 22, height: 28)
            Triangle()
                .fill(color)
                .frame(width: 28, height: 22)
                .offset(y: -8)
            Rectangle()
                .fill(Color(hex: "#5D4037"))
                .frame(width: 5, height: 10)
        }
    }
}

private struct WaveView: View {
    var offset: CGFloat
    var color: Color

    var body: some View {
        GeometryReader { geo in
            Path { path in
                let width = geo.size.width
                let height = geo.size.height
                let midHeight = height * 0.5
                let wavelength = width * 0.5

                path.move(to: CGPoint(x: 0, y: midHeight))
                for x in stride(from: 0, through: width, by: 1) {
                    let relX = (x + offset).truncatingRemainder(dividingBy: wavelength)
                    let y = midHeight + sin((relX / wavelength) * 2 * .pi) * 8
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                path.addLine(to: CGPoint(x: width, y: height))
                path.addLine(to: CGPoint(x: 0, y: height))
                path.closeSubpath()
            }
            .fill(color)
        }
    }
}

private struct PalmTreeView: View {
    var sway: Double

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color(hex: "#8B6914"))
                .frame(width: 8, height: 60)
                .rotationEffect(.degrees(sway * 0.3), anchor: .bottom)

            ForEach(0..<5, id: \.self) { index in
                Ellipse()
                    .fill(Color(hex: "#2D7D2D"))
                    .frame(width: 30, height: 12)
                    .offset(x: CGFloat(index % 2 == 0 ? 10 : -10), y: -55 + CGFloat(index) * 3)
                    .rotationEffect(.degrees(Double(index) * 36 + sway), anchor: UnitPoint(x: 0, y: 0.5))
            }
        }
    }
}

private struct BeachUmbrellaView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color(hex: "#8B6914"))
                .frame(width: 3, height: 40)
                .rotationEffect(.degrees(15), anchor: .bottom)

            HalfCircleStriped()
                .frame(width: 50, height: 25)
                .offset(x: 8, y: -28)
                .rotationEffect(.degrees(15), anchor: .bottom)
        }
    }
}

private struct HalfCircleStriped: View {
    var body: some View {
        ZStack {
            HalfCircle()
                .fill(Color(hex: "#1565C0"))

            HStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { index in
                    Rectangle()
                        .fill(index.isMultiple(of: 2) ? Color.white.opacity(0.82) : Color.clear)
                        .frame(maxWidth: .infinity)
                }
            }
            .mask(HalfCircle())
        }
    }
}

private struct HalfCircle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addArc(
                center: CGPoint(x: rect.midX, y: rect.maxY),
                radius: rect.width / 2,
                startAngle: .degrees(180),
                endAngle: .degrees(0),
                clockwise: false
            )
            path.closeSubpath()
        }
    }
}

private struct VacationConfetti: View {
    @State private var burst = false

    var body: some View {
        ZStack {
            ForEach(0..<28, id: \.self) { index in
                Circle()
                    .fill([Color.mabeBlue, Color.mabeElectric, Color.mabeSuccess, .white][index % 4])
                    .frame(width: 7, height: 7)
                    .offset(
                        x: burst ? CGFloat((index % 7) - 3) * 24 : 0,
                        y: burst ? -CGFloat(70 + (index % 6) * 24) : 0
                    )
                    .opacity(burst ? 0 : 1)
                    .animation(.easeOut(duration: 1.0).delay(Double(index) * 0.02), value: burst)
            }
        }
        .onAppear { burst = true }
        .allowsHitTesting(false)
    }
}
