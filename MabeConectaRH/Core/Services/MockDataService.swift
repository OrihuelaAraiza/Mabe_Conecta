import Foundation
import SwiftUI

struct SolicitudRH: Identifiable {
    let id: String
    let empleadoNombre: String
    let empleadoId: String
    let ultimoMensaje: String
    let urgencia: Urgencia
    let tiempoRelativo: String

    var iniciales: String {
        empleadoNombre.split(separator: " ").prefix(2)
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
            .uppercased()
    }

    enum Urgencia {
        case alta
        case normal
    }
}

struct MockDataService {
    static let empleadoActual = Empleado(
        id: "12345",
        nombre: "Carlos",
        apellidos: "Ramírez Medina",
        puesto: "Técnico de Producción",
        departamento: "Línea de Ensamble A",
        planta: "Planta Querétaro",
        diasVacacionesDisponibles: 12,
        diasVacacionesTotales: 15
    )

    static let agenteRH = Empleado(
        id: "99001",
        nombre: "Laura",
        apellidos: "González Ríos",
        puesto: "Agente de Recursos Humanos",
        departamento: "Recursos Humanos",
        planta: "Planta Querétaro",
        diasVacacionesDisponibles: 8,
        diasVacacionesTotales: 15
    )

    static let directorioEmpleados: [Empleado] = [
        empleadoActual,
        Empleado(
            id: "10234",
            nombre: "Miguel",
            apellidos: "Torres Reyes",
            puesto: "Operador de Producción",
            departamento: "Línea B",
            planta: "Planta Querétaro",
            diasVacacionesDisponibles: 8,
            diasVacacionesTotales: 15
        ),
        Empleado(
            id: "10891",
            nombre: "Ana",
            apellidos: "Pérez Morales",
            puesto: "Técnico de Calidad",
            departamento: "Control de Calidad",
            planta: "Planta Querétaro",
            diasVacacionesDisponibles: 15,
            diasVacacionesTotales: 15
        ),
        Empleado(
            id: "11045",
            nombre: "Roberto",
            apellidos: "Sosa Jiménez",
            puesto: "Operador Senior",
            departamento: "Línea A",
            planta: "Planta Querétaro",
            diasVacacionesDisponibles: 5,
            diasVacacionesTotales: 15
        ),
        Empleado(
            id: "11203",
            nombre: "Daniela",
            apellidos: "Ríos Castro",
            puesto: "Técnico de Mantenimiento",
            departamento: "Mantenimiento",
            planta: "Planta Querétaro",
            diasVacacionesDisponibles: 12,
            diasVacacionesTotales: 15
        )
    ]

    static let chatsEscalados: [ChatEscalado] = [
        ChatEscalado(
            empleadoNombre: "Miguel Torres",
            empleadoId: "10234",
            ultimoMensaje: "No reconozco el descuento en mi nómina de noviembre",
            fecha: Date().addingTimeInterval(-300),
            urgencia: .alta
        ),
        ChatEscalado(
            empleadoNombre: "Ana Pérez",
            empleadoId: "10891",
            ultimoMensaje: "¿Pueden darme constancia con sueldo esta semana?",
            fecha: Date().addingTimeInterval(-1380),
            urgencia: .normal
        ),
        ChatEscalado(
            empleadoNombre: "Roberto Sosa",
            empleadoId: "11045",
            ultimoMensaje: "Permiso por enfermedad familiar urgente",
            fecha: Date().addingTimeInterval(-3600),
            urgencia: .alta
        ),
        ChatEscalado(
            empleadoNombre: "Daniela Ríos",
            empleadoId: "11203",
            ultimoMensaje: "¿Cuándo se activa mi seguro médico?",
            fecha: Date().addingTimeInterval(-7200),
            urgencia: .normal
        )
    ]

    static let solicitudesRecientes: [Solicitud] = [
        Solicitud(id: "001", tipo: "Constancia de empleo", fecha: Date(), estado: .pendiente),
        Solicitud(id: "002", tipo: "Vacaciones (23-27 dic)", fecha: Date(), estado: .aprobada),
        Solicitud(id: "003", tipo: "Actualización de datos", fecha: Date(), estado: .completada),
        Solicitud(id: "004", tipo: "Permiso personal", fecha: Date().addingTimeInterval(-172800), estado: .rechazada),
        Solicitud(id: "005", tipo: "Aclaración de nómina", fecha: Date().addingTimeInterval(-259200), estado: .completada)
    ]

    static let chatInicial: [ChatMessage] = [
        ChatMessage(
            rol: .asistente,
            texto: "¡Hola Carlos! Soy tu asistente de RH. ¿En qué te puedo ayudar hoy?",
            fecha: Date(),
            sugerencias: quickReplies
        )
    ]

    static let quickReplies = [
        "¿Cuántas vacaciones tengo?",
        "Necesito una constancia",
        "Tengo un problema con mi nómina",
        "Quiero actualizar mis datos"
    ]

    static let bienestarRecursos = [
        "Pausa activa de 5 minutos",
        "Guía para manejar estrés en planta",
        "Línea de apoyo emocional Mabe",
        "Recomendaciones de ergonomía"
    ]

    static let recursosBienestar: [RecursoBienestar] = [
        RecursoBienestar(
            id: "r1",
            titulo: "Pausa activa de 5 minutos",
            icon: "figure.walk.motion",
            color: Color(hex: "#00C27C"),
            duracion: "5 min · Ejercicio",
            tipoIcon: "clock",
            prioridad: .normal
        ),
        RecursoBienestar(
            id: "r2",
            titulo: "Guía para manejar estrés en planta",
            icon: "brain.head.profile",
            color: Color(hex: "#7C5CFC"),
            duracion: "8 min lectura",
            tipoIcon: "book.closed",
            prioridad: .alta
        ),
        RecursoBienestar(
            id: "r3",
            titulo: "Línea de apoyo emocional Mabe",
            icon: "phone.fill",
            color: Color(hex: "#003087"),
            duracion: "24/7 · Confidencial",
            tipoIcon: "phone",
            prioridad: .alta
        ),
        RecursoBienestar(
            id: "r4",
            titulo: "Recomendaciones de ergonomía",
            icon: "person.and.background.dotted",
            color: Color(hex: "#D97706"),
            duracion: "4 min lectura",
            tipoIcon: "book.closed",
            prioridad: .normal
        ),
        RecursoBienestar(
            id: "r5",
            titulo: "Meditación guiada para dormir mejor",
            icon: "moon.stars.fill",
            color: Color(hex: "#5C3BC1"),
            duracion: "10 min · Audio",
            tipoIcon: "play.circle",
            prioridad: .normal
        ),
        RecursoBienestar(
            id: "r6",
            titulo: "Tips de alimentación saludable",
            icon: "leaf.fill",
            color: Color(hex: "#00704A"),
            duracion: "3 min lectura",
            tipoIcon: "book.closed",
            prioridad: .normal
        )
    ]

    static let moodHistorialDemo: [MoodEntry] = {
        let cal = Calendar.current
        let moods: [MoodOption] = [.bien, .regular, .bien, .excelente, .cansado]
        return moods.enumerated().compactMap { index, mood in
            guard let date = cal.date(byAdding: .day, value: -(4 - index), to: Date()) else {
                return nil
            }
            return MoodEntry(id: UUID(), mood: mood, fecha: date, nota: nil)
        }
    }()

    static let rewardProfileDemo: RewardProfile = {
        let calendar = Calendar.current
        let eventos = [
            RewardEvent(
                id: UUID(),
                tipo: .evaluacionCuatrimestral,
                puntos: 300,
                puntosFinales: 300,
                descripcion: "Evaluación Buena (82%) — Q2/2025",
                fecha: calendar.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
                fuente: .desempeno
            ),
            RewardEvent(
                id: UUID(),
                tipo: .rachaSemanal,
                puntos: 50,
                puntosFinales: 63,
                descripcion: "Racha de 7 días",
                fecha: calendar.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                fuente: .app
            ),
            RewardEvent(
                id: UUID(),
                tipo: .checkinBienestar,
                puntos: 10,
                puntosFinales: 13,
                descripcion: "Check-in de bienestar — Bien",
                fecha: Date(),
                fuente: .app
            )
        ]

        return RewardProfile(
            puntosAcumulados: 720,
            puntosDisponibles: 540,
            tier: .plata,
            eventos: eventos,
            logrosDesbloqueados: ["primer_paso", "nivel_plata", "primer_cuatrimestre"],
            rachaActual: 8,
            cuatrimestresConBono: 1,
            fechaUltimoCheckin: Date()
        )
    }()

    static let prestaciones: [Prestacion] = [
        Prestacion(
            id: "aguinaldo",
            nombre: "Aguinaldo",
            descripcion: "Pago adicional a fin de año equivalente a 30 días de salario.",
            detalle: "Se paga en diciembre antes del día 20. El doble de lo que marca la ley federal: 15 días.",
            valor: "30 días",
            vsLey: "Ley: 15 días",
            icon: "banknote.fill",
            color: Color(hex: "#003087"),
            categoria: .economica,
            badge: "2x la ley",
            esDestacada: true
        ),
        Prestacion(
            id: "prima",
            nombre: "Prima vacacional",
            descripcion: "Porcentaje adicional sobre tu salario al salir de vacaciones.",
            detalle: "Al tomar vacaciones recibes el 22% adicional sobre los días que goces. Aplica sobre salario diario.",
            valor: "22%",
            vsLey: "Ley mín: 25%",
            icon: "sun.max.fill",
            color: Color(hex: "#0EA5E9"),
            categoria: .economica,
            badge: nil,
            esDestacada: false
        ),
        Prestacion(
            id: "fondo",
            nombre: "Fondo de ahorro",
            descripcion: "Mabe aporta el 12.5% de tu salario mensual a tu fondo personal de ahorro.",
            detalle: "Tu aportación y la de Mabe crecen juntas. Puedes retirarlo al final del año o al separarte de la empresa. Libre de impuestos dentro del límite legal.",
            valor: "12.5%",
            vsLey: nil,
            icon: "building.columns.fill",
            color: Color(hex: "#00704A"),
            categoria: .economica,
            badge: "Ahorro garantizado",
            esDestacada: true
        ),
        Prestacion(
            id: "vales",
            nombre: "Vales de despensa",
            descripcion: "Tarjeta mensual para compras de supermercado equivalente al 8% de tu salario.",
            detalle: "Cargada mensualmente en tarjeta electrónica. Aceptada en Walmart, Chedraui, La Comer, OXXO y más de 20,000 establecimientos. Libre de ISR.",
            valor: "8% del salario",
            vsLey: nil,
            icon: "cart.fill",
            color: Color(hex: "#D97706"),
            categoria: .economica,
            badge: "Libre de ISR",
            esDestacada: true
        ),
        Prestacion(
            id: "bonos",
            nombre: "Bonos cuatrimestrales",
            descripcion: "Bono de desempeño tres veces al año: abril, agosto y diciembre.",
            detalle: "El monto varía según el cumplimiento de objetivos individuales y de planta. Puede representar hasta un mes adicional de salario por período.",
            valor: "3 veces al año",
            vsLey: nil,
            icon: "star.fill",
            color: Color(hex: "#D97706"),
            categoria: .economica,
            badge: "Por desempeño",
            esDestacada: false
        ),
        Prestacion(
            id: "caja",
            nombre: "Caja de ahorro",
            descripcion: "Acceso a la caja de ahorro interna de Mabe con tasas preferenciales.",
            detalle: "Puedes solicitar préstamos personales con tasas por debajo del mercado. También puedes ahorrar con rendimientos superiores a la banca tradicional. Descuento automático por nómina.",
            valor: "Tasas preferenciales",
            vsLey: nil,
            icon: "creditcard.fill",
            color: Color(hex: "#003087"),
            categoria: .economica,
            badge: nil,
            esDestacada: false
        ),
        Prestacion(
            id: "sgmm",
            nombre: "Seguro de gastos médicos mayores",
            descripcion: "Cobertura de salud amplia para ti y tu familia directa.",
            detalle: "Incluye hospitalización, cirugías, medicamentos, maternidad y enfermedades crónicas. Suma asegurada superior al IMSS. Cubre cónyuge e hijos. Deducible accesible.",
            valor: "Tú + familia",
            vsLey: nil,
            icon: "cross.circle.fill",
            color: Color(hex: "#00C27C"),
            categoria: .saludBienestar,
            badge: "Premium",
            esDestacada: true
        ),
        Prestacion(
            id: "cumple",
            nombre: "Día de cumpleaños",
            descripcion: "El día de tu cumpleaños es un día libre pagado.",
            detalle: "Ausentismo autorizado el día exacto de tu cumpleaños. Si cae en fin de semana o festivo, puedes tomarlo el lunes siguiente. Solo avisa a tu supervisor.",
            valor: "1 día libre",
            vsLey: nil,
            icon: "balloon.fill",
            color: Color(hex: "#EC4899"),
            categoria: .saludBienestar,
            badge: "Festéjate",
            esDestacada: false
        ),
        Prestacion(
            id: "maternidad",
            nombre: "Licencia de maternidad extendida",
            descripcion: "Licencia de maternidad de hasta 9 meses, por encima de los 3 meses de ley.",
            detalle: "La ley federal otorga 84 días. Mabe ofrece hasta 9 meses con goce de sueldo parcial en los meses adicionales. Aplica también para adopción. Paternidad: 5 días hábiles adicionales a los legales.",
            valor: "3 a 9 meses",
            vsLey: "Ley: 3 meses",
            icon: "figure.and.child.holdinghands",
            color: Color(hex: "#7C5CFC"),
            categoria: .saludBienestar,
            badge: "3x la ley",
            esDestacada: true
        ),
        Prestacion(
            id: "posgrado",
            nombre: "Apoyo académico — Posgrado",
            descripcion: "Mabe apoya económicamente a empleados que estudian maestría o doctorado.",
            detalle: "Cubre parcial o totalmente inscripción y colegiaturas en programas reconocidos. Se evalúa caso por caso. Requiere mantenerse activo durante y después del estudio.",
            valor: "Apoyo económico",
            vsLey: nil,
            icon: "graduationcap.fill",
            color: Color(hex: "#7C5CFC"),
            categoria: .desarrollo,
            badge: "Maestría · Doctorado",
            esDestacada: false
        ),
        Prestacion(
            id: "prepa",
            nombre: "Prepa Mabe",
            descripcion: "Operarios sin bachillerato pueden terminar la preparatoria sin costo.",
            detalle: "Programa en convenio con SEP y sistema de bachillerato abierto. Las clases son fuera de turno dentro de instalaciones. Certificación oficial para operadores que no concluyeron bachillerato.",
            valor: "100% gratuito",
            vsLey: nil,
            icon: "book.closed.fill",
            color: Color(hex: "#0EA5E9"),
            categoria: .desarrollo,
            badge: "Certificado SEP",
            esDestacada: false
        ),
        Prestacion(
            id: "convenios",
            nombre: "Convenios y descuentos",
            descripcion: "Acceso a descuentos exclusivos en múltiples categorías por ser empleado Mabe.",
            detalle: "Descuentos en restaurantes, cines, parques, gimnasios, ópticas, farmacias, electrónicos y viajes. Los convenios se actualizan periódicamente.",
            valor: "Múltiples categorías",
            vsLey: nil,
            icon: "tag.fill",
            color: Color(hex: "#D97706"),
            categoria: .convenios,
            badge: "Descuentos exclusivos",
            esDestacada: false
        )
    ]

    static let valorPaquetePrestaciones = "+50% sobre salario base"
    static let numPrestaciones = prestaciones.count

    static let coupons: [Coupon] = [
        Coupon(
            id: "coupon-001",
            title: "20% en productos mabe",
            description: "Descuento exclusivo para colaboradores en línea blanca seleccionada.",
            category: .hogar,
            expirationDate: Date().addingTimeInterval(86400 * 12),
            status: .available,
            valueText: "20% OFF",
            partnerName: "mabe",
            recommendedReason: "Puede ayudarte a renovar tu hogar con menor gasto este mes.",
            iconName: "house.fill"
        ),
        Coupon(
            id: "coupon-002",
            title: "Vale de comida",
            description: "Beneficio para consumir en comedor durante turno operativo.",
            category: .alimentacion,
            expirationDate: Date().addingTimeInterval(86400 * 3),
            status: .expiringSoon,
            valueText: "$150 MXN",
            partnerName: "Comedor",
            recommendedReason: "Está por expirar; úsalo antes del cierre de semana.",
            iconName: "fork.knife"
        ),
        Coupon(
            id: "coupon-003",
            title: "Descuento en cine",
            description: "Promoción familiar para boletos en complejo participante.",
            category: .familia,
            expirationDate: Date().addingTimeInterval(86400 * 20),
            status: .available,
            valueText: "2x1",
            partnerName: "Cine",
            recommendedReason: "Ideal para convivir con tu familia el fin de semana.",
            iconName: "popcorn.fill"
        ),
        Coupon(
            id: "coupon-004",
            title: "Consulta médica preventiva",
            description: "Chequeo preventivo con red de salud aliada.",
            category: .bienestar,
            expirationDate: Date().addingTimeInterval(86400 * 8),
            status: .available,
            valueText: "Gratis",
            partnerName: "Bienestar",
            recommendedReason: "Este beneficio puede ayudarte a cuidar tu salud sin costo.",
            iconName: "cross.case.fill"
        ),
        Coupon(
            id: "coupon-005",
            title: "Apoyo escolar familiar",
            description: "Descuento en material educativo para hijos de colaboradores.",
            category: .educacion,
            expirationDate: Date().addingTimeInterval(86400 * 5),
            status: .expiringSoon,
            valueText: "$300 MXN",
            partnerName: "Educación",
            recommendedReason: "Detectamos temporada escolar; puede reducir gastos familiares.",
            iconName: "graduationcap.fill"
        ),
        Coupon(
            id: "coupon-006",
            title: "Transporte colaborador",
            description: "Viaje subsidiado para ruta de planta.",
            category: .transporte,
            expirationDate: Date().addingTimeInterval(-86400 * 2),
            status: .used,
            valueText: "1 viaje",
            partnerName: "Transporte",
            recommendedReason: nil,
            iconName: "bus.fill",
            usedDate: Date().addingTimeInterval(-86400 * 4)
        ),
        Coupon(
            id: "coupon-007",
            title: "Curso de bienestar financiero",
            description: "Acceso a sesión práctica para organizar gastos personales.",
            category: .educacion,
            expirationDate: Date().addingTimeInterval(-86400 * 5),
            status: .used,
            valueText: "100%",
            partnerName: "Bienestar",
            recommendedReason: nil,
            iconName: "chart.line.uptrend.xyaxis",
            usedDate: Date().addingTimeInterval(-86400 * 10)
        ),
        Coupon(
            id: "coupon-008",
            title: "Snack saludable",
            description: "Canje de snack saludable en comedor.",
            category: .alimentacion,
            expirationDate: Date().addingTimeInterval(-86400),
            status: .expired,
            valueText: "Gratis",
            partnerName: "Comedor",
            recommendedReason: nil,
            iconName: "leaf.fill"
        )
    ]

    static let cupones: [Cupon] = [
        Cupon(
            id: "c1",
            titulo: "20% en Oxxo",
            empresa: "OXXO",
            descripcion: "Obtén 20% de descuento en cualquier compra mayor a $50 en tiendas OXXO participantes.",
            icon: "bag.fill",
            gradient: LinearGradient(colors: [Color(hex: "#D97706"), Color(hex: "#F59E0B")], startPoint: .topLeading, endPoint: .bottomTrailing),
            categoria: .tienda,
            puntosCosto: 50,
            vencimiento: "31 dic",
            fechaVencimiento: nil,
            codigoPromo: "MABE20OXX",
            terminos: ["Válido en tiendas participantes", "No combinable con otras promociones", "Una sola vez por empleado"]
        ),
        Cupon(
            id: "c2",
            titulo: "Ride gratis en Uber",
            empresa: "Uber",
            descripcion: "Un viaje gratuito hasta $120 MXN en Uber. Perfecto para ir al trabajo o a casa.",
            icon: "car.fill",
            gradient: LinearGradient(colors: [Color(hex: "#1C1C1E"), Color(hex: "#3A3A3C")], startPoint: .topLeading, endPoint: .bottomTrailing),
            categoria: .transporte,
            puntosCosto: 80,
            vencimiento: "15 dic",
            fechaVencimiento: nil,
            codigoPromo: "MABERIDE1",
            terminos: ["Máximo $120 MXN", "Solo viajes en México", "Válido 30 días tras canje"]
        ),
        Cupon(
            id: "c3",
            titulo: "Consulta médica sin costo",
            empresa: "DoctoLink",
            descripcion: "Una consulta médica general gratuita por videollamada con médicos certificados.",
            icon: "stethoscope",
            gradient: LinearGradient(colors: [Color(hex: "#00704A"), Color(hex: "#00C27C")], startPoint: .topLeading, endPoint: .bottomTrailing),
            categoria: .salud,
            puntosCosto: 120,
            vencimiento: "28 feb",
            fechaVencimiento: nil,
            codigoPromo: "MABEHLTH1",
            terminos: ["Solo consulta general", "Válido por videollamada", "Agenda tu cita en la app"]
        ),
        Cupon(
            id: "c4",
            titulo: "2x1 en Cinépolis",
            empresa: "Cinépolis",
            descripcion: "Lleva a alguien contigo al cine y paga solo una entrada en cualquier función.",
            icon: "film.fill",
            gradient: LinearGradient(colors: [Color(hex: "#BE185D"), Color(hex: "#EC4899")], startPoint: .topLeading, endPoint: .bottomTrailing),
            categoria: .entretenimiento,
            puntosCosto: 100,
            vencimiento: "31 ene",
            fechaVencimiento: nil,
            codigoPromo: "MABE2X1CN",
            terminos: ["No aplica en estrenos", "Solo fines de semana", "Presentar código en taquilla"]
        ),
        Cupon(
            id: "c5",
            titulo: "$50 en Rappi",
            empresa: "Rappi",
            descripcion: "Descuento de $50 MXN en tu próximo pedido de comida en Rappi.",
            icon: "fork.knife",
            gradient: LinearGradient(colors: [Color(hex: "#FF441F"), Color(hex: "#FF7043")], startPoint: .topLeading, endPoint: .bottomTrailing),
            categoria: .comida,
            puntosCosto: 60,
            vencimiento: "20 dic",
            fechaVencimiento: nil,
            codigoPromo: "MABERAPPI",
            terminos: ["Pedido mínimo $200", "Solo comida, no mercado", "No aplica en Turbo"]
        ),
        Cupon(
            id: "c6",
            titulo: "Mes gratis en gym",
            empresa: "Smart Fit",
            descripcion: "Un mes de membresía gratis en Smart Fit. Aplica para planes nuevos.",
            icon: "figure.run",
            gradient: LinearGradient(colors: [Color(hex: "#5C3BC1"), Color(hex: "#7C5CFC")], startPoint: .topLeading, endPoint: .bottomTrailing),
            categoria: .salud,
            puntosCosto: 200,
            vencimiento: "31 mar",
            fechaVencimiento: nil,
            codigoPromo: "MABEFIT01",
            terminos: ["Solo membresías nuevas", "Aplica plan Black", "Canjear en sucursal"]
        )
    ]

    static let recomendacionesHome: [HomeRecommendation] = [
        HomeRecommendation(icon: "beach.umbrella.fill", title: "Vacaciones disponibles", description: "Tienes 12 días disponibles para planear descanso.", cta: "Ver", destination: .vacaciones),
        HomeRecommendation(icon: "ticket.fill", title: "Cupones por expirar", description: "Tienes 2 beneficios que vencen esta semana.", cta: "Usar", destination: .benefits),
        HomeRecommendation(icon: "doc.badge.clock", title: "Constancia pendiente", description: "Tu constancia de empleo está lista para seguimiento.", cta: "Resolver", destination: .solicitudes),
        HomeRecommendation(icon: "heart.fill", title: "Check-in de bienestar", description: "Registra cómo te sientes hoy para recibir apoyo oportuno.", cta: "Registrar", destination: .bienestar)
    ]

    static let avisosRH: [String] = [
        "Recuerda actualizar tus datos antes del cierre mensual.",
        "Nuevo beneficio disponible para colaboradores.",
        "Menos trámites. Más tiempo para lo importante."
    ]

    static let solicitudesUrgentes: [SolicitudRH] = [
        SolicitudRH(
            id: "1",
            empleadoNombre: "Miguel Torres",
            empleadoId: "10234",
            ultimoMensaje: "No reconozco el descuento de noviembre",
            urgencia: .alta,
            tiempoRelativo: "hace 5 min"
        ),
        SolicitudRH(
            id: "2",
            empleadoNombre: "Ana Pérez",
            empleadoId: "10891",
            ultimoMensaje: "¿Constancia con sueldo esta semana?",
            urgencia: .normal,
            tiempoRelativo: "hace 23 min"
        ),
        SolicitudRH(
            id: "3",
            empleadoNombre: "Roberto Sosa",
            empleadoId: "11045",
            ultimoMensaje: "Solicitud de permiso por enfermedad familiar",
            urgencia: .alta,
            tiempoRelativo: "hace 1 hr"
        )
    ]
}
