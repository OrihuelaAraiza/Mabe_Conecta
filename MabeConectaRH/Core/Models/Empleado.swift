import Foundation

struct Empleado: Identifiable, Hashable {
    let id: String
    let nombre: String
    let apellidos: String
    let puesto: String
    let departamento: String
    let planta: String
    let diasVacacionesDisponibles: Int
    let diasVacacionesTotales: Int

    var nombreCompleto: String {
        "\(nombre) \(apellidos)"
    }

    var iniciales: String {
        let primera = nombre.first.map(String.init) ?? ""
        let segunda = apellidos.first.map(String.init) ?? ""
        return "\(primera)\(segunda)"
    }
}
