import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(CoreHaptics)
import CoreHaptics
#endif

enum Haptics {
    enum ImpactStyle {
        case light
        case medium
    }

    static func impact(_ style: ImpactStyle = .light) {
        #if canImport(UIKit)
        let uiStyle: UIImpactFeedbackGenerator.FeedbackStyle = style == .medium ? .medium : .light
        UIImpactFeedbackGenerator(style: uiStyle).impactOccurred()
        #endif
    }
}

final class MabeHaptics {
    static let shared = MabeHaptics()

    #if canImport(CoreHaptics)
    private var engine: CHHapticEngine?
    #endif

    private init() {
        prepareEngine()
    }

    func prepareEngine() {
        #if canImport(CoreHaptics)
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        engine = try? CHHapticEngine()
        try? engine?.start()
        #endif
    }

    func loginSuccess() {
        play(pattern: [
            (intensity: 0.4, sharpness: 0.3, time: 0.0),
            (intensity: 0.4, sharpness: 0.3, time: 0.12),
            (intensity: 0.8, sharpness: 0.6, time: 0.28)
        ])
    }

    func requestSent() {
        play(pattern: [
            (intensity: 0.3, sharpness: 0.2, time: 0.0),
            (intensity: 0.5, sharpness: 0.4, time: 0.1),
            (intensity: 0.7, sharpness: 0.6, time: 0.2),
            (intensity: 1.0, sharpness: 0.8, time: 0.3)
        ])
    }

    func error() {
        play(pattern: [
            (intensity: 0.8, sharpness: 0.9, time: 0.0),
            (intensity: 0.8, sharpness: 0.9, time: 0.15)
        ])
    }

    func tabChange() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.7)
        #endif
    }

    func moodSelected(_ mood: MoodOption) {
        #if canImport(UIKit)
        switch mood {
        case .dificil:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .cansado:
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        case .regular:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .bien:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .excelente:
            loginSuccess()
        }
        #endif
    }

    private func play(pattern: [(intensity: Float, sharpness: Float, time: TimeInterval)]) {
        #if canImport(CoreHaptics)
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine
        else { return }

        let events = pattern.map {
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: $0.intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: $0.sharpness)
                ],
                relativeTime: $0.time
            )
        }

        guard let hapticPattern = try? CHHapticPattern(events: events, parameters: []),
              let player = try? engine.makePlayer(with: hapticPattern)
        else { return }
        try? player.start(atTime: 0)
        #endif
    }
}
