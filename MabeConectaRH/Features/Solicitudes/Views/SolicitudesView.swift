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
        .background(Color.mabeBackground)
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
                        .background(viewModel.selectedSegment == segment ? AnyShapeStyle(LinearGradient.mabeHero) : AnyShapeStyle(Color.clear))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(segment.rawValue)
            }
        }
        .padding(4)
        .background(Color.mabeSurface)
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
                            .font(.mabeBody.weight(.semibold))
                            .foregroundStyle(Color.mabeGray900)
                        Text("Solicitada el \(solicitud.fecha.mabeShortDate)")
                            .font(.mabeSub)
                            .foregroundStyle(Color.mabeGray400)
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
                Image(systemName: "doc.text")
                    .font(.system(size: 78, weight: .semibold))
                    .foregroundStyle(Color.mabeGray200)
                    .offset(x: -18, y: 4)
                Image(systemName: "tray")
                    .font(.system(size: 54, weight: .semibold))
                    .foregroundStyle(Color.mabeGray400.opacity(0.8))
                    .offset(x: 18, y: -8)
                Image(systemName: "sparkles")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.mabeElectric.opacity(0.55))
                    .offset(x: 50, y: 38)
            }
            .frame(width: 140, height: 120)

            VStack(spacing: 6) {
                Text("Aún no tienes solicitudes")
                    .font(.mabeTitle)
                    .foregroundStyle(Color.mabeGray600)
                Text("Tus trámites aparecerán aquí")
                    .font(.mabeSub)
                    .foregroundStyle(Color.mabeGray400)
                    .multilineTextAlignment(.center)
            }

            Button("Crear mi primera solicitud") {}
                .font(.mabeSub.weight(.semibold))
                .foregroundStyle(Color.mabeBlue)
                .frame(minHeight: 44)
        }
    }
}
