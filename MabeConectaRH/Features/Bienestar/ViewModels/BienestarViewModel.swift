import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class BienestarViewModel {
    var todayMood: MoodOption?
    var rachaActual: Int = 0
    var showingSupportBanner = false
    var showingHistory = false
    var historialSemana: [MoodEntry?] = []
    var historialCompleto: [MoodEntry] = []

    private let storageKey = "mabe.bienestar.historial"

    init() {
        loadHistorial()
        checkTodayMood()
        calcularRacha()
    }

    var alreadyCheckedInToday: Bool {
        historialCompleto.contains { Calendar.current.isDateInToday($0.fecha) }
    }

    func registerMood(_ mood: MoodOption) {
        guard !alreadyCheckedInToday else { return }

        let entry = MoodEntry(id: UUID(), mood: mood, fecha: Date(), nota: nil)
        historialCompleto.append(entry)
        persistAndRefresh(selectedMood: mood)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func saveCheckInResult(_ resultado: CheckInResultado) {
        let entry = MoodEntry(id: UUID(), mood: resultado.mood, fecha: Date(), nota: resultado.nota)
        historialCompleto.removeAll { Calendar.current.isDateInToday($0.fecha) }
        historialCompleto.append(entry)
        persistAndRefresh(selectedMood: resultado.mood)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func persistAndRefresh(selectedMood: MoodOption) {
        saveHistorial()
        calcularRacha()
        buildSemana()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            todayMood = selectedMood
            showingSupportBanner = selectedMood == .dificil || selectedMood == .cansado
        }
    }

    private func checkTodayMood() {
        todayMood = historialCompleto.first { Calendar.current.isDateInToday($0.fecha) }?.mood
        showingSupportBanner = todayMood == .dificil || todayMood == .cansado
    }

    private func calcularRacha() {
        var racha = 0
        var fecha = Calendar.current.startOfDay(for: Date())
        let cal = Calendar.current

        while true {
            let tieneRegistro = historialCompleto.contains {
                cal.isDate($0.fecha, inSameDayAs: fecha)
            }
            if tieneRegistro {
                racha += 1
                fecha = cal.date(byAdding: .day, value: -1, to: fecha) ?? fecha
            } else {
                break
            }
        }

        rachaActual = racha
    }

    private func buildSemana() {
        let cal = Calendar.current
        historialSemana = (0..<7).map { daysAgo -> MoodEntry? in
            guard let date = cal.date(byAdding: .day, value: -daysAgo, to: Date()) else {
                return nil
            }
            return historialCompleto.first { cal.isDate($0.fecha, inSameDayAs: date) }
        }
        .reversed()
    }

    private func saveHistorial() {
        if let data = try? JSONEncoder().encode(historialCompleto) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadHistorial() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data) else {
            historialCompleto = MockDataService.moodHistorialDemo
            buildSemana()
            return
        }

        historialCompleto = decoded
        buildSemana()
    }
}
