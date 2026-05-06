import SwiftUI

extension Color {
    static let mabePrimary = Color(hex: "#003087")
    static let mabeAccent = Color(hex: "#1565C0")
    static let mabeElectric = Color(hex: "#2979FF")

    static let mabeBase = Color(hex: "#F0F4FF")
    static let mabeSurface0 = Color(hex: "#FFFFFF")
    static let mabeSurface1 = Color(hex: "#F7F9FF")
    static let mabeSurface2 = Color(hex: "#EEF2FF")

    static let mabeText1 = Color(hex: "#0A1628")
    static let mabeText2 = Color(hex: "#344563")
    static let mabeText3 = Color(hex: "#6B7A99")
    static let mabeText4 = Color(hex: "#A8B4CC")

    static let mabeBorder1 = Color(hex: "#E2E8F5")
    static let mabeBorder2 = Color(hex: "#C8D4EC")

    static let mabeSuccess = Color(hex: "#00875A")
    static let mabeWarning = Color(hex: "#B45309")
    static let mabeDanger = Color(hex: "#C62828")
    static let mabeInfo = Color(hex: "#1565C0")

    static let mabeBlue = mabePrimary
    static let mabeLightBlue = mabeAccent
    static let mabeBackground = mabeBase
    static let mabeSurface = mabeSurface0
    static let mabeWhite = mabeSurface0

    static let mabeGray100 = mabeSurface2
    static let mabeGray200 = mabeBorder1
    static let mabeGray400 = mabeText4
    static let mabeGray500 = mabeText3
    static let mabeGray600 = mabeText2
    static let mabeGray900 = mabeText1
}

extension LinearGradient {
    static let mabePrimary = LinearGradient(
        stops: [
            .init(color: Color(hex: "#003087"), location: 0),
            .init(color: Color(hex: "#1565C0"), location: 0.6),
            .init(color: Color(hex: "#2979FF"), location: 1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let mabeSubtle = LinearGradient(
        colors: [Color(hex: "#EEF2FF"), Color(hex: "#F7F9FF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let mabeOverlay = LinearGradient(
        colors: [Color.black.opacity(0.0), Color.black.opacity(0.4)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let mabeHero = LinearGradient(
        colors: [Color(hex: "#003087"), Color(hex: "#1565C0"), Color(hex: "#2979FF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let mabeHeroSoft = LinearGradient(
        colors: [Color(hex: "#EEF2FF"), Color(hex: "#F7F9FF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let mabeCard = LinearGradient(
        colors: [Color(hex: "#2979FF").opacity(0.06), Color.clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let mabeSuccess = LinearGradient(
        colors: [Color(hex: "#00875A"), Color(hex: "#00A36C")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Font {
    static let mabeDisplay = Font.custom("PlusJakartaSans-ExtraBold", size: 40)
    static let mabeDisplaySm = Font.custom("PlusJakartaSans-Bold", size: 28)

    static let mabeH1 = Font.custom("PlusJakartaSans-Bold", size: 24)
    static let mabeH2 = Font.custom("PlusJakartaSans-Bold", size: 20)
    static let mabeH3 = Font.custom("PlusJakartaSans-SemiBold", size: 17)

    static let mabeBody = Font.custom("PlusJakartaSans-Regular", size: 15)
    static let mabeBodyMed = Font.custom("PlusJakartaSans-Medium", size: 15)

    static let mabeLabelLg = Font.custom("PlusJakartaSans-SemiBold", size: 13)
    static let mabeLabelMd = Font.custom("PlusJakartaSans-Medium", size: 12)
    static let mabeLabelSm = Font.custom("PlusJakartaSans-SemiBold", size: 10)
    static let mabeMono = Font.system(size: 14, weight: .medium, design: .monospaced)

    static let mabeHeadline = mabeH1
    static let mabeTitle = mabeH2
    static let mabeSub = mabeBodyMed
    static let mabeCaption = mabeLabelLg
    static let mabeLabel = mabeLabelSm

    static func jakartaOrSystem(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .bold:
            name = "PlusJakartaSans-Bold"
        case .semibold:
            name = "PlusJakartaSans-SemiBold"
        case .medium:
            name = "PlusJakartaSans-Medium"
        case .heavy, .black:
            name = "PlusJakartaSans-ExtraBold"
        default:
            name = "PlusJakartaSans-Regular"
        }
        return .custom(name, size: size)
    }
}

enum MabeTheme {
    static let horizontalPadding: CGFloat = 20
    static let cardSpacing: CGFloat = 12
    static let cardRadius: CGFloat = 18
    static let buttonRadius: CGFloat = 14
    static let shadow = Color.mabePrimary.opacity(0.055)
}

struct MabeElevation: ViewModifier {
    enum Level {
        case low
        case mid
        case high
        case colored(Color, opacity: Double = 0.24)
    }

    let level: Level

    func body(content: Content) -> some View {
        content.shadow(color: shadowColor, radius: radius, x: 0, y: y)
    }

    private var shadowColor: Color {
        switch level {
        case .low:
            Color.mabePrimary.opacity(0.04)
        case .mid:
            Color.mabePrimary.opacity(0.055)
        case .high:
            Color.mabePrimary.opacity(0.09)
        case let .colored(color, opacity):
            color.opacity(min(opacity, 0.16))
        }
    }

    private var radius: CGFloat {
        switch level {
        case .low: 6
        case .mid: 12
        case .high: 20
        case .colored: 14
        }
    }

    private var y: CGFloat {
        switch level {
        case .low: 1
        case .mid: 3
        case .high, .colored: 6
        }
    }
}

extension View {
    func mabeCardShadow() -> some View {
        shadow(color: MabeTheme.shadow, radius: 12, x: 0, y: 3)
    }

    func mabeElevation(_ level: MabeElevation.Level = .mid) -> some View {
        modifier(MabeElevation(level: level))
    }
}
