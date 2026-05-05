import SwiftUI

enum LottieLoopMode {
    case playOnce
    case loop
}

struct LottieView: View {
    let name: String
    var loopMode: LottieLoopMode = .playOnce
    var speed: CGFloat = 1.0
    var onComplete: (() -> Void)? = nil
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            switch name {
            case "success_check":
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72, weight: .semibold))
                    .foregroundStyle(Color.mabeSuccess)
                    .scaleEffect(isAnimating ? 1 : 0.72)
                    .opacity(isAnimating ? 1 : 0)
            case "empty_inbox":
                Image(systemName: "tray")
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(Color.mabeGray400)
            default:
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.mabeBlue)
                            .frame(width: 8, height: 8)
                            .scaleEffect(isAnimating ? 1 : 0.45)
                            .animation(.easeInOut(duration: 0.55).repeatForever().delay(Double(index) * 0.12), value: isAnimating)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                isAnimating = true
            }
            if loopMode == .playOnce {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    onComplete?()
                }
            }
        }
    }
}

struct PulsingDot: View {
    @State private var pulsing = false
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: 14, height: 14)
                .scaleEffect(pulsing ? 1.8 : 1.0)
                .opacity(pulsing ? 0 : 0.6)
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false)) {
                pulsing = true
            }
        }
    }
}

struct PressableCard<Content: View>: View {
    let action: () -> Void
    @ViewBuilder let content: () -> Content
    @State private var pressed = false

    var body: some View {
        content()
            .scaleEffect(pressed ? 0.97 : 1.0)
            .brightness(pressed ? -0.02 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: pressed)
            .onTapGesture {
                withAnimation { pressed = true }
                Haptics.impact(.light)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation { pressed = false }
                    action()
                }
            }
    }
}

struct AnimatedNumber: View {
    let target: Double
    var prefix: String = ""
    var suffix: String = ""
    @State private var current: Double = 0

    var body: some View {
        Text("\(prefix)\(Int(current))\(suffix)")
            .contentTransition(.numericText(value: current))
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    current = target
                }
            }
    }
}

struct HomeSkeletonView: View {
    var body: some View {
        VStack(spacing: 16) {
            SkeletonView(height: 170, cornerRadius: 24)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in
                    SkeletonView(height: 110, cornerRadius: 20)
                }
            }

            ForEach(0..<3, id: \.self) { _ in
                SkeletonView(height: 72, cornerRadius: 16)
            }
        }
        .padding(.horizontal, 20)
    }
}

struct SolicitudConfirmedView: View {
    @State private var burst = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                LottieView(name: "success_check", loopMode: .playOnce)
                    .frame(width: 120, height: 120)

                Text("¡Solicitud enviada!")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#0D1B3E"))

                Text("Tu solicitud fue recibida.\nTe notificaremos cuando sea revisada.")
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "#4B5675"))
                    .multilineTextAlignment(.center)
            }

            ForEach(0..<18, id: \.self) { index in
                Circle()
                    .fill([Color.mabeBlue, Color.mabeElectric, Color.mabeSuccess, .white][index % 4])
                    .frame(width: 7, height: 7)
                    .offset(y: burst ? -CGFloat(70 + (index % 5) * 22) : 0)
                    .rotationEffect(.degrees(Double(index) * 20))
                    .opacity(burst ? 0 : 1)
                    .animation(.easeOut(duration: 1.0).delay(Double(index) * 0.02), value: burst)
            }
        }
        .onAppear { burst = true }
    }
}
