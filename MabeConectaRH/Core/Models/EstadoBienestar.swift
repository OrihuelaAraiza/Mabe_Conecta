import Foundation
import SwiftUI

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

enum MoodOption: Int, CaseIterable, Codable {
    case dificil = 1
    case cansado = 2
    case regular = 3
    case bien = 4
    case excelente = 5

    var emoji: String {
        switch self {
        case .dificil: "😔"
        case .cansado: "😕"
        case .regular: "😐"
        case .bien: "🙂"
        case .excelente: "😊"
        }
    }

    var label: String {
        switch self {
        case .dificil: "Difícil"
        case .cansado: "Cansado"
        case .regular: "Regular"
        case .bien: "Bien"
        case .excelente: "Excelente"
        }
    }

    var color: Color {
        switch self {
        case .dificil: Color(hex: "#F03E3E")
        case .cansado: Color(hex: "#D97706")
        case .regular: Color(hex: "#9AA5BE")
        case .bien: Color(hex: "#00C27C")
        case .excelente: Color(hex: "#1976FF")
        }
    }

    var descripcion: String {
        switch self {
        case .dificil: "Es un día complicado. Está bien no estar bien."
        case .cansado: "El cansancio es señal de que diste mucho hoy."
        case .regular: "Un día neutral también cuenta."
        case .bien: "Vas bien. Mantén ese ritmo positivo."
        case .excelente: "Estás en tu mejor momento. Aprovéchalo."
        }
    }

    var consejo: String {
        switch self {
        case .dificil: "Considera tomar una pausa y hablar con alguien."
        case .cansado: "Una pausa de cinco minutos puede hacer diferencia."
        case .regular: "Pequeñas victorias pueden mejorar el día."
        case .bien: "Comparte esa energía con tu equipo."
        case .excelente: "Piensa qué hábito te ayudó a sentirte así."
        }
    }

    var numericValue: Int { rawValue }

    static func from(value: Int) -> MoodOption? {
        MoodOption(rawValue: value)
    }
}

enum FactorBienestar: String, CaseIterable, Codable {
    case trabajo
    case relaciones
    case salud
    case sueno
    case familia
    case economia
    case ruido
    case calor
    case carga

    var label: String {
        switch self {
        case .trabajo: "Carga de trabajo"
        case .relaciones: "Relaciones"
        case .salud: "Salud física"
        case .sueno: "Sueño"
        case .familia: "Familia"
        case .economia: "Economía"
        case .ruido: "Ruido en planta"
        case .calor: "Temperatura"
        case .carga: "Estrés acumulado"
        }
    }

    var icon: String {
        switch self {
        case .trabajo: "briefcase.fill"
        case .relaciones: "person.2.fill"
        case .salud: "cross.fill"
        case .sueno: "moon.zzz.fill"
        case .familia: "house.fill"
        case .economia: "banknote.fill"
        case .ruido: "speaker.wave.3.fill"
        case .calor: "thermometer.sun.fill"
        case .carga: "brain.head.profile"
        }
    }

    var color: Color {
        switch self {
        case .trabajo: Color(hex: "#003087")
        case .relaciones: Color(hex: "#EC4899")
        case .salud: Color(hex: "#00C27C")
        case .sueno: Color(hex: "#7C5CFC")
        case .familia: Color(hex: "#D97706")
        case .economia: Color(hex: "#00704A")
        case .ruido: Color(hex: "#F03E3E")
        case .calor: Color(hex: "#D97706")
        case .carga: Color(hex: "#5C3BC1")
        }
    }
}

struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let mood: MoodOption
    let fecha: Date
    let nota: String?
}

struct CheckInResultado {
    let mood: MoodOption
    let energia: Int
    let factores: [FactorBienestar]
    let nota: String?
}

struct RecursoBienestar: Identifiable {
    let id: String
    let titulo: String
    let icon: String
    let color: Color
    let duracion: String
    let tipoIcon: String
    let prioridad: Prioridad

    enum Prioridad {
        case alta
        case normal
    }
}
