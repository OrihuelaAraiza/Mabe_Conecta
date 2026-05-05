import SwiftUI

struct HeroFeature {
    let id: String
    let icon: String
    let gradient: LinearGradient
    let shadowColor: Color
    let unidad: String
    let valorPrincipal: (Empleado) -> String
    let subtitulo: (Empleado) -> String
    let contextoTemporal: String

    static func from(_ id: String) -> HeroFeature {
        features[id] ?? features["vacaciones"]!
    }

    static func contextoParaVacaciones() -> String {
        let diasParaFinDeSemana = diasHastaViernes()
        if diasParaFinDeSemana == 0 { return "¡Hoy es viernes! ¿Te tomas un puente? 🎉" }
        if diasParaFinDeSemana == 1 { return "Mañana es viernes — buen momento para planear" }
        return "Próx. corte: 15 ene · \(diasParaFinDeSemana) días para el fin de semana"
    }

    static func contextoParaNomina() -> String {
        let dia = Calendar.current.component(.day, from: Date())
        if dia >= 14 && dia <= 16 { return "🔔 ¡Tu nómina se deposita esta semana!" }
        if dia >= 28 || dia <= 2 { return "🔔 ¡Tu nómina se deposita esta semana!" }
        let diasRestantes = dia < 15 ? 15 - dia : 30 - dia + 1
        return "Faltan \(diasRestantes) días para tu próximo depósito"
    }

    static func diasHastaViernes() -> Int {
        let weekday = Calendar.current.component(.weekday, from: Date())
        switch weekday {
        case 6: return 0
        case 7: return 6
        case 1: return 5
        default: return 6 - weekday
        }
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
            subtitulo: { _ in "disponibles este año" },
            contextoTemporal: contextoParaVacaciones()
        ),
        "nomina": HeroFeature(
            id: "nomina",
            icon: "banknote.fill",
            gradient: LinearGradient(
                colors: [Color(hex: "#00704A"), Color(hex: "#00C27C")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            shadowColor: Color(hex: "#00C27C").opacity(0.35),
            unidad: "",
            valorPrincipal: { _ in "15 nov" },
            subtitulo: { _ in "próximo depósito" },
            contextoTemporal: contextoParaNomina()
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
            unidad: "",
            valorPrincipal: { _ in "1 lista" },
            subtitulo: { _ in "constancia de empleo" },
            contextoTemporal: "Tu última constancia fue hace 15 días"
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
            subtitulo: { _ in "sin permisos pendientes" },
            contextoTemporal: "Sin solicitudes activas esta semana"
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
            unidad: "activas",
            valorPrincipal: { _ in "0" },
            subtitulo: { _ in "incapacidades" },
            contextoTemporal: "Todo en orden ✓ Sin registros activos"
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
            subtitulo: { _ in "completados este mes" },
            contextoTemporal: "Noviembre · 3 completados, 1 en revisión"
        )
    ]
}
