import SwiftUI

extension Color {
    static let mabeBlue = Color(hex: "#003087")
    static let mabeLightBlue = Color(hex: "#0057B8")
    static let mabeWhite = Color(hex: "#FFFFFF")

    static let mabeGray100 = Color(hex: "#F5F6F8")
    static let mabeGray200 = Color(hex: "#E8EAED")
    static let mabeGray500 = Color(hex: "#6B7280")
    static let mabeGray900 = Color(hex: "#111827")

    static let mabeSuccess = Color(hex: "#16A34A")
    static let mabeWarning = Color(hex: "#D97706")
    static let mabeDanger = Color(hex: "#DC2626")
    static let mabeInfo = Color(hex: "#0EA5E9")
}

enum MabeTheme {
    static let horizontalPadding: CGFloat = 20
    static let cardSpacing: CGFloat = 12
    static let cardRadius: CGFloat = 16
    static let buttonRadius: CGFloat = 12
    static let shadow = Color.black.opacity(0.06)
}

extension View {
    func mabeCardShadow() -> some View {
        shadow(color: MabeTheme.shadow, radius: 8, x: 0, y: 2)
    }
}
