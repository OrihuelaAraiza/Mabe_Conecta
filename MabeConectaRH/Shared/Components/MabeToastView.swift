import SwiftUI

struct MabeToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.mabeGray900.opacity(0.85))
            .clipShape(Capsule())
            .mabeCardShadow()
            .accessibilityLabel(message)
    }
}
