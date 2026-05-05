import SwiftUI

enum HomeRecommendationDestination: Hashable {
    case vacaciones
    case benefits
    case solicitudes
    case bienestar
}

struct HomeRecommendation: Identifiable, Hashable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let cta: String
    let destination: HomeRecommendationDestination
}

struct PredictiveRecommendationsView: View {
    let recommendations: [HomeRecommendation]
    let onSelect: (HomeRecommendationDestination) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recomendado para ti")
                .font(.mabeHeadline)
                .foregroundStyle(Color.mabeGray900)

            VStack(spacing: 10) {
                ForEach(recommendations) { item in
                    Button {
                        onSelect(item.destination)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: item.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.mabeBlue)
                                .frame(width: 38, height: 38)
                                .background(Color.mabeBlue.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.mabeGray900)
                                Text(item.description)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.mabeGray500)
                                    .lineLimit(2)
                            }

                            Spacer()

                            Text(item.cta)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.mabeBlue)
                                .padding(.horizontal, 10)
                                .frame(height: 30)
                                .background(Color.mabeBlue.opacity(0.08))
                                .clipShape(Capsule())
                        }
                        .padding(14)
                        .background(Color.mabeSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Color.mabeGray900.opacity(0.05), radius: 10, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
