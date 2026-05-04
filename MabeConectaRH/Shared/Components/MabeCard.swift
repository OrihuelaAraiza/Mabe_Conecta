import SwiftUI

struct MabeCard<Content: View>: View {
    var padding: CGFloat = 16
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: MabeTheme.cardRadius, style: .continuous))
            .mabeCardShadow()
    }
}
