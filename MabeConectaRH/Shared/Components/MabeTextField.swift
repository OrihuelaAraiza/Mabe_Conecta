import SwiftUI

enum MabeKeyboardType {
    case `default`
    case numberPad
}

struct MabeTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure = false
    var keyboardType: MabeKeyboardType = .default
    var submitLabel: SubmitLabel = .done
    var highlightColor: Color?

    @FocusState private var isFocused: Bool
    @State private var isVisible = false

    var body: some View {
        HStack(spacing: 10) {
            Group {
                if isSecure && !isVisible {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.mabeBody)
            .foregroundStyle(Color.mabeGray900)
            .mabeKeyboard(keyboardType)
            .autocorrectionDisabled()
            .submitLabel(submitLabel)
            .focused($isFocused)

            if isSecure {
                Button {
                    isVisible.toggle()
                } label: {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .font(.mabeBody)
                        .foregroundStyle(Color.mabeGray400)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isVisible ? "Ocultar NIP" : "Mostrar NIP")
            }
        }
        .padding(.leading, 14)
        .padding(.trailing, isSecure ? 4 : 14)
        .frame(minHeight: 48)
        .background(Color.mabeSurface1)
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(highlightColor ?? (isFocused ? Color.mabeBorder2 : Color.mabeBorder1), lineWidth: highlightColor == nil ? (isFocused ? 1.5 : 0.5) : 1.5)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
                .animation(.easeInOut(duration: 0.2), value: highlightColor)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Color.mabePrimary.opacity(isFocused ? 0.08 : 0.03), radius: isFocused ? 12 : 6, x: 0, y: 3)
    }
}

private extension View {
    @ViewBuilder
    func mabeKeyboard(_ type: MabeKeyboardType) -> some View {
        #if os(iOS)
        switch type {
        case .default:
            self
                .keyboardType(.default)
                .textInputAutocapitalization(.never)
        case .numberPad:
            self
                .keyboardType(.numberPad)
                .textInputAutocapitalization(.never)
        }
        #else
        self
        #endif
    }
}
