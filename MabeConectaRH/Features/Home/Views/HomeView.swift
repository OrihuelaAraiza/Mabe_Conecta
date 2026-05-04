import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel

    init(empleado: Empleado) {
        _viewModel = State(initialValue: HomeViewModel(empleado: empleado))
    }

    var body: some View {
        VStack(spacing: 0) {
            HomeHeader(empleado: viewModel.empleado)
                .padding(.horizontal, MabeTheme.horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, 10)
                .background(Color.white)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    quickAccessSection
                    wellnessBanner
                    recentRequestsSection
                }
                .padding(.horizontal, MabeTheme.horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .background(Color.mabeGray100)
        }
        .mabeNavigationBarTitleDisplayMode(.large)
    }

    private var quickAccessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Acceso rápido")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.mabeGray900)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.accesos) { item in
                    QuickAccessCard(item: item)
                }
            }
        }
    }

    private var wellnessBanner: some View {
        MabeCard(padding: 0) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("¿Cómo estás hoy?")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("Registra tu bienestar y recibe apoyo oportuno.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Spacer()

                Button("Registrar") {}
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.mabeBlue)
                    .padding(.horizontal, 14)
                    .frame(height: 36)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .accessibilityLabel("Registrar bienestar")
            }
            .padding(18)
            .background(
                LinearGradient(colors: [.mabeBlue, .mabeLightBlue], startPoint: .leading, endPoint: .trailing)
            )
        }
    }

    private var recentRequestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mis solicitudes recientes")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.mabeGray900)

            ForEach(viewModel.solicitudes) { solicitud in
                MabeCard {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Color.mabeBlue)
                            .frame(width: 40, height: 40)
                            .background(Color.mabeBlue.opacity(0.1))
                            .clipShape(Circle())

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

private struct HomeHeader: View {
    let empleado: Empleado

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hola, \(empleado.nombre) 👋")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.mabeGray900)
                Text(empleado.nombreCompleto)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.mabeGray500)
            }

            Spacer()

            Button {} label: {
                Image(systemName: "bell")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.mabeGray900)
                    .frame(width: 44, height: 44)
                    .background(Color.mabeGray100)
                    .clipShape(Circle())
            }
            .accessibilityLabel("Notificaciones")

            Text(empleado.iniciales)
                .font(.callout.weight(.bold))
                .foregroundStyle(Color.mabeBlue)
                .frame(width: 46, height: 46)
                .background(Color.mabeBlue.opacity(0.1))
                .clipShape(Circle())
                .accessibilityLabel("Foto de perfil")
        }
    }
}

private struct QuickAccessCard: View {
    let item: QuickAccessItem

    var body: some View {
        Button {
            Haptics.impact(.light)
        } label: {
            MabeCard {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: item.icono)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.mabeBlue)
                        .frame(width: 42, height: 42)
                        .background(Color.mabeBlue.opacity(0.1))
                        .clipShape(Circle())

                    Text(item.titulo)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(Color.mabeGray900)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(minHeight: 98)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.titulo)
    }
}
