import SwiftUI

struct BienestarView: View {
    @State private var viewModel = BienestarViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    checkInCard
                    streakCard

                    if viewModel.estadoSeleccionado?.necesitaApoyo == true {
                        supportCard
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    resourcesSection
                }
                .padding(MabeTheme.horizontalPadding)
                .padding(.bottom, 24)
            }
        }
        .background(Color.mabeGray100)
        .navigationTitle("Mi Bienestar")
        .mabeNavigationBarTitleDisplayMode(.large)
        .animation(.spring(response: 0.28), value: viewModel.estadoSeleccionado)
    }

    private var checkInCard: some View {
        MabeCard(padding: 0) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Check-in emocional del día")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.mabeGray900)
                    Text("Selecciona cómo te sientes hoy.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.mabeGray500)
                }

                HStack {
                    ForEach(EstadoBienestar.allCases) { estado in
                        Button {
                            viewModel.seleccionar(estado)
                        } label: {
                            VStack(spacing: 6) {
                                Text(estado.emoji)
                                    .font(.system(size: viewModel.estadoSeleccionado == estado ? 42 : 34))
                                    .scaleEffect(viewModel.estadoSeleccionado == estado ? 1.12 : 1)
                                Text(estado.rawValue)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(Color.mabeGray500)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                            }
                            .frame(maxWidth: .infinity, minHeight: 74)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(estado.rawValue)
                    }
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color.mabeInfo.opacity(0.12), Color.mabeBlue.opacity(0.05), .white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }

    private var streakCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.18))
                .clipShape(Circle())
            Text("Llevas 5 días registrando tu bienestar 🔥")
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(16)
        .background(Color.mabeBlue)
        .clipShape(RoundedRectangle(cornerRadius: MabeTheme.cardRadius, style: .continuous))
        .mabeCardShadow()
    }

    private var supportCard: some View {
        MabeCard {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.badge.exclamationmark")
                    .font(.title2)
                    .foregroundStyle(Color.mabeDanger)
                    .frame(width: 44, height: 44)
                    .background(Color.mabeDanger.opacity(0.1))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 12) {
                    Text("Estamos contigo")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.mabeDanger)
                    Text("Podemos canalizarte con un especialista de RH de forma confidencial.")
                        .font(.subheadline)
                        .foregroundStyle(Color.mabeGray500)
                    Button("Hablar con alguien") {}
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .frame(height: 36)
                        .background(Color.mabeDanger)
                        .clipShape(Capsule())
                        .accessibilityLabel("Hablar con alguien")
                }
            }
        }
    }

    private var resourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recursos")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.mabeGray900)

            ForEach(viewModel.recursos, id: \.self) { recurso in
                MabeCard {
                    HStack(spacing: 12) {
                        Image(systemName: "heart.text.square")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Color.mabeBlue)
                            .frame(width: 42, height: 42)
                            .background(Color.mabeBlue.opacity(0.1))
                            .clipShape(Circle())
                        Text(recurso)
                            .font(.body.weight(.medium))
                            .foregroundStyle(Color.mabeGray900)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.mabeGray500)
                    }
                }
            }
        }
    }
}
