import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @Environment(UserPreferencesStore.self) private var preferencesStore
    @State private var step = 0
    @State private var preferences = UserPreferences()

    private let intereses = [
        OnboardingChip(id: "vacaciones", icon: "calendar", title: "Vacaciones"),
        OnboardingChip(id: "constancias", icon: "doc.text", title: "Constancias"),
        OnboardingChip(id: "nomina", icon: "dollarsign.circle", title: "Nómina"),
        OnboardingChip(id: "permisos", icon: "checklist", title: "Permisos"),
        OnboardingChip(id: "incapacidades", icon: "cross.case", title: "Incapacidades"),
        OnboardingChip(id: "historial", icon: "chart.bar.doc.horizontal", title: "Mi historial")
    ]

    private let widgets = [
        WidgetOption(id: "vacaciones", title: "Días de vacaciones", description: "Ver tu saldo disponible"),
        WidgetOption(id: "solicitudes", title: "Solicitudes recientes", description: "Tus últimos trámites"),
        WidgetOption(id: "bienestar", title: "Check-in de bienestar", description: "Registra cómo te sientes"),
        WidgetOption(id: "accesos", title: "Accesos rápidos", description: "Los trámites más usados")
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $step) {
                welcomeStep.tag(0)
                interestsStep.tag(1)
                widgetsStep.tag(2)
                notificationsStep.tag(3)
            }
            .mabeOnboardingPageStyle()

            OnboardingDots(step: step, count: 4)
                .padding(.bottom, 18)

            if step < 3 {
                MabePrimaryButton(title: "Continuar") {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        step += 1
                    }
                }
                .padding(.horizontal, MabeTheme.horizontalPadding)
                .padding(.bottom, 24)
            }
        }
        .background(Color.mabeBackground)
        .onAppear {
            preferences = preferencesStore.preferences
            configurePageControl()
        }
    }

    private var welcomeStep: some View {
        VStack(spacing: 28) {
            Spacer()

            MabeLogoView()
                .scaleEffect(1.18)

            VStack(spacing: 8) {
                Text("Tu RH, siempre contigo")
                    .font(.mabeHeadline)
                    .foregroundStyle(Color.mabeGray900)
                    .multilineTextAlignment(.center)
                Text("Configura tu experiencia en 3 pasos. Toma menos de un minuto.")
                    .font(.mabeSub)
                    .foregroundStyle(Color.mabeGray400)
                    .multilineTextAlignment(.center)
            }

            ZStack {
                Circle()
                    .fill(Color.mabeBlue.opacity(0.08))
                    .frame(width: 170, height: 170)
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 76, weight: .semibold))
                    .foregroundStyle(Color.mabeBlue)
                    .offset(x: -24, y: 10)
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 58, weight: .semibold))
                    .foregroundStyle(Color.mabeLightBlue)
                    .offset(x: 42, y: -30)
            }
            .accessibilityHidden(true)

            Spacer()
        }
        .padding(MabeTheme.horizontalPadding)
    }

    private var interestsStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(
                title: "¿Qué consultas más seguido?",
                subtitle: "Tu asistente aprenderá a ayudarte mejor"
            )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(intereses) { item in
                    SelectableChip(
                        item: item,
                        isSelected: preferences.interesesSeleccionados.contains(item.id)
                    ) {
                        toggleInterest(item.id)
                    }
                }
            }

            Spacer()
        }
        .padding(MabeTheme.horizontalPadding)
        .padding(.top, 72)
    }

    private var widgetsStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepHeader(
                title: "Personaliza tu pantalla de inicio",
                subtitle: "Activa los widgets que quieres ver"
            )

            VStack(spacing: 0) {
                ForEach(widgets) { widget in
                    Toggle(isOn: bindingForWidget(widget.id)) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(widget.title)
                                .font(.mabeBody.weight(.medium))
                                .foregroundStyle(Color.mabeGray900)
                            Text(widget.description)
                                .font(.mabeSub)
                                .foregroundStyle(Color.mabeGray400)
                        }
                    }
                    .tint(.mabeBlue)
                    .padding(16)

                    if widget.id != widgets.last?.id {
                        Divider().padding(.leading, 16)
                    }
                }
            }
            .background(Color.mabeSurface)
            .clipShape(RoundedRectangle(cornerRadius: MabeTheme.cardRadius, style: .continuous))
            .mabeCardShadow()

            Spacer()
        }
        .padding(MabeTheme.horizontalPadding)
        .padding(.top, 72)
    }

    private var notificationsStep: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 82, weight: .semibold))
                .foregroundStyle(Color.mabeBlue)
                .frame(width: 150, height: 150)
                .background(Color.mabeBlue.opacity(0.08))
                .clipShape(Circle())

            VStack(spacing: 8) {
                Text("¿Te avisamos cuando haya novedades?")
                    .font(.mabeHeadline)
                    .foregroundStyle(Color.mabeGray900)
                    .multilineTextAlignment(.center)
                Text("Te notificaremos cuando tu solicitud cambie de estatus")
                    .font(.mabeSub)
                    .foregroundStyle(Color.mabeGray400)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 12) {
                MabePrimaryButton(title: "Sí, activar notificaciones") {
                    complete(notifications: true)
                }

                Button("Ahora no") {
                    complete(notifications: false)
                }
                .font(.mabeSub)
                .foregroundStyle(Color.mabeGray400)
                .frame(maxWidth: .infinity, minHeight: 48)
                .accessibilityLabel("Ahora no")
            }
        }
        .padding(MabeTheme.horizontalPadding)
        .padding(.bottom, 24)
    }

    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.mabeHeadline)
                .foregroundStyle(Color.mabeGray900)
            Text(subtitle)
                .font(.mabeSub)
                .foregroundStyle(Color.mabeGray400)
        }
    }

    private func toggleInterest(_ id: String) {
        Haptics.impact(.light)
        if preferences.interesesSeleccionados.contains(id) {
            preferences.interesesSeleccionados.removeAll { $0 == id }
        } else {
            preferences.interesesSeleccionados.append(id)
        }
    }

    private func bindingForWidget(_ id: String) -> Binding<Bool> {
        Binding {
            preferences.widgetsActivos.contains(id)
        } set: { isOn in
            if isOn {
                if !preferences.widgetsActivos.contains(id) {
                    preferences.widgetsActivos.append(id)
                }
                if !preferences.widgetsOrden.contains(id) {
                    preferences.widgetsOrden.append(id)
                }
            } else {
                preferences.widgetsActivos.removeAll { $0 == id }
            }
        }
    }

    private func complete(notifications: Bool) {
        let shortcuts = UserPreferences.defaultShortcuts(for: preferences.interesesSeleccionados)
        preferences.shortcutsActivos = shortcuts
        preferences.shortcutsOrden = shortcuts
        preferences.widgetsOrden = widgets.map(\.id).filter { preferences.widgetsActivos.contains($0) } + widgets.map(\.id).filter { !preferences.widgetsActivos.contains($0) }
        preferences.notificacionesActivas = notifications
        preferences.onboardingCompletado = true
        preferencesStore.save(preferences)
        withAnimation(.easeInOut(duration: 0.25)) {
            appState.hasCompletedOnboarding = true
        }
    }

    private func configurePageControl() {
        #if canImport(UIKit)
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.mabeBlue)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.mabeGray200)
        #endif
    }
}

private extension View {
    @ViewBuilder
    func mabeOnboardingPageStyle() -> some View {
        #if os(iOS)
        self
            .tabViewStyle(.page(indexDisplayMode: .never))
        #else
        self
        #endif
    }
}

private struct OnboardingDots: View {
    let step: Int
    let count: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == step ? AnyShapeStyle(LinearGradient.mabeHero) : AnyShapeStyle(Color.mabeGray200))
                    .frame(width: index == step ? 20 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.75), value: step)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct OnboardingChip: Identifiable {
    let id: String
    let icon: String
    let title: String
}

private struct WidgetOption: Identifiable {
    let id: String
    let title: String
    let description: String
}

private struct SelectableChip: View {
    let item: OnboardingChip
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: item.icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(item.title)
                    .font(.mabeCaption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Spacer(minLength: 0)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption.weight(.bold))
                }
            }
            .foregroundStyle(isSelected ? Color.mabeBlue : Color.mabeGray900)
            .padding(.horizontal, 12)
            .frame(minHeight: 58)
            .background(isSelected ? Color.mabeBlue.opacity(0.08) : Color.mabeSurface)
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color.mabeBlue : Color.mabeGray200, lineWidth: isSelected ? 2 : 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.title)
    }
}
