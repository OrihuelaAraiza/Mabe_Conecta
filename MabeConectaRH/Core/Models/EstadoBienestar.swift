import Foundation

enum EstadoBienestar: String, CaseIterable, Identifiable {
    case triste = "Triste"
    case bajo = "Bajo"
    case neutral = "Neutral"
    case bien = "Bien"
    case excelente = "Excelente"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .triste: "😔"
        case .bajo: "😕"
        case .neutral: "😐"
        case .bien: "🙂"
        case .excelente: "😊"
        }
    }

    var necesitaApoyo: Bool {
        self == .triste || self == .bajo
    }
}
