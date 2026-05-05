import SwiftUI

struct ImpactSummaryCard: View {
    var body: some View {
        MabeCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Impacto este mes")
                            .font(.mabeHeadline)
                            .foregroundStyle(Color.mabeGray900)
                        Text("Menos trámites. Más tiempo para lo importante.")
                            .font(.mabeCaption)
                            .foregroundStyle(Color.mabeGray500)
                    }
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.mabeElectric)
                        .frame(width: 38, height: 38)
                        .background(Color.mabeElectric.opacity(0.1))
                        .clipShape(Circle())
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    impactMetric(value: "2h 40min", label: "Tiempo recuperado", color: .mabeBlue)
                    impactMetric(value: "8", label: "Solicitudes resueltas", color: .mabeSuccess)
                    impactMetric(value: "3", label: "Beneficios usados", color: .mabeElectric)
                    impactMetric(value: "Alta", label: "Satisfacción", color: .mabeWarning)
                }
            }
        }
    }

    private func impactMetric(value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.mabeGray500)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
