import Foundation
import SwiftUI

enum CouponStatus: String, CaseIterable, Identifiable {
    case available
    case used
    case expired
    case expiringSoon

    var id: String { rawValue }

    var title: String {
        switch self {
        case .available: "Disponible"
        case .used: "Usado"
        case .expired: "Expirado"
        case .expiringSoon: "Expira pronto"
        }
    }

    var color: Color {
        switch self {
        case .available: .mabeSuccess
        case .used: .mabeBlue
        case .expired: .mabeDanger
        case .expiringSoon: .mabeWarning
        }
    }
}

enum CouponCategory: String, CaseIterable, Identifiable {
    case hogar = "Hogar"
    case alimentacion = "Alimentación"
    case bienestar = "Bienestar"
    case familia = "Familia"
    case transporte = "Transporte"
    case educacion = "Educación"

    var id: String { rawValue }
}

struct Coupon: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let category: CouponCategory
    let expirationDate: Date
    var status: CouponStatus
    let valueText: String
    let partnerName: String
    let recommendedReason: String?
    let iconName: String
    var usedDate: Date?

    var isUsable: Bool {
        status == .available || status == .expiringSoon
    }
}

struct Cupon: Identifiable {
    let id: String
    let titulo: String
    let empresa: String
    let descripcion: String
    let icon: String
    let gradient: LinearGradient
    let categoria: CuponCategory
    let puntosCosto: Int
    let vencimiento: String
    let fechaVencimiento: Date?
    let codigoPromo: String
    let terminos: [String]
}

enum CuponCategory: CaseIterable {
    case todos
    case comida
    case transporte
    case salud
    case entretenimiento
    case tienda

    var label: String {
        switch self {
        case .todos: "Todos"
        case .comida: "Comida"
        case .transporte: "Transporte"
        case .salud: "Salud"
        case .entretenimiento: "Ocio"
        case .tienda: "Tienda"
        }
    }

    var icon: String {
        switch self {
        case .todos: "square.grid.2x2"
        case .comida: "fork.knife"
        case .transporte: "car.fill"
        case .salud: "cross.fill"
        case .entretenimiento: "ticket.fill"
        case .tienda: "bag.fill"
        }
    }
}
