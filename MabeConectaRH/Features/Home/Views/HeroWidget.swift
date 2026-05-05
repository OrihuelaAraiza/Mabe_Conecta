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
        default:
            SolicitudesView()
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
