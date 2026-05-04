import SwiftUI

struct VacacionesView: View {
    @State private var viewModel: VacacionesViewModel

    init(empleado: Empleado) {
        _viewModel = State(initialValue: VacacionesViewModel(empleado: empleado))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    summaryCard
                    calendarCard
                    historySection
                }
                .padding(MabeTheme.horizontalPadding)
                .padding(.bottom, 88)
            }
            .background(Color.mabeGray100)

            Button {
                viewModel.showingSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 58, height: 58)
                    .background(Color.mabeBlue)
                    .clipShape(Circle())
                    .mabeCardShadow()
            }
            .padding(24)
            .accessibilityLabel("Nueva solicitud de vacaciones")
        }
        .navigationTitle("Mis Vacaciones")
        .mabeNavigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $viewModel.showingSheet) {
            NuevaSolicitudVacacionesSheet(viewModel: viewModel)
        }
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
    }

    private var calendarCard: some View {
        MabeCard {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.monthTitle)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.mabeGray900)

                CustomMonthCalendar(selectedDates: viewModel.selectedDates) { components in
                    viewModel.toggle(components)
                }
            }
        }
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

private struct CustomMonthCalendar: View {
    let selectedDates: Set<DateComponents>
    let onTap: (DateComponents) -> Void

    private let calendar = Calendar.current
    private let weekdaySymbols = ["L", "M", "M", "J", "V", "S", "D"]

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.mabeGray500)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(Array(daysForCurrentMonth().enumerated()), id: \.offset) { _, components in
                    if let day = components.day {
                        let isSelected = selectedDates.contains(components)
                        Button {
                            onTap(components)
                        } label: {
                            Text("\(day)")
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(isSelected ? .white : Color.mabeGray900)
                                .frame(maxWidth: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                                .background(isSelected ? Color.mabeBlue : Color.mabeGray100)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Día \(day)")
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
    }

    private func daysForCurrentMonth() -> [DateComponents] {
        let now = Date()
        guard
            let interval = calendar.dateInterval(of: .month, for: now),
            let daysRange = calendar.range(of: .day, in: .month, for: now)
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: interval.start)
        let mondayOffset = (firstWeekday + 5) % 7
        var values = Array(repeating: DateComponents(), count: mondayOffset)

        for day in daysRange {
            var components = calendar.dateComponents([.year, .month], from: now)
            components.day = day
            values.append(components)
        }

        return values
    }
}

private struct NuevaSolicitudVacacionesSheet: View {
    @Bindable var viewModel: VacacionesViewModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                MabeCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Fechas seleccionadas")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.mabeGray900)
                        Text(viewModel.selectedDates.isEmpty ? "Elige días en el calendario antes de enviar." : "\(viewModel.selectedDates.count) día(s) seleccionados")
                            .font(.subheadline)
                            .foregroundStyle(Color.mabeGray500)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Motivo opcional")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.mabeGray500)
                    TextField("Ej. viaje familiar", text: $viewModel.motivo, axis: .vertical)
                        .font(.body)
                        .padding(14)
                        .frame(minHeight: 92, alignment: .topLeading)
                        .background(Color.mabeGray100)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10).stroke(Color.mabeGray200, lineWidth: 1)
                        }
                }

                Spacer()

                MabePrimaryButton(title: "Enviar solicitud", isDisabled: viewModel.selectedDates.isEmpty) {
                    viewModel.enviarSolicitud()
                }
            }
            .padding(MabeTheme.horizontalPadding)
            .background(Color.mabeGray100)
            .navigationTitle("Nueva solicitud")
            .mabeNavigationBarTitleDisplayMode(.inline)
        }
    }
}
