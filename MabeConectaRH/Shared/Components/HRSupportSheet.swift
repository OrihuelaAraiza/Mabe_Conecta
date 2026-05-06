import SwiftUI

struct HRSupportSheet: View {
    @Environment(\.dismiss) private var dismiss
    let context: String

    @State private var issueTitle = ""
    @State private var detail = ""
    @State private var urgency = "normal"
    @State private var createDocument = false
    @State private var isSubmitting = false
    @State private var successMessage: String?

    private let api = BackendAPI()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "person.2.badge.gearshape.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(Color.mabeBlue)
                    .frame(width: 72, height: 72)
                    .background(Color.mabeBlue.opacity(0.1))
                    .clipShape(Circle())

                VStack(spacing: 8) {
                    Text("Hablar con RH")
                        .font(.mabeHeadline)
                        .foregroundStyle(Color.mabeGray900)
                    Text("Tu caso será canalizado con un especialista de RH.")
                        .font(.mabeSub)
                        .foregroundStyle(Color.mabeGray600)
                        .multilineTextAlignment(.center)
                    Text(context)
                        .font(.mabeCaption)
                        .foregroundStyle(Color.mabeGray400)
                        .multilineTextAlignment(.center)
                }

                Toggle(isOn: $createDocument) {
                    Text("Solicitar documento en lugar de escalar")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.mabeGray900)
                }
                .tint(Color.mabeBlue)

                VStack(alignment: .leading, spacing: 8) {
                    Text(createDocument ? "Tipo de solicitud" : "Título")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.mabeGray600)

                    TextField(
                        createDocument ? "employment_certificate" : "Ej. Aclaración de nómina",
                        text: $issueTitle
                    )
                    .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Detalle")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.mabeGray600)

                    TextEditor(text: $detail)
                        .frame(height: 90)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.mabeGray200, lineWidth: 1)
                        )
                }

                if !createDocument {
                    Picker("Urgencia", selection: $urgency) {
                        Text("Baja").tag("low")
                        Text("Normal").tag("normal")
                        Text("Alta").tag("high")
                    }
                    .pickerStyle(.segmented)
                }

                if let successMessage {
                    Text(successMessage)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.mabeSuccess)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 10) {
                    Button {
                        Task { await submitCase() }
                    } label: {
                        Group {
                            if isSubmitting {
                                ProgressView().tint(.white)
                            } else {
                                Text(createDocument ? "Solicitar documento" : "Crear caso")
                            }
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.mabeBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .disabled(
                        issueTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            || detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            || isSubmitting)

                    Button("Cancelar") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.mabeGray600)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                }
            }
            .padding(24)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .background(Color.mabeBackground)
    }

    @MainActor
    private func submitCase() async {
        guard let session = SessionService.load(), let authToken = session.authToken else {
            successMessage = "Caso registrado en modo local."
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            if createDocument {
                _ = try await api.createDocumentRequest(
                    documentType: issueTitle,
                    includeSalary: false,
                    notes: detail,
                    authToken: authToken
                )
                successMessage = "Solicitud de documento enviada correctamente."
            } else {
                _ = try await api.createEscalationTicket(
                    title: issueTitle,
                    detail: detail,
                    urgency: urgency,
                    authToken: authToken
                )
                successMessage = "Caso escalado con RH correctamente."
            }
        } catch {
            successMessage = "No fue posible enviar tu caso. Intenta nuevamente."
        }
    }
}
