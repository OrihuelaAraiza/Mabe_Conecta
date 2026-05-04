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
            .font(.body)
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
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.mabeGray500)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isVisible ? "Ocultar NIP" : "Mostrar NIP")
            }
        }
        .padding(.leading, 14)
        .padding(.trailing, isSecure ? 4 : 14)
        .frame(minHeight: 52)
        .background(Color.mabeGray100)
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(isFocused ? Color.mabeLightBlue : Color.mabeGray200, lineWidth: isFocused ? 2 : 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
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
