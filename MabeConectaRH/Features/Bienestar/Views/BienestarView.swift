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
        .background(Color.mabeBackground)
        .navigationTitle("Mi Bienestar")
        .mabeNavigationBarTitleDisplayMode(.large)
        .animation(.spring(response: 0.28), value: viewModel.estadoSeleccionado)
    }

    private var checkInCard: some View {
        MabeCard(padding: 0) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Check-in emocional del día")
                        .font(.mabeHeadline)
                        .foregroundStyle(Color.mabeGray900)
                    Text("Selecciona cómo te sientes hoy.")
                        .font(.mabeSub)
                        .foregroundStyle(Color.mabeGray400)
                }

                HStack(spacing: 8) {
                    ForEach(EstadoBienestar.allCases) { estado in
                        let visual = estado.visual
                        let isSelected = viewModel.estadoSeleccionado == estado
                        let hasSelection = viewModel.estadoSeleccionado != nil
                        Button {
                            viewModel.seleccionar(estado)
                        } label: {
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(visual.color.opacity(isSelected ? 0.15 : 0))
                                        .frame(width: 54, height: 54)
                                    Text(visual.emoji)
                                        .font(.system(size: 32))
                                        .scaleEffect(isSelected ? 1.4 : (hasSelection ? 0.9 : 1))
                                }
                                Text(visual.label)
                                    .font(.mabeLabel)
                                    .foregroundStyle(isSelected ? visual.color : Color.mabeGray400)
                                    .opacity(isSelected ? 1 : 0.75)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                            }
                            .frame(maxWidth: .infinity, minHeight: 84)
                            .opacity(hasSelection && !isSelected ? 0.42 : 1)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(visual.label)
                    }
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color.mabeInfo.opacity(0.10), Color.mabeElectric.opacity(0.05), .white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Text("🔥")
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.18))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("Llevas 5 días registrando")
                        .font(.mabeSub.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("Mantén tu racha de bienestar")
                        .font(.mabeCaption)
                        .foregroundStyle(.white.opacity(0.78))
                }
                Spacer()
            }

            HStack(spacing: 8) {
                ForEach(0..<7) { index in
                    Circle()
                        .fill(Color.white.opacity(index < 5 ? 1 : 0.3))
                        .frame(width: 16, height: 16)
                }
                Spacer()
                Text("5 de 7 días")
                    .font(.mabeCaption.weight(.semibold))
                    .foregroundStyle(.white)
            }
        }
        .padding(20)
        .background(LinearGradient.mabeHero)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.mabeElectric.opacity(0.24), radius: 18, x: 0, y: 8)
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
                        .font(.mabeTitle)
                        .foregroundStyle(Color.mabeDanger)
                    Text("Podemos canalizarte con un especialista de RH de forma confidencial.")
                        .font(.mabeSub)
                        .foregroundStyle(Color.mabeGray600)
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
                .font(.mabeHeadline)
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
                            .font(.mabeBody.weight(.medium))
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

private extension EstadoBienestar {
    var visual: (emoji: String, label: String, color: Color) {
        switch self {
        case .triste:
            return ("😔", "Difícil", Color(hex: "#F03E3E"))
        case .bajo:
            return ("😕", "Cansado", Color(hex: "#FFB300"))
        case .neutral:
            return ("😐", "Regular", Color(hex: "#9AA5BE"))
        case .bien:
            return ("🙂", "Bien", Color(hex: "#00C27C"))
        case .excelente:
            return ("😊", "Excelente", Color(hex: "#1976FF"))
        }
    }
}
