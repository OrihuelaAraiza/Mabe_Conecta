import SwiftUI

extension Color {
    static let mabeBlue = Color(hex: "#003087")
    static let mabeLightBlue = Color(hex: "#0057B8")
    static let mabeElectric = Color(hex: "#1976FF")

    static let mabeBackground = Color(hex: "#F8F9FC")
    static let mabeSurface = Color(hex: "#FFFFFF")
    static let mabeSurface2 = Color(hex: "#EFF3FA")
    static let mabeWhite = Color(hex: "#FFFFFF")

    static let mabeGray100 = Color(hex: "#EFF3FA")
    static let mabeGray200 = Color(hex: "#DDE3F0")
    static let mabeGray400 = Color(hex: "#9AA5BE")
    static let mabeGray500 = Color(hex: "#9AA5BE")
    static let mabeGray600 = Color(hex: "#4B5675")
    static let mabeGray900 = Color(hex: "#0D1B3E")

    static let mabeSuccess = Color(hex: "#00C27C")
    static let mabeWarning = Color(hex: "#FFB300")
    static let mabeDanger = Color(hex: "#F03E3E")
    static let mabeInfo = Color(hex: "#2196F3")
}

extension LinearGradient {
    static let mabeHero = LinearGradient(
        colors: [Color(hex: "#003087"), Color(hex: "#1976FF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let mabeHeroSoft = LinearGradient(
        colors: [Color(hex: "#003087").opacity(0.9), Color(hex: "#0057B8").opacity(0.85)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let mabeCard = LinearGradient(
        colors: [Color(hex: "#1976FF").opacity(0.06), Color.clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let mabeSuccess = LinearGradient(
        colors: [Color(hex: "#00C27C"), Color(hex: "#00A36C")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Font {
    static let mabeDisplay = Font.system(size: 42, weight: .bold, design: .rounded)
    static let mabeHeadline = Font.system(size: 22, weight: .bold, design: .rounded)
    static let mabeTitle = Font.system(size: 20, weight: .semibold, design: .default)
    static let mabeSub = Font.system(size: 15, weight: .medium, design: .default)
    static let mabeBody = Font.system(size: 16, weight: .regular, design: .default)
    static let mabeCaption = Font.system(size: 13, weight: .medium, design: .default)
    static let mabeLabel = Font.system(size: 11, weight: .semibold, design: .default)
}

enum MabeTheme {
    static let horizontalPadding: CGFloat = 20
    static let cardSpacing: CGFloat = 12
    static let cardRadius: CGFloat = 20
    static let buttonRadius: CGFloat = 14
    static let shadow = Color.mabeGray900.opacity(0.07)
}

extension View {
    func mabeCardShadow() -> some View {
        shadow(color: MabeTheme.shadow, radius: 16, x: 0, y: 4)
    }
}
