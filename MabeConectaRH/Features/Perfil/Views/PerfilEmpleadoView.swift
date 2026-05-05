import SwiftUI

struct PerfilEmpleadoView: View {
    let empleado: Empleado
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            MabeBackButton(title: "Inicio")

            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color(hex: "#003087"), Color(hex: "#1976FF")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 90, height: 90)
                        Text(empleado.iniciales)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .shadow(color: Color(hex:"#1976FF").opacity(0.3), radius: 16, x: 0, y: 6)
                    .padding(.top, 8)

                    VStack(spacing: 4) {
                        Text(empleado.nombreCompleto)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "#0D1B3E"))
                        Text(empleado.puesto)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(hex: "#4B5675"))
                    }

                    VStack(spacing: 1) {
                        perfilRow(icon: "number", label: "No. Empleado", value: empleado.id)
                        perfilRow(icon: "building.2.fill", label: "Departamento", value: empleado.departamento)
                        perfilRow(icon: "mappin.circle.fill", label: "Planta", value: empleado.planta)
                        perfilRow(icon: "calendar", label: "Antigüedad", value: "4 años, 3 meses")
                        perfilRow(icon: "clock.fill", label: "Turno", value: "Matutino 6:00-14:00")
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color(hex:"#0D1B3E").opacity(0.06), radius: 12, x: 0, y: 4)
                    .padding(.horizontal, 20)

                    HStack(spacing: 0) {
                        statBadge(valor: "\(empleado.diasVacacionesDisponibles)", label: "Disponibles", color: Color(hex: "#1976FF"))
                        Divider().frame(height: 40)
                        statBadge(valor: "\(empleado.diasVacacionesTotales - empleado.diasVacacionesDisponibles)", label: "Usados", color: Color(hex: "#4B5675"))
                        Divider().frame(height: 40)
                        statBadge(valor: "\(empleado.diasVacacionesTotales)", label: "Total anual", color: Color(hex: "#4B5675"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color(hex:"#0D1B3E").opacity(0.06), radius: 12, x: 0, y: 4)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 32)
            }
        }
        .background(Color(hex: "#F8F9FC"))
        .navigationBarHidden(true)
    }

    func perfilRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "#1976FF"))
                .frame(width: 24)
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "#4B5675"))
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(hex: "#0D1B3E"))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color.white)
        .overlay(alignment: .bottom) {
            Divider().padding(.leading, 56)
        }
    }

    func statBadge(valor: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(valor)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "#9AA5BE"))
        }
        .frame(maxWidth: .infinity)
    }
}
