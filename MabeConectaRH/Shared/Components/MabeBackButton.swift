import SwiftUI

struct MabeBackButton: View {
    @Environment(\.dismiss) private var dismiss
    var title: String = ""

    var body: some View {
        HStack(spacing: 4) {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    if !title.isEmpty {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .foregroundColor(Color(hex: "#003087"))
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}
