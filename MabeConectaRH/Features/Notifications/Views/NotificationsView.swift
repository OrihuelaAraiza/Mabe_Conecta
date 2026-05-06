import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notifications: [NotificationData] = []
    @State private var isLoading = true

    private let api = BackendAPI()

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "#003087"))
                        .frame(width: 34, height: 34)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Text("Notificaciones")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(hex: "#0D1B3E"))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            .background(Color(hex: "#F8F9FC"))

            Divider().opacity(0.3)

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if notifications.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.mabeGray400)
                    Text("No tienes notificaciones")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.mabeGray600)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(notifications, id: \.id) { notification in
                            NotificationCard(notification: notification)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(Color.mabeBackground)
        .navigationBarHidden(true)
        .task {
            await loadNotifications()
        }
    }

    @MainActor
    private func loadNotifications() async {
        guard let session = SessionService.load(), let authToken = session.authToken else {
            isLoading = false
            return
        }

        do {
            notifications = try await api.listNotifications(authToken: authToken)
        } catch {
            notifications = []
        }

        isLoading = false
    }
}

private struct NotificationCard: View {
    let notification: NotificationData

    var body: some View {
        MabeCard {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(notification.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.mabeGray900)
                    Spacer()
                    Text(kindLabel)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(kindColor)
                }

                Text(notification.body)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.mabeGray600)

                Text(
                    notification.inserted_at?.formatted(date: .abbreviated, time: .shortened) ?? ""
                )
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.mabeGray400)
            }
        }
    }

    private var kindLabel: String {
        switch notification.kind {
        case "success": return "Éxito"
        case "warning": return "Alerta"
        case "action_required": return "Acción"
        default: return "Info"
        }
    }

    private var kindColor: Color {
        switch notification.kind {
        case "success": return Color.mabeSuccess
        case "warning": return Color.mabeWarning
        case "action_required": return Color.mabeDanger
        default: return Color.mabeBlue
        }
    }
}
