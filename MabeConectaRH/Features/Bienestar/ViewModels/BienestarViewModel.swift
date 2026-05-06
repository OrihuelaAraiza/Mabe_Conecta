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
    var isSyncing = false

    private let storageKey = "mabe.bienestar.historial"
    private let api = BackendAPI()

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

        Task {
            await syncMoodToBackend(mood: mood, note: nil, factors: [])
        }
    }

    func saveCheckInResult(_ resultado: CheckInResultado) {
        let entry = MoodEntry(id: UUID(), mood: resultado.mood, fecha: Date(), nota: resultado.nota)
        historialCompleto.removeAll { Calendar.current.isDateInToday($0.fecha) }
        historialCompleto.append(entry)
        persistAndRefresh(selectedMood: resultado.mood)
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        Task {
            await syncMoodToBackend(
                mood: resultado.mood,
                note: resultado.nota,
                factors: resultado.factores.map(\.rawValue),
                energy: resultado.energia,
                stress: max(1, 6 - resultado.energia)
            )
        }
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
            let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data)
        else {
            historialCompleto = MockDataService.moodHistorialDemo
            buildSemana()
            Task {
                await loadFromBackendIfPossible()
            }
            return
        }

        historialCompleto = decoded
        buildSemana()

        Task {
            await loadFromBackendIfPossible()
        }
    }

    private func loadFromBackendIfPossible() async {
        guard let session = SessionService.load(), let authToken = session.authToken else { return }
        isSyncing = true
        defer { isSyncing = false }

        do {
            let remote = try await api.listWellbeingEntries(authToken: authToken)
            let mapped: [MoodEntry] = remote.compactMap { entry in
                guard let mood = moodFromBackend(entry.mood) else { return nil }
                return MoodEntry(
                    id: UUID(),
                    mood: mood,
                    fecha: entry.inserted_at ?? Date(),
                    nota: entry.note
                )
            }

            guard !mapped.isEmpty else { return }
            historialCompleto = mapped.sorted { $0.fecha < $1.fecha }
            saveHistorial()
            buildSemana()
            checkTodayMood()
            calcularRacha()
        } catch {
            // keep local fallback
        }
    }

    private func syncMoodToBackend(
        mood: MoodOption, note: String?, factors: [String], energy: Int? = nil, stress: Int? = nil
    ) async {
        guard let session = SessionService.load(), let authToken = session.authToken else { return }

        do {
            _ = try await api.createWellbeingEntry(
                mood: moodBackendValue(mood),
                energyLevel: energy,
                stressLevel: stress,
                note: note,
                factors: factors,
                authToken: authToken
            )
        } catch {
            // keep UX smooth during demo
        }
    }

    private func moodBackendValue(_ mood: MoodOption) -> String {
        switch mood {
        case .dificil: return "dificil"
        case .cansado: return "cansado"
        case .regular: return "regular"
        case .bien: return "bien"
        case .excelente: return "excelente"
        }
    }

    private func moodFromBackend(_ value: String) -> MoodOption? {
        switch value.lowercased() {
        case "dificil": return .dificil
        case "cansado": return .cansado
        case "regular": return .regular
        case "bien": return .bien
        case "excelente": return .excelente
        default: return nil
        }
    }
}
