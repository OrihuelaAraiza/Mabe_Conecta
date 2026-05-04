import SwiftUI

struct MabeLogoView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color.white)
            .frame(width: 124, height: 64)
            .overlay {
                Text("MABE")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.mabeBlue)
                    .tracking(1.5)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.mabeBlue.opacity(0.12), lineWidth: 1)
            }
            .mabeCardShadow()
            .accessibilityLabel("Mabe")
    }
}
