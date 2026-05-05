import SwiftUI

struct HeroFeature {
    let id: String
    let icon: String
    let gradient: LinearGradient
    let shadowColor: Color
    let unidad: String
    let valorPrincipal: (Empleado) -> String
    let subtitulo: (Empleado) -> String

    static func from(_ id: String) -> HeroFeature {
        features[id] ?? features["vacaciones"]!
    }

    static let features: [String: HeroFeature] = [
        "vacaciones": HeroFeature(
            id: "vacaciones",
            icon: "beach.umbrella.fill",
            gradient: LinearGradient(
                colors: [Color(hex: "#003087"), Color(hex: "#1976FF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            shadowColor: Color(hex: "#1976FF").opacity(0.35),
            unidad: "días",
            valorPrincipal: { "\($0.diasVacacionesDisponibles)" },
            subtitulo: { _ in "disponibles · Próx. corte 15 ene" }
        ),
        "nomina": HeroFeature(
            id: "nomina",
            icon: "banknote.fill",
            gradient: LinearGradient(
                colors: [Color(hex: "#00704A"), Color(hex: "#00A36C")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            shadowColor: Color(hex: "#00A36C").opacity(0.35),
            unidad: "",
            valorPrincipal: { _ in "15 nov" },
            subtitulo: { _ in "Próximo depósito de nómina" }
        ),
        "constancias": HeroFeature(
            id: "constancias",
            icon: "doc.badge.arrow.up.fill",
            gradient: LinearGradient(
                colors: [Color(hex: "#5C3BC1"), Color(hex: "#7C5CFC")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            shadowColor: Color(hex: "#7C5CFC").opacity(0.35),
            unidad: "lista",
            valorPrincipal: { _ in "Lista" },
            subtitulo: { _ in "Tu constancia de empleo está disponible" }
        ),
        "permisos": HeroFeature(
            id: "permisos",
            icon: "calendar.badge.checkmark",
            gradient: LinearGradient(
                colors: [Color(hex: "#B45309"), Color(hex: "#D97706")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            shadowColor: Color(hex: "#D97706").opacity(0.35),
            unidad: "pend.",
            valorPrincipal: { _ in "0" },
            subtitulo: { _ in "Sin permisos pendientes de aprobación" }
        ),
        "incapacidades": HeroFeature(
            id: "incapacidades",
            icon: "cross.case.fill",
            gradient: LinearGradient(
                colors: [Color(hex: "#BE185D"), Color(hex: "#EC4899")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            shadowColor: Color(hex: "#EC4899").opacity(0.35),
            unidad: "días",
            valorPrincipal: { _ in "0" },
            subtitulo: { _ in "Sin incapacidades activas" }
        ),
        "historial": HeroFeature(
            id: "historial",
            icon: "chart.bar.fill",
            gradient: LinearGradient(
                colors: [Color(hex: "#0E7490"), Color(hex: "#0EA5E9")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            shadowColor: Color(hex: "#0EA5E9").opacity(0.35),
            unidad: "trám.",
            valorPrincipal: { _ in "3" },
            subtitulo: { _ in "Trámites completados este mes" }
        )
    ]
}
