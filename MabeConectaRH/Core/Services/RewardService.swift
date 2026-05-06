import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class RewardService {
    var profile: RewardProfile = RewardProfile()
    var eventoReciente: RewardEvent?

    private let key = "mabe.rewardProfile"
    private let chatUsagePrefix = "mabe.chatUsedToday."

    private let puntosBase: [RewardEvent.TipoEvento: Int] = [
        .checkinBienestar: 10,
        .rachaSemanal: 50,
        .solicitudCompletada: 25,
        .cuponCanjeado: 15,
        .consultaAsistente: 5,
        .onboardingCompletado: 50,
        .perfilCompletado: 20,
        .primeraVez: 30,
        .evaluacionCuatrimestral: 0,
        .asistenciaPerfecta: 200,
        .capacitacionCompletada: 75,
        .reconocimientoPares: 30
    ]

    init() {
        load()
    }

    func ganarPuntos(
        tipo: RewardEvent.TipoEvento,
        fuente: RewardEvent.FuentePuntos = .app,
        puntosOverride: Int? = nil,
        descripcion: String
    ) {
        let base = puntosOverride ?? puntosBase[tipo] ?? 0
        guard base > 0 else { return }

        let multiplicador = fuente == .app ? profile.tier.multiplicador : 1.0
        let puntosFinales = Int((Double(base) * multiplicador).rounded())
        let evento = RewardEvent(
            id: UUID(),
            tipo: tipo,
            puntos: base,
            puntosFinales: puntosFinales,
            descripcion: descripcion,
            fecha: Date(),
            fuente: fuente
        )

        profile.eventos.insert(evento, at: 0)
        profile.puntosAcumulados += puntosFinales
        profile.puntosDisponibles += puntosFinales
        profile.recalcularTier()
        checkLogros()
        save()
        showRewardToast(evento)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func canjearPuntos(_ cantidad: Int) {
        guard cantidad > 0 else { return }
        profile.puntosDisponibles = max(0, profile.puntosDisponibles - cantidad)
        save()
    }

    func registrarCheckinBienestar(moodLabel: String) {
        if let ultimo = profile.fechaUltimoCheckin, Calendar.current.isDateInToday(ultimo) {
            return
        }

        actualizarRachaCheckin()
        ganarPuntos(
            tipo: .checkinBienestar,
            descripcion: "Check-in de bienestar — \(moodLabel)"
        )

        if profile.rachaActual > 0, profile.rachaActual % 7 == 0 {
            ganarPuntos(
                tipo: .rachaSemanal,
                descripcion: "Racha de \(profile.rachaActual) días"
            )
        }
    }

    func registrarConsultaAsistenteSiNecesario() {
        let key = chatUsagePrefix + dayKey(Date())
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)
        ganarPuntos(tipo: .consultaAsistente, descripcion: "Consulta al asistente RH")
    }

    func cargarEvaluacionCuatrimestral(porcentaje: Int) {
        let puntos: Int
        let descripcion: String

        if porcentaje >= 90 {
            puntos = 500
            descripcion = "Evaluación Excelente (\(porcentaje)%) — \(cuatrimestreActual())"
        } else if porcentaje >= 75 {
            puntos = 300
            descripcion = "Evaluación Buena (\(porcentaje)%) — \(cuatrimestreActual())"
        } else {
            puntos = 100
            descripcion = "Evaluación Satisfactoria (\(porcentaje)%) — \(cuatrimestreActual())"
        }

        ganarPuntos(
            tipo: .evaluacionCuatrimestral,
            fuente: .desempeno,
            puntosOverride: puntos,
            descripcion: descripcion
        )
        profile.cuatrimestresConBono += 1
        checkLogros()
        save()
    }

    func resetToDemoProfile() {
        profile = MockDataService.rewardProfileDemo
        checkLogros()
        save()
    }

    private func actualizarRachaCheckin() {
        let hoy = Date()
        defer {
            profile.fechaUltimoCheckin = hoy
            save()
        }

        guard let ultimo = profile.fechaUltimoCheckin else {
            profile.rachaActual = max(profile.rachaActual, 1)
            return
        }

        let ayer = Calendar.current.date(byAdding: .day, value: -1, to: hoy) ?? hoy
        if Calendar.current.isDate(ultimo, inSameDayAs: ayer) {
            profile.rachaActual += 1
        } else if !Calendar.current.isDateInToday(ultimo) {
            profile.rachaActual = 1
        }
    }

    private func checkLogros() {
        for logro in LogrosCatalogo.todos {
            if !profile.logrosDesbloqueados.contains(logro.id), logro.condicion(profile) {
                profile.logrosDesbloqueados.insert(logro.id)
            }
        }
    }

    private func showRewardToast(_ evento: RewardEvent) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
            eventoReciente = evento
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(3))
            if eventoReciente?.id == evento.id {
                withAnimation(.easeInOut(duration: 0.2)) {
                    eventoReciente = nil
                }
            }
        }
    }

    private func cuatrimestreActual() -> String {
        let month = Calendar.current.component(.month, from: Date())
        let year = Calendar.current.component(.year, from: Date())
        switch month {
        case 1...4:
            return "Q1/\(year)"
        case 5...8:
            return "Q2/\(year)"
        default:
            return "Q3/\(year)"
        }
    }

    private func dayKey(_ date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }

    private func save() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let saved = try? JSONDecoder().decode(RewardProfile.self, from: data)
        else {
            profile = MockDataService.rewardProfileDemo
            checkLogros()
            save()
            return
        }
        profile = saved
        profile.recalcularTier()
        checkLogros()
    }
}
