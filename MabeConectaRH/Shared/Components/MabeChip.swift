import SwiftUI

struct MabeChip: View {
    let title: String
    var isSelected = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.mabeCaption)
                .foregroundStyle(isSelected ? Color.white : Color.mabeBlue)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        LinearGradient.mabeHero
                    } else {
                        Color.mabeSurface2
                    }
                }
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(isSelected ? Color.clear : Color.mabeGray200, lineWidth: 1)
                }
                .shadow(color: isSelected ? Color.mabeElectric.opacity(0.25) : .clear, radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
    }
}
