import SwiftUI

struct MabeStatusBadge: View {
    let status: String
    let color: Color

    var body: some View {
        Text(status)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
            .accessibilityLabel("Estado \(status)")
    }
}
