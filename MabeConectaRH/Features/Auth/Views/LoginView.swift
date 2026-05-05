import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState
    @Environment(UserPreferencesStore.self) private var preferencesStore
    @State private var viewModel = LoginViewModel()
    @State private var didAppear = false
    @State private var isRHMode = false

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack {
            Color.mabeBackground.ignoresSafeArea()

            Ellipse()
                .fill(LinearGradient.mabeHero)
                .frame(width: 500, height: 400)
                .blur(radius: 60)
                .opacity(0.15)
                .offset(x: 80, y: -180)
                .accessibilityHidden(true)

            Circle()
                .fill(Color.mabeElectric)
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .opacity(0.08)
                .offset(x: -120, y: -100)
                .accessibilityHidden(true)

            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 32)

                    MabeLogoView()
                        .padding(.bottom, 22)
                        .premiumEntrance(didAppear, index: 0)

                    VStack(spacing: 6) {
                        Text("Bienvenido")
                            .font(.mabeHeadline)
                            .foregroundStyle(Color.mabeGray900)
                        Text("Ingresa con tu número de empleado")
                            .font(.mabeSub)
                            .foregroundStyle(Color.mabeGray600)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 24)
                    .premiumEntrance(didAppear, index: 1)

                    VStack(spacing: 12) {
                        MabeTextField(
                            placeholder: "Número de empleado",
                            text: $viewModel.numeroEmpleado,
                            keyboardType: .numberPad,
                            submitLabel: .next,
                            highlightColor: isRHMode ? Color(hex: "#D97706") : nil
                        )

                        if isRHMode {
                            HStack(spacing: 6) {
                                Image(systemName: "shield.checkered")
                                    .font(.system(size: 11, weight: .semibold))
                                Text("Acceso Administrador RH")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(Color(hex: "#D97706"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "#D97706").opacity(0.1))
                            .clipShape(Capsule())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.scale(scale: 0.8).combined(with: .opacity))
                        }

                        MabeTextField(
                            placeholder: "NIP",
                            text: $viewModel.nip,
                            isSecure: true,
                            keyboardType: .numberPad
                        )

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.mabeCaption)
                                .foregroundStyle(Color.mabeDanger)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .transition(.opacity)
                        }

                        MabePrimaryButton(
                            title: viewModel.isLoading ? "Validando..." : "Ingresar",
                            icon: viewModel.isLoading ? nil : "arrow.right",
                            isDisabled: !viewModel.canSubmit,
                            isLoading: viewModel.isLoading
                        ) {
                            Task {
                                if let result = await viewModel.login() {
                                    appState.hasCompletedOnboarding = preferencesStore.hasCompletedOnboarding
                                    appState.signIn(user: result.0, role: result.1, isDemo: false)
                                }
                            }
                        }
                        .padding(.top, 6)

                        Button("¿Olvidaste tu NIP? Contacta a RH") {}
                            .font(.mabeCaption)
                            .foregroundStyle(Color.mabeLightBlue)
                            .frame(minHeight: 40)
                            .accessibilityLabel("Olvidaste tu NIP, contacta a RH")
                    }
                    .frame(maxWidth: 360)
                    .padding(.horizontal, MabeTheme.horizontalPadding)
                    .premiumEntrance(didAppear, index: 2)

                    Spacer(minLength: 40)

                    VStack(spacing: 4) {
                        Text("Mabe Conecta RH v1.0")
                        Text("Uso interno para colaboradores Mabe")
                    }
                    .font(.mabeCaption)
                    .foregroundStyle(Color.mabeGray400)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, MabeTheme.horizontalPadding)
                    .padding(.bottom, 20)
                    .premiumEntrance(didAppear, index: 3)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 620)
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button("Demo") {
                        let empleado = viewModel.loginDemo()
                        appState.hasCompletedOnboarding = preferencesStore.hasCompletedOnboarding
                        appState.signIn(user: empleado, role: .empleado, isDemo: true)
                    }
                    .font(.mabeCaption)
                    .foregroundStyle(Color.mabeGray400)
                    .frame(minWidth: 44, minHeight: 44)
                    .padding(.trailing, 18)
                    .padding(.bottom, 18)
                    .accessibilityLabel("Entrar en modo demo")
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.errorMessage)
        .animation(.easeInOut(duration: 0.3), value: isRHMode)
        .onChange(of: viewModel.numeroEmpleado) { _, value in
            isRHMode = value == "99001"
        }
        .preferredColorScheme(.light)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.86)) {
                didAppear = true
            }
        }
    }
}

private extension View {
    func premiumEntrance(_ isVisible: Bool, index: Int) -> some View {
        opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .animation(.spring(response: 0.5, dampingFraction: 0.86).delay(Double(index) * 0.08), value: isVisible)
    }
}
