import SwiftUI

struct MabePrimaryButton: View {
    let title: String
    var icon: String?
    var isDisabled = false
    var usesLightBlue = false
    var isLoading = false
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            guard !isDisabled else { return }
            Haptics.impact(.medium)
            action()
        } label: {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.8)
                } else if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.mabeSub)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(usesLightBlue ? Color.mabeElectric : Color.mabeBlue)
            .clipShape(RoundedRectangle(cornerRadius: MabeTheme.buttonRadius, style: .continuous))
            .opacity(isDisabled ? 0.5 : 1)
            .scaleEffect(isPressed ? 0.97 : 1)
            .shadow(color: Color.mabeElectric.opacity(isPressed || isDisabled ? 0 : 0.35), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.spring(response: 0.2)) { isPressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.3)) { isPressed = false } }
        )
        .accessibilityLabel(title)
    }
}
