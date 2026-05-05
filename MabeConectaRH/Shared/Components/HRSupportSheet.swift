import SwiftUI

struct HRSupportSheet: View {
    @Environment(\.dismiss) private var dismiss
    let context: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.badge.gearshape.fill")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(Color.mabeBlue)
                .frame(width: 72, height: 72)
                .background(Color.mabeBlue.opacity(0.1))
                .clipShape(Circle())

            VStack(spacing: 8) {
                Text("Hablar con RH")
                    .font(.mabeHeadline)
                    .foregroundStyle(Color.mabeGray900)
                Text("Tu caso será canalizado con un especialista de RH.")
                    .font(.mabeSub)
                    .foregroundStyle(Color.mabeGray600)
                    .multilineTextAlignment(.center)
                Text(context)
                    .font(.mabeCaption)
                    .foregroundStyle(Color.mabeGray400)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 10) {
                Button {
                    dismiss()
                } label: {
                    Text("Crear caso")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(LinearGradient.mabeHero)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                Button("Cancelar") {
                    dismiss()
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.mabeGray600)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            }
        }
        .padding(24)
        .presentationDetents([.height(360)])
        .presentationDragIndicator(.visible)
        .background(Color.mabeBackground)
    }
}
