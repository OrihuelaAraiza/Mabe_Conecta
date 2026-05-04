import SwiftUI

struct MabePrimaryButton: View {
    let title: String
    var icon: String?
    var isDisabled = false
    var usesLightBlue = false
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            guard !isDisabled else { return }
            Haptics.impact(.medium)
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.callout.weight(.semibold))
                }
                Text(title)
                    .font(.callout.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(usesLightBlue ? Color.mabeLightBlue : Color.mabeBlue)
            .clipShape(RoundedRectangle(cornerRadius: MabeTheme.buttonRadius, style: .continuous))
            .opacity(isDisabled ? 0.5 : 1)
            .scaleEffect(isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.2), value: isPressed)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityLabel(title)
    }
}
