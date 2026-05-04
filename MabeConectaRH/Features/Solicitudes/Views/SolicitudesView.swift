import SwiftUI

struct SolicitudesView: View {
    @State private var viewModel = SolicitudesViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 16) {
            segmentedControl
                .padding(.horizontal, MabeTheme.horizontalPadding)
                .padding(.top, 12)

            if viewModel.filtradas.isEmpty {
                EmptyRequestsView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(MabeTheme.horizontalPadding)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.filtradas) { solicitud in
                            RequestCard(solicitud: solicitud)
                        }
                    }
                    .padding(.horizontal, MabeTheme.horizontalPadding)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(Color.mabeGray100)
        .navigationTitle("Mis Solicitudes")
        .mabeNavigationBarTitleDisplayMode(.large)
    }

    private var segmentedControl: some View {
        HStack(spacing: 4) {
            ForEach(SolicitudesSegment.allCases, id: \.rawValue) { segment in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.selectedSegment = segment
                    }
                } label: {
                    Text(segment.rawValue)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(viewModel.selectedSegment == segment ? .white : Color.mabeBlue)
                        .frame(maxWidth: .infinity, minHeight: 42)
                        .background(viewModel.selectedSegment == segment ? Color.mabeBlue : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(segment.rawValue)
            }
        }
        .padding(4)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .mabeCardShadow()
    }
}

private struct RequestCard: View {
    let solicitud: Solicitud

    var body: some View {
        MabeCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(solicitud.tipo)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.mabeGray900)
                        Text("Solicitada el \(solicitud.fecha.mabeShortDate)")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.mabeGray500)
                    }

                    Spacer()
                    MabeStatusBadge(status: solicitud.estado.rawValue, color: solicitud.estado.color)
                }

                Button("Ver detalle") {}
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.mabeBlue)
                    .padding(.horizontal, 12)
                    .frame(height: 34)
                    .background(Color.mabeBlue.opacity(0.08))
                    .clipShape(Capsule())
                    .accessibilityLabel("Ver detalle de \(solicitud.tipo)")
            }
        }
    }
}

private struct EmptyRequestsView: View {
    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.mabeBlue.opacity(0.08))
                    .frame(width: 116, height: 116)
                Image(systemName: "tray")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Color.mabeBlue)
            }

            VStack(spacing: 6) {
                Text("Sin solicitudes pendientes")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.mabeGray900)
                Text("Cuando registres un trámite, aparecerá aquí para que puedas darle seguimiento.")
                    .font(.subheadline)
                    .foregroundStyle(Color.mabeGray500)
                    .multilineTextAlignment(.center)
            }

            MabePrimaryButton(title: "Crear solicitud", icon: "plus") {}
        }
    }
}
