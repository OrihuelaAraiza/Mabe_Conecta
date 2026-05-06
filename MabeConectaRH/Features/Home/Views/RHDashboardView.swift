import Charts
import SwiftUI

struct RHDashboardView: View {
    let empleado: Empleado

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                RHHeroWidget(empleado: empleado)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    KPICard(
                        valor: 3,
                        label: "Pendientes",
                        icon: "clock.fill",
                        gradient: LinearGradient(colors: [Color(hex:"#B45309"), Color(hex:"#D97706")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    KPICard(
                        valor: 12,
                        label: "Resueltos hoy",
                        icon: "checkmark.circle.fill",
                        gradient: LinearGradient(colors: [Color(hex:"#00704A"), Color(hex:"#00C27C")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    KPICard(
                        valor: 5,
                        label: "Chats activos",
                        icon: "bubble.left.and.bubble.right.fill",
                        gradient: LinearGradient(colors: [Color(hex:"#003087"), Color(hex:"#1976FF")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    KPICard(
                        valor: 94,
                        label: "Satisfacción %",
                        icon: "star.fill",
                        gradient: LinearGradient(colors: [Color(hex:"#5C3BC1"), Color(hex:"#7C5CFC")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                }
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Requieren atención")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Color(hex: "#0D1B3E"))
                        Spacer()
                        PulsingDot(color: Color(hex: "#F03E3E"))
                        Text("3 urgentes")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "#F03E3E"))
                    }

                    ForEach(MockDataService.solicitudesUrgentes) { solicitud in
                        RHSolicitudRow(solicitud: solicitud)
                    }
                }
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Actividad reciente")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color(hex: "#0D1B3E"))
                        .padding(.horizontal, 20)

                    RHActivityChart()
                        .padding(.horizontal, 20)
                }

                CargarEvaluacionButton()
                    .padding(.horizontal, 20)
            }
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
        .background(Color(hex: "#F8F9FC"))
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
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                                .tracking(1)
                        }
                        Text(empleado.nombreCompleto)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("\(empleado.puesto) · \(empleado.planta)")
                            .font(.system(size: 12, weight: .medium))
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
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct KPICard: View {
    let valor: Int
    let label: String
    let icon: String
    let gradient: LinearGradient
    @State private var displayedValue: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                Spacer()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(Int(displayedValue))")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#0D1B3E"))
                    .contentTransition(.numericText(value: displayedValue))
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#9AA5BE"))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color(hex: "#0D1B3E").opacity(0.06), radius: 12, x: 0, y: 4)
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
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "#0D1B3E"))

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
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "#9AA5BE"))
                        }
                    }
                }
            }
            .frame(height: 120)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color(hex: "#0D1B3E").opacity(0.06), radius: 12, x: 0, y: 4)
    }
}

private struct RHSolicitudRow: View {
    let solicitud: SolicitudRH

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(solicitud.urgencia == .alta ? Color(hex: "#F03E3E").opacity(0.1) : Color(hex: "#EFF3FA"))
                    .frame(width: 44, height: 44)
                Text(solicitud.iniciales)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(solicitud.urgencia == .alta ? Color(hex: "#F03E3E") : Color(hex: "#003087"))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(solicitud.empleadoNombre)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#0D1B3E"))
                Text(solicitud.ultimoMensaje)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#9AA5BE"))
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(solicitud.tiempoRelativo)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "#9AA5BE"))
                if solicitud.urgencia == .alta {
                    PulsingDot(color: Color(hex: "#F03E3E"))
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    solicitud.urgencia == .alta ? Color(hex: "#F03E3E").opacity(0.3) : Color(hex: "#DDE3F0"),
                    lineWidth: 1
                )
        }
        .shadow(color: Color(hex: "#0D1B3E").opacity(0.04), radius: 8, x: 0, y: 2)
    }
}
