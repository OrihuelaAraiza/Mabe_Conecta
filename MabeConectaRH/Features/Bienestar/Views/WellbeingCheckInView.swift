import SwiftUI

enum WellbeingCheckInState: String, CaseIterable, Identifiable {
    case bien = "Bien"
    case neutral = "Neutral"
    case conCarga = "Con carga"
    case necesitoApoyo = "Necesito apoyo"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .bien: "sun.max.fill"
        case .neutral: "cloud.fill"
        case .conCarga: "exclamationmark.bubble.fill"
        case .necesitoApoyo: "person.crop.circle.badge.exclamationmark"
        }
    }

    var color: Color {
        switch self {
        case .bien: .mabeSuccess
        case .neutral: .mabeGray500
        case .conCarga: .mabeWarning
        case .necesitoApoyo: .mabeDanger
        }
    }

    var response: String {
        switch self {
        case .bien:
            "Nos alegra saberlo. Sigue cuidando tu bienestar."
        case .neutral:
            "Gracias por compartirlo. Te recomendamos revisar tus beneficios de bienestar."
        case .conCarga:
            "Podemos ayudarte a encontrar apoyo o hablar con RH."
        case .necesitoApoyo:
            "La IA detecta la señal y te ayuda a escalar con una persona de RH cuando hace falta."
        }
    }
}

struct WellbeingCheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedState: WellbeingCheckInState?
    @State private var showSupport = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("¿Cómo estás hoy?")
                        .font(.mabeHeadline)
                        .foregroundStyle(Color.mabeGray900)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(WellbeingCheckInState.allCases) { state in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    selectedState = state
                                }
                            } label: {
                                VStack(spacing: 10) {
                                    Image(systemName: state.icon)
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(state.color)
                                    Text(state.rawValue)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(Color.mabeGray900)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 104)
                                .background(selectedState == state ? state.color.opacity(0.12) : Color.mabeSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .strokeBorder(selectedState == state ? state.color.opacity(0.45) : Color.clear, lineWidth: 1.5)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if let selectedState {
                        responseCard(for: selectedState)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(20)
            }
            .background(Color.mabeBackground)
            .navigationTitle("Check-in")
            .mabeNavigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") { dismiss() }
                        .font(.system(size: 15, weight: .semibold))
                }
            }
            .sheet(isPresented: $showSupport) {
                HRSupportSheet(context: "Check-in de bienestar")
            }
        }
    }

    private func responseCard(for state: WellbeingCheckInState) -> some View {
        MabeCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(state.response)
                    .font(.mabeSub)
                    .foregroundStyle(Color.mabeGray700Fallback)

                if state == .necesitoApoyo {
                    VStack(spacing: 10) {
                        supportAction("Hablar con RH", icon: "person.2.fill") { showSupport = true }
                        supportAction("Ver recursos de apoyo", icon: "heart.text.square.fill") {}
                        supportAction("Solicitar seguimiento", icon: "calendar.badge.plus") { showSupport = true }
                    }
                } else if state == .conCarga {
                    supportAction("Hablar con RH", icon: "person.2.fill") { showSupport = true }
                }
            }
        }
    }

    private func supportAction(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.mabeBlue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.mabeBlue.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private extension Color {
    static var mabeGray700Fallback: Color { Color(hex: "#4B5675") }
}
