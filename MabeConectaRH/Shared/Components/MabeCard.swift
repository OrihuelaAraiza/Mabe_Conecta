import SwiftUI

struct MabeCard<Content: View>: View {
    var padding: CGFloat = 20
    var hasBorder = false
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .background(Color.mabeSurface)
            .clipShape(RoundedRectangle(cornerRadius: MabeTheme.cardRadius, style: .continuous))
            .shadow(color: Color.mabeGray900.opacity(0.07), radius: 16, x: 0, y: 4)
            .overlay {
                RoundedRectangle(cornerRadius: MabeTheme.cardRadius, style: .continuous)
                    .strokeBorder(Color.mabeGray200.opacity(hasBorder ? 1 : 0), lineWidth: 1)
            }
    }
}
