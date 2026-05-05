import SwiftUI

enum CategoriaPrestacion: String, CaseIterable {
    case economica = "Económicas"
    case saludBienestar = "Salud y bienestar"
    case desarrollo = "Desarrollo académico"
    case convenios = "Convenios"

    var icon: String {
        switch self {
        case .economica: "dollarsign.circle.fill"
        case .saludBienestar: "heart.circle.fill"
        case .desarrollo: "graduationcap.fill"
        case .convenios: "tag.fill"
        }
    }

    var color: Color {
        switch self {
        case .economica: Color(hex: "#003087")
        case .saludBienestar: Color(hex: "#00C27C")
        case .desarrollo: Color(hex: "#7C5CFC")
        case .convenios: Color(hex: "#D97706")
        }
    }
}

struct Prestacion: Identifiable {
    let id: String
    let nombre: String
    let descripcion: String
    let detalle: String
    let valor: String
    let vsLey: String?
    let icon: String
    let color: Color
    let categoria: CategoriaPrestacion
    let badge: String?
    let esDestacada: Bool
}
