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
            Color.mabePrimary.opacity(0.06)
        case .mid:
            Color.mabePrimary.opacity(0.09)
        case .high:
            Color.mabePrimary.opacity(0.14)
        }
    }

    private var shadowRadius: CGFloat {
        switch elevation {
        case .low: 8
        case .mid: 16
        case .high: 28
        }
    }

    private var shadowY: CGFloat {
        switch elevation {
        case .low: 2
        case .mid: 4
        case .high: 8
        }
    }
}

struct MabeActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
    let destination: AnyView
    @State private var pressed = false

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
                    .strokeBorder(pressed ? accentColor.opacity(0.3) : Color.mabeBorder1, lineWidth: pressed ? 1 : 0.5)
            }
            .shadow(color: accentColor.opacity(pressed ? 0.12 : 0.07), radius: 12, x: 0, y: 3)
            .scaleEffect(pressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.spring(response: 0.2)) { pressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.3)) { pressed = false } }
        )
        .animation(.spring(response: 0.25), value: pressed)
    }
}
