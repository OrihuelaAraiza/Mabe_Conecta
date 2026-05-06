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
            MabeIndustrialPattern(opacity: 0.035, color: .mabePrimary)
                .ignoresSafeArea()

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
                                    MabeHaptics.shared.loginSuccess()
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

                        demoAccessSection
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

    private var demoAccessSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.mabeGray200)
                    .frame(height: 1)
                Text("Modo demo")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.mabeGray500)
                    .textCase(.uppercase)
                    .tracking(0.8)
                Rectangle()
                    .fill(Color.mabeGray200)
                    .frame(height: 1)
            }
            .padding(.top, 4)

            HStack(spacing: 10) {
                demoButton(
                    title: "Empleado",
                    subtitle: "Colaborador",
                    icon: "person.fill",
                    color: Color.mabeBlue
                ) {
                    signInDemo(user: viewModel.loginDemoEmpleado(), role: .empleado)
                }

                demoButton(
                    title: "RH",
                    subtitle: "Administrador",
                    icon: "shield.checkered",
                    color: Color(hex: "#D97706")
                ) {
                    signInDemo(user: viewModel.loginDemoRH(), role: .agenteRH)
                }
            }
        }
        .padding(.top, 4)
    }

    private func demoButton(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.mabeGray900)
                    Text(subtitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.mabeGray500)
                }

                Spacer(minLength: 0)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color.mabeSurface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(color.opacity(0.16), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Entrar en modo demo como \(title)")
    }

    private func signInDemo(user: Empleado, role: UserRole) {
        MabeHaptics.shared.loginSuccess()
        appState.hasCompletedOnboarding = preferencesStore.hasCompletedOnboarding
        appState.signIn(user: user, role: role, isDemo: true)
    }
}

private extension View {
    func premiumEntrance(_ isVisible: Bool, index: Int) -> some View {
        opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .animation(.spring(response: 0.5, dampingFraction: 0.86).delay(Double(index) * 0.08), value: isVisible)
    }
}
