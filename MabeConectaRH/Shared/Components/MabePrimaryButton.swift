import SwiftUI

struct MabePrimaryButton: View {
    let title: String
    var icon: String?
    var isDisabled = false
    var usesLightBlue = false
    var isLoading = false
    let action: () -> Void

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
            .shadow(color: Color.mabeAccent.opacity(isDisabled ? 0 : 0.22), radius: 14, x: 0, y: 6)
            .overlay {
                RoundedRectangle(cornerRadius: MabeTheme.buttonRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
            }
        }
        .buttonStyle(MabePressButtonStyle(scale: 0.97))
        .disabled(isDisabled)
        .accessibilityLabel(title)
    }
}
