import Foundation

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

    static let chatsEscalados: [ChatEscalado] = [
        ChatEscalado(
            empleadoNombre: "Miguel Torres",
            empleadoId: "10234",
            ultimoMensaje: "No reconozco el descuento en mi nómina de noviembre",
            fecha: Date(),
            urgencia: .alta
        ),
        ChatEscalado(
            empleadoNombre: "Ana Pérez",
            empleadoId: "10891",
            ultimoMensaje: "¿Pueden darme constancia con sueldo esta semana?",
            fecha: Date(),
            urgencia: .normal
        )
    ]

    static let solicitudesRecientes: [Solicitud] = [
        Solicitud(id: "001", tipo: "Constancia de empleo", fecha: Date(), estado: .pendiente),
        Solicitud(id: "002", tipo: "Vacaciones (23-27 dic)", fecha: Date(), estado: .aprobada),
        Solicitud(id: "003", tipo: "Actualización de datos", fecha: Date(), estado: .completada),
        Solicitud(id: "004", tipo: "Permiso personal", fecha: Date().addingTimeInterval(-172800), estado: .rechazada)
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
}
