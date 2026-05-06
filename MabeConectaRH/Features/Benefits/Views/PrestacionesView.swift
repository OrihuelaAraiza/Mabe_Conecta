import SwiftUI

struct PrestacionesView: View {
    @State private var selectedCategoria: CategoriaPrestacion?
    @State private var selectedPrestacion: Prestacion?
    @Environment(\.dismiss) private var dismiss

    private var prestacionesFiltradas: [Prestacion] {
        guard let selectedCategoria else { return MockDataService.prestaciones }
        return MockDataService.prestaciones.filter { $0.categoria == selectedCategoria }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 16) {
                    ValorTotalCard()
                    CategoriasFilter(selected: $selectedCategoria)
                    PrestacionesGrid(prestaciones: prestacionesFiltradas) { prestacion in
                        selectedPrestacion = prestacion
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 100)
            }
        }
        .navigationBarHidden(true)
        .background(Color(hex: "#F8F9FC"))
        .sheet(item: $selectedPrestacion) { prestacion in
            PrestacionDetailSheet(prestacion: prestacion)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
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

            Text("Mis Prestaciones")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "#0D1B3E"))

            Spacer()

            Button {
                Haptics.impact(.light)
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "#003087"))
                    .frame(width: 36, height: 36)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(Color(hex: "#F8F9FC"))
    }
}

private struct ValorTotalCard: View {
    private let salarioMensualEjemplo: Double = 15_000

    private var aguinaldoValor: Double { salarioMensualEjemplo }
    private var fondoValor: Double { salarioMensualEjemplo * 12 * 0.125 }
    private var valesValor: Double { salarioMensualEjemplo * 12 * 0.08 }
    private var totalAdicionalAnual: Double { aguinaldoValor + fondoValor + valesValor }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [Color(hex: "#003087"), Color(hex: "#1976FF")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: 120, height: 120)
                    .offset(x: 250, y: 30)
                Circle()
                    .fill(.white.opacity(0.04))
                    .frame(width: 80, height: 80)
                    .offset(x: 300, y: -20)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Tu paquete total de compensación")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                    Text("Vale más de lo que ves en tu nómina")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(16)
            }
            .frame(height: 100)
            .clipped()

            HStack(spacing: 0) {
                statItem(valor: "\(MockDataService.numPrestaciones)", label: "prestaciones", color: Color(hex: "#003087"))
                Divider().frame(height: 40)
                statItem(valor: "+50%", label: "sobre ley", color: Color(hex: "#00C27C"))
                Divider().frame(height: 40)
                statItem(valor: "~$\(Int(totalAdicionalAnual / 1000))K", label: "valor anual", color: Color(hex: "#7C5CFC"))
            }
            .padding(.vertical, 14)
            .background(Color.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color(hex: "#003087").opacity(0.2), radius: 16, x: 0, y: 6)
    }

    private func statItem(valor: String, label: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(valor)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .contentTransition(.numericText())
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "#9AA5BE"))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct CategoriasFilter: View {
    @Binding var selected: CategoriaPrestacion?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                PrestacionCategoryChip(
                    title: "Todas",
                    icon: "square.grid.2x2.fill",
                    color: Color(hex: "#003087"),
                    isSelected: selected == nil
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selected = nil
                    }
                }

                ForEach(CategoriaPrestacion.allCases, id: \.self) { categoria in
                    PrestacionCategoryChip(
                        title: categoria.rawValue,
                        icon: categoria.icon,
                        color: categoria.color,
                        isSelected: selected == categoria
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selected = selected == categoria ? nil : categoria
                        }
                        Haptics.impact(.light)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 2)
        }
        .padding(.horizontal, -20)
    }
}

private struct PrestacionCategoryChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? color : color.opacity(0.1))
            .clipShape(Capsule())
            .overlay {
                Capsule().strokeBorder(isSelected ? Color.clear : color.opacity(0.2), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
    }
}

private struct PrestacionesGrid: View {
    let prestaciones: [Prestacion]
    let onTap: (Prestacion) -> Void

    var body: some View {
        VStack(spacing: 10) {
            ForEach(CategoriaPrestacion.allCases, id: \.self) { categoria in
                let items = prestaciones.filter { $0.categoria == categoria }
                if !items.isEmpty {
                    let destacadas = items.filter(\.esDestacada)
                    let normales = items.filter { !$0.esDestacada }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: categoria.icon)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(categoria.color)
                            Text(categoria.rawValue.uppercased())
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(categoria.color)
                                .tracking(0.5)
                        }
                        .padding(.top, 4)

                        ForEach(destacadas) { prestacion in
                            PrestacionCard(prestacion: prestacion) {
                                onTap(prestacion)
                            }
                        }

                        if !normales.isEmpty {
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 10),
                                    GridItem(.flexible(), spacing: 10)
                                ],
                                spacing: 10
                            ) {
                                ForEach(normales) { prestacion in
                                    PrestacionCard(prestacion: prestacion) {
                                        onTap(prestacion)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 6)
                }
            }
        }
    }
}

private struct PrestacionCard: View {
    let prestacion: Prestacion
    let onTap: () -> Void

    private var isWide: Bool { prestacion.esDestacada }

    var body: some View {
        Button(action: onTap) {
            Group {
                if isWide {
                    HStack(spacing: 14) {
                        iconView
                        VStack(alignment: .leading, spacing: 4) {
                            Text(prestacion.nombre)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "#0D1B3E"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                            Text(prestacion.descripcion)
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#4B5675"))
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                            bottomRow
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "#DDE3F0"))
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, minHeight: 94, alignment: .leading)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        iconView
                        Text(prestacion.nombre)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "#0D1B3E"))
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)
                            .frame(minHeight: 34, alignment: .topLeading)
                        Text(prestacion.valor)
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundColor(prestacion.color)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)
                            .fixedSize(horizontal: false, vertical: true)
                        if let vsLey = prestacion.vsLey {
                            Text(vsLey)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(hex: "#9AA5BE"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        if let badge = prestacion.badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(prestacion.color)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(prestacion.color.opacity(0.1))
                                .clipShape(Capsule())
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, minHeight: 166, alignment: .topLeading)
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color(hex: "#DDE3F0"), lineWidth: 0.5)
            }
            .shadow(color: Color(hex: "#0D1B3E").opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(MabePressButtonStyle(scale: 0.97))
    }

    private var iconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(prestacion.color.opacity(0.12))
                .frame(width: isWide ? 44 : 38, height: isWide ? 44 : 38)
            Image(systemName: prestacion.icon)
                .font(.system(size: isWide ? 19 : 17, weight: .semibold))
                .foregroundColor(prestacion.color)
        }
    }

    private var bottomRow: some View {
        HStack(spacing: 8) {
            Text(prestacion.valor)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundColor(prestacion.color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            if let vsLey = prestacion.vsLey {
                Text(vsLey)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#9AA5BE"))
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
            if let badge = prestacion.badge {
                Text(badge)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(prestacion.color)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(prestacion.color.opacity(0.1))
                    .clipShape(Capsule())
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
    }
}

struct PrestacionDetailSheet: View {
    let prestacion: Prestacion
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: "#DDE3F0"))
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    detailHeader
                    detailContent
                }
            }
        }
        .background(Color.white)
    }

    private var detailHeader: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [prestacion.color.opacity(0.85), prestacion.color],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 140)

            Image(systemName: prestacion.icon)
                .font(.system(size: 70))
                .foregroundColor(.white.opacity(0.1))
                .offset(x: 220, y: 20)

            VStack(alignment: .leading, spacing: 6) {
                if let badge = prestacion.badge {
                    Text(badge)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                }

                Text(prestacion.nombre)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text(prestacion.valor)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    if let vsLey = prestacion.vsLey {
                        Text("vs \(vsLey)")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(20)
        }
        .clipped()
    }

    private var detailContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            detailSection(title: "¿Qué es?", icon: "info.circle.fill", text: prestacion.descripcion)
            Divider().opacity(0.3)
            detailSection(title: "¿Cómo funciona?", icon: "gearshape.fill", text: prestacion.detalle)

            if let vsLey = prestacion.vsLey {
                legalComparison(vsLey: vsLey)
            }

            Button {
                appState.openAssistant(prefill: "Quiero saber más sobre mi \(prestacion.nombre)")
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Consultar al asistente RH")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(prestacion.color)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(prestacion.color.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(prestacion.color.opacity(0.2), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(20)
    }

    private func detailSection(title: String, icon: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(prestacion.color)
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "#4B5675"))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func legalComparison(vsLey: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Vs la ley", systemImage: "scale.3d")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(hex: "#00C27C"))

            HStack(spacing: 12) {
                comparisonColumn(title: "Mabe", value: prestacion.valor, color: prestacion.color, background: prestacion.color.opacity(0.08))
                Text("vs")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#9AA5BE"))
                comparisonColumn(
                    title: "Ley federal",
                    value: vsLey
                        .replacingOccurrences(of: "Ley: ", with: "")
                        .replacingOccurrences(of: "Ley mín: ", with: ""),
                    color: Color(hex: "#9AA5BE"),
                    background: Color(hex: "#EFF3FA")
                )
            }
        }
    }

    private func comparisonColumn(title: String, value: String, color: Color, background: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct PrestacionMiniCard: View {
    let prestacion: Prestacion
    @State private var showingDetail = false

    var body: some View {
        Button {
            showingDetail = true
        } label: {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(prestacion.color.opacity(0.12))
                        .frame(width: 34, height: 34)
                    Image(systemName: prestacion.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(prestacion.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(prestacion.nombre)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "#0D1B3E"))
                    Text("Ver detalles de esta prestación")
                        .font(.system(size: 11))
                        .foregroundColor(prestacion.color)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(prestacion.color.opacity(0.7))
            }
            .padding(10)
            .background(prestacion.color.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(prestacion.color.opacity(0.2), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDetail) {
            PrestacionDetailSheet(prestacion: prestacion)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
    }
}
