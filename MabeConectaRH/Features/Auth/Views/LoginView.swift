import SwiftUI

struct LoginView: View {
    let onLogin: (Empleado) -> Void
    @State private var viewModel = LoginViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack {
            LinearGradient(
                colors: [Color.mabeBlue.opacity(0.04), .white, .white],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 44)

                MabeLogoView()
                    .padding(.bottom, 28)

                VStack(spacing: 6) {
                    Text("Bienvenido")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.mabeGray900)
                    Text("Ingresa con tu número de empleado")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.mabeGray500)
                }
                .padding(.bottom, 28)

                VStack(spacing: 14) {
                    MabeTextField(
                        placeholder: "Número de empleado",
                        text: $viewModel.numeroEmpleado,
                        keyboardType: .numberPad,
                        submitLabel: .next
                    )
                    MabeTextField(
                        placeholder: "NIP",
                        text: $viewModel.nip,
                        isSecure: true,
                        keyboardType: .numberPad
                    )

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(Color.mabeDanger)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.opacity)
                    }

                    MabePrimaryButton(
                        title: viewModel.isLoading ? "Validando..." : "Ingresar",
                        icon: viewModel.isLoading ? nil : "arrow.right",
                        isDisabled: !viewModel.canSubmit
                    ) {
                        Task {
                            if let empleado = await viewModel.login() {
                                onLogin(empleado)
                            }
                        }
                    }
                    .padding(.top, 8)

                    Button("¿Olvidaste tu NIP? Contacta a RH") {}
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.mabeLightBlue)
                        .frame(minHeight: 44)
                        .accessibilityLabel("Olvidaste tu NIP, contacta a RH")
                }
                .padding(.horizontal, MabeTheme.horizontalPadding)

                Spacer()

                VStack(spacing: 4) {
                    Text("Mabe Conecta RH v1.0")
                    Text("Uso interno para colaboradores Mabe")
                }
                .font(.caption)
                .foregroundStyle(Color.mabeGray500)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MabeTheme.horizontalPadding)
                .padding(.bottom, 20)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.errorMessage)
    }
}
