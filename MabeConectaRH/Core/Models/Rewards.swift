import Foundation
import SwiftUI

enum RewardTier: Int, CaseIterable, Codable, Comparable {
    case bronce = 0
    case plata = 1
    case oro = 2
    case platino = 3

    static func < (lhs: RewardTier, rhs: RewardTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var nombre: String {
        switch self {
        case .bronce: "Bronce"
        case .plata: "Plata"
        case .oro: "Oro"
        case .platino: "Platino"
        }
    }

    var emoji: String {
        switch self {
        case .bronce: "🥉"
        case .plata: "🥈"
        case .oro: "🥇"
        case .platino: "💎"
        }
    }

    var puntosMinimos: Int {
        switch self {
        case .bronce: 0
        case .plata: 500
        case .oro: 1500
        case .platino: 3500
        }
    }

    var puntosParaSiguiente: Int {
        switch self {
        case .bronce: 500
        case .plata: 1500
        case .oro: 3500
        case .platino: Int.max
        }
    }

    var multiplicador: Double {
        switch self {
        case .bronce: 1.0
        case .plata: 1.25
        case .oro: 1.5
        case .platino: 2.0
        }
    }

    var color: Color {
        switch self {
        case .bronce: Color(hex: "#B45309")
        case .plata: Color(hex: "#64748B")
        case .oro: Color(hex: "#D97706")
        case .platino: Color(hex: "#7C5CFC")
        }
    }

    var backgroundColor: Color {
        switch self {
        case .bronce: Color(hex: "#FEF3C7")
        case .plata: Color(hex: "#F1F5F9")
        case .oro: Color(hex: "#FAEEDA")
        case .platino: Color(hex: "#EEEDFE")
        }
    }

    var beneficiosExclusivos: [String] {
        switch self {
        case .bronce:
            ["Acceso a cupones básicos", "Check-in de bienestar"]
        case .plata:
            ["Cupones premium", "Prioridad en solicitudes", "Resumen semanal IA"]
        case .oro:
            ["Cupones exclusivos", "Día adicional de homeoffice*", "Acceso anticipado a beneficios"]
        case .platino:
            ["Todos los beneficios Oro", "Reconocimiento en planta", "Cupones sin límite mensual"]
        }
    }

    var next: RewardTier {
        RewardTier(rawValue: rawValue + 1) ?? .platino
    }
}

struct RewardEvent: Identifiable, Codable {
    let id: UUID
    let tipo: TipoEvento
    let puntos: Int
    let puntosFinales: Int
    let descripcion: String
    let fecha: Date
    let fuente: FuentePuntos

    enum FuentePuntos: String, Codable {
        case app
        case desempeno
    }

    enum TipoEvento: String, Codable {
        case checkinBienestar
        case rachaSemanal
        case solicitudCompletada
        case cuponCanjeado
        case consultaAsistente
        case onboardingCompletado
        case perfilCompletado
        case primeraVez
        case evaluacionCuatrimestral
        case asistenciaPerfecta
        case capacitacionCompletada
        case reconocimientoPares

        var icon: String {
            switch self {
            case .checkinBienestar: "face.smiling"
            case .rachaSemanal: "flame.fill"
            case .solicitudCompletada: "checkmark.circle.fill"
            case .cuponCanjeado: "ticket.fill"
            case .consultaAsistente: "bubble.left.fill"
            case .onboardingCompletado: "star.fill"
            case .perfilCompletado: "person.fill"
            case .primeraVez: "sparkles"
            case .evaluacionCuatrimestral: "chart.bar.fill"
            case .asistenciaPerfecta: "calendar.badge.checkmark"
            case .capacitacionCompletada: "graduationcap.fill"
            case .reconocimientoPares: "hand.thumbsup.fill"
            }
        }
    }
}

struct Logro: Identifiable {
    let id: String
    let nombre: String
    let descripcion: String
    let icon: String
    let color: Color
    let condicion: (RewardProfile) -> Bool
    let rareza: Rareza

    enum Rareza: String {
        case comun = "Común"
        case raro = "Raro"
        case epico = "Épico"
        case legendario = "Legendario"

        var color: Color {
            switch self {
            case .comun: Color(hex: "#64748B")
            case .raro: Color(hex: "#1565C0")
            case .epico: Color(hex: "#7C5CFC")
            case .legendario: Color(hex: "#D97706")
            }
        }
    }
}

struct RewardProfile: Codable {
    var puntosAcumulados: Int = 0
    var puntosDisponibles: Int = 0
    var tier: RewardTier = .bronce
    var eventos: [RewardEvent] = []
    var logrosDesbloqueados: Set<String> = []
    var rachaActual: Int = 0
    var cuatrimestresConBono: Int = 0
    var fechaUltimoCheckin: Date?

    mutating func recalcularTier() {
        tier = RewardTier.allCases.last { $0.puntosMinimos <= puntosAcumulados } ?? .bronce
    }

    var progresoSiguienteTier: Double {
        guard tier != .platino else { return 1.0 }
        let inicio = Double(tier.puntosMinimos)
        let fin = Double(tier.puntosParaSiguiente)
        let actual = Double(puntosAcumulados)
        return min(max((actual - inicio) / (fin - inicio), 0), 1)
    }

    var puntosParaSiguienteTier: Int {
        guard tier != .platino else { return 0 }
        return max(0, tier.puntosParaSiguiente - puntosAcumulados)
    }
}

struct LogrosCatalogo {
    static let todos: [Logro] = [
        Logro(
            id: "primer_paso",
            nombre: "Primer paso",
            descripcion: "Completaste tu primer check-in de bienestar",
            icon: "figure.walk",
            color: Color(hex: "#00875A"),
            condicion: { $0.eventos.contains { $0.tipo == .checkinBienestar } },
            rareza: .comun
        ),
        Logro(
            id: "racha_7",
            nombre: "Una semana seguida",
            descripcion: "7 días consecutivos de check-in",
            icon: "flame.fill",
            color: Color(hex: "#D97706"),
            condicion: { $0.rachaActual >= 7 },
            rareza: .raro
        ),
        Logro(
            id: "racha_30",
            nombre: "Mes dedicado",
            descripcion: "30 días consecutivos de check-in",
            icon: "medal.fill",
            color: Color(hex: "#7C5CFC"),
            condicion: { $0.rachaActual >= 30 },
            rareza: .epico
        ),
        Logro(
            id: "primer_cuatrimestre",
            nombre: "Evaluación reconocida",
            descripcion: "Recibiste puntos por tu desempeño cuatrimestral",
            icon: "chart.bar.fill",
            color: Color(hex: "#1565C0"),
            condicion: { $0.cuatrimestresConBono >= 1 },
            rareza: .raro
        ),
        Logro(
            id: "tres_cuatrimestres",
            nombre: "Consistencia de acero",
            descripcion: "3 cuatrimestres seguidos con puntos de desempeño",
            icon: "bolt.fill",
            color: Color(hex: "#D97706"),
            condicion: { $0.cuatrimestresConBono >= 3 },
            rareza: .epico
        ),
        Logro(
            id: "nivel_plata",
            nombre: "Subiste a Plata",
            descripcion: "Alcanzaste el nivel Plata",
            icon: "star.fill",
            color: Color(hex: "#64748B"),
            condicion: { $0.tier >= .plata },
            rareza: .raro
        ),
        Logro(
            id: "nivel_oro",
            nombre: "Llegaste al Oro",
            descripcion: "Alcanzaste el nivel Oro",
            icon: "crown.fill",
            color: Color(hex: "#D97706"),
            condicion: { $0.tier >= .oro },
            rareza: .epico
        ),
        Logro(
            id: "nivel_platino",
            nombre: "Élite Mabe",
            descripcion: "Alcanzaste el nivel Platino",
            icon: "diamond.fill",
            color: Color(hex: "#7C5CFC"),
            condicion: { $0.tier == .platino },
            rareza: .legendario
        ),
        Logro(
            id: "cinco_cupones",
            nombre: "Aprovecha tus beneficios",
            descripcion: "Canjeaste 5 cupones",
            icon: "ticket.fill",
            color: Color(hex: "#EC4899"),
            condicion: { $0.eventos.filter { $0.tipo == .cuponCanjeado }.count >= 5 },
            rareza: .comun
        ),
        Logro(
            id: "mil_puntos",
            nombre: "Primer millar",
            descripcion: "Acumulaste 1,000 puntos en total",
            icon: "trophy.fill",
            color: Color(hex: "#D97706"),
            condicion: { $0.puntosAcumulados >= 1000 },
            rareza: .raro
        )
    ]
}
