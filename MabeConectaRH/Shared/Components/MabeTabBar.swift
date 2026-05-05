import SwiftUI

enum MainTab: String, CaseIterable, Identifiable {
    case home
    case assistant
    case benefits
    case rh

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "Inicio"
        case .assistant: "Asistente"
        case .benefits: "Beneficios"
        case .rh: "Mi RH"
        }
    }

    var icon: String {
        switch self {
        case .home: "house"
        case .assistant: "bubble.left.and.bubble.right"
        case .benefits: "ticket"
        case .rh: "person.crop.circle"
        }
    }

    var iconFilled: String {
        switch self {
        case .home: "house.fill"
        case .assistant: "bubble.left.and.bubble.right.fill"
        case .benefits: "ticket.fill"
        case .rh: "person.crop.circle.fill"
        }
    }
}

struct MabeTabBar: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases) { tab in
                TabBarItem(tab: tab, isSelected: selectedTab == tab) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                        Haptics.impact(.light)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.mabeGray900.opacity(0.12), radius: 24, x: 0, y: 8)
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}

struct AppTabBar: View {
    @Binding var selectedIndex: Int
    @Namespace private var tabNamespace
    private let tabs = MainTab.allCases

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                FixedTabBarButton(
                    tab: tab,
                    namespace: tabNamespace,
                    isSelected: selectedIndex == index
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedIndex = index
                        Haptics.impact(.light)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .frame(height: 64)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Color.white.opacity(0.65), lineWidth: 1)
        }
        .shadow(color: Color(hex: "#0D1B3E").opacity(0.1), radius: 20, x: 0, y: -6)
        .padding(.horizontal, 20)
    }
}

private struct FixedTabBarButton: View {
    let tab: MainTab
    let namespace: Namespace.ID
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#003087"), Color(hex: "#1976FF")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 28)
                            .matchedGeometryEffect(id: "tabPill", in: namespace)
                    }

                    Image(systemName: isSelected ? tab.iconFilled : tab.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.white : Color(hex: "#9AA5BE"))
                        .animation(.none, value: isSelected)
                }
                .frame(height: 28)

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? Color(hex: "#003087") : Color(hex: "#9AA5BE"))
                    .frame(height: 14)
                    .animation(.none, value: isSelected)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
    }
}

private struct TabBarItem: View {
    let tab: MainTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(LinearGradient.mabeHero)
                            .frame(width: 52, height: 32)
                            .transition(.scale.combined(with: .opacity))
                    }

                    Image(systemName: isSelected ? tab.iconFilled : tab.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.white : Color.mabeGray400)
                        .scaleEffect(isSelected ? 1.05 : 1)
                }

                Text(tab.title)
                    .font(.mabeLabel)
                    .foregroundStyle(isSelected ? Color.mabeBlue : Color.mabeGray400)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
    }
}
