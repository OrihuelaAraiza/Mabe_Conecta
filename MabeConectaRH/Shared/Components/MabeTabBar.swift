import SwiftUI

enum MainTab: String, CaseIterable, Identifiable {
    case home
    case assistant
    case rh

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "Inicio"
        case .assistant: "Asistente"
        case .rh: "Mi RH"
        }
    }

    var icon: String {
        switch self {
        case .home: "house"
        case .assistant: "bubble.left.and.bubble.right"
        case .rh: "person.crop.circle"
        }
    }

    var iconFilled: String {
        switch self {
        case .home: "house.fill"
        case .assistant: "bubble.left.and.bubble.right.fill"
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
