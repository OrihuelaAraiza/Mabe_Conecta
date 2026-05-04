import SwiftUI

struct MabeLogoView: View {
    var body: some View {
        Image("MabeLogoOfficial")
            .resizable()
            .scaledToFit()
            .frame(width: 154, height: 66)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.mabeGray900.opacity(0.08), radius: 18, x: 0, y: 8)
            .accessibilityLabel("Mabe")
    }
}
