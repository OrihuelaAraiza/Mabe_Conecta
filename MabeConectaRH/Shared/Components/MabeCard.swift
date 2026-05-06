import SwiftUI

struct MabeCard<Content: View>: View {
    var padding: CGFloat = 16
    var hasBorder = true
    var elevation: CardElevation = .mid
    @ViewBuilder let content: Content

    enum CardElevation {
        case low
        case mid
        case high
    }

    var body: some View {
        content
            .padding(padding)
            .background(Color.mabeSurface0)
            .clipShape(RoundedRectangle(cornerRadius: MabeTheme.cardRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: MabeTheme.cardRadius, style: .continuous)
                    .strokeBorder(Color.mabeBorder1.opacity(hasBorder ? 1 : 0), lineWidth: 0.5)
            }
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
    }

    private var shadowColor: Color {
        switch elevation {
        case .low:
            Color.mabePrimary.opacity(0.04)
        case .mid:
            Color.mabePrimary.opacity(0.055)
        case .high:
            Color.mabePrimary.opacity(0.09)
        }
    }

    private var shadowRadius: CGFloat {
        switch elevation {
        case .low: 6
        case .mid: 12
        case .high: 20
        }
    }

    private var shadowY: CGFloat {
        switch elevation {
        case .low: 1
        case .mid: 3
        case .high: 6
        }
    }
}

struct MabeActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(accentColor.opacity(0.10))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(accentColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.mabeLabelLg)
                        .foregroundColor(.mabeText1)
                    Text(subtitle)
                        .font(.mabeLabelSm)
                        .foregroundColor(accentColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.mabeSurface0)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.mabeBorder1, lineWidth: 0.5)
            }
            .shadow(color: accentColor.opacity(0.045), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(MabePressButtonStyle(scale: 0.97))
    }
}

struct MabePressButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.97

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.82), value: configuration.isPressed)
    }
}
