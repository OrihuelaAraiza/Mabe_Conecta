import Foundation
import Observation

@Observable
final class BienestarViewModel {
    var estadoSeleccionado: EstadoBienestar?
    let recursos = MockDataService.bienestarRecursos

    func seleccionar(_ estado: EstadoBienestar) {
        Haptics.impact(.light)
        estadoSeleccionado = estado
    }
}
