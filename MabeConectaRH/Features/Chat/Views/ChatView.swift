import SwiftUI

struct ChatView: View {
    @Environment(AppState.self) private var appState
    @Environment(RewardService.self) private var rewardService
    @State private var viewModel = ChatViewModel()
    @State private var showSupport = false
    @State private var showVacaciones = false
    @State private var showSolicitudes = false
    @State private var showBienestar = false
    @State private var showBenefits = false
    @State private var showNotifications = false
    @State private var isKeyboardVisible = false

    var body: some View {
        @Bindable var viewModel = viewModel

        Group {
            if appState.userRole == .agenteRH {
                EscalatedChatsView()
            } else {
                VStack(spacing: 0) {
                    chatHeader

                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 14) {
                                ForEach(viewModel.mensajes) { mensaje in
                                    ChatBubble(
                                        message: mensaje,
                                        linkedPrestacion: viewModel.linkedPrestaciones[mensaje.id],
                                        onSuggestion: { suggestion in
                                            rewardService.registrarConsultaAsistenteSiNecesario()
                                            Task { await viewModel.enviar(suggestion) }
                                        },
                                        onQuickAction: handleQuickAction
                                    )
                                    .id(mensaje.id)
                                }

                                if viewModel.isTyping {
                                    TypingIndicator()
                                        .id("typing")
                                }
                            }
                            .padding(.horizontal, MabeTheme.horizontalPadding)
                            .padding(.vertical, 16)
                        }
                        .contentShape(Rectangle())
                        .background(Color.mabeBackground)
                        .scrollDismissesKeyboard(.interactively)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 12)
                                .onChanged { _ in
                                    dismissKeyboard()
                                }
                        )
                        .onTapGesture {
                            dismissKeyboard()
                        }
                        .onChange(of: viewModel.mensajes.count) {
                            scrollToBottom(proxy)
                        }
                        .onChange(of: viewModel.isTyping) {
                            scrollToBottom(proxy)
                        }
                        .onAppear {
                            DispatchQueue.main.async {
                                scrollToBottom(proxy)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                scrollToBottom(proxy)
                            }
                        }
                    }

                    HStack(spacing: 10) {
                        MabeTextField(
                            placeholder: "Escribe tu consulta...", text: $viewModel.textoActual
                        )
                        .frame(maxHeight: 52)

                        Button {
                            rewardService.registrarConsultaAsistenteSiNecesario()
                            Task { await viewModel.enviar() }
                        } label: {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Color.white)
                                .frame(width: 42, height: 42)
                                .background(Color.mabeBlue)
                                .clipShape(Circle())
                                .scaleEffect(
                                    viewModel.textoActual.trimmingCharacters(
                                        in: .whitespacesAndNewlines
                                    ).isEmpty ? 0.72 : 1
                                )
                                .animation(
                                    .spring(response: 0.25, dampingFraction: 0.7),
                                    value: viewModel.textoActual.isEmpty)
                        }
                        .disabled(
                            viewModel.textoActual.trimmingCharacters(in: .whitespacesAndNewlines)
                                .isEmpty || viewModel.isTyping
                        )
                        .opacity(viewModel.textoActual.isEmpty ? 0.55 : 1)
                        .accessibilityLabel("Enviar mensaje")
                    }
                    .padding(.horizontal, MabeTheme.horizontalPadding)
                    .padding(.vertical, 12)
                    .padding(.bottom, isKeyboardVisible ? 8 : 88)
                    .background {
                        Color.mabeBackground
                            .ignoresSafeArea(edges: .bottom)
                    }
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(Color.mabeGray200)
                            .frame(height: 1)
                    }
                }
            }
        }
        .mabeNavigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Listo") {
                    dismissKeyboard()
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.mabeBlue)
            }
        }
        .onAppear {
            consumePendingPromptIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation(.easeOut(duration: 0.22)) {
                isKeyboardVisible = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeOut(duration: 0.22)) {
                isKeyboardVisible = false
            }
        }
        .onChange(of: appState.pendingChatPrompt) {
            consumePendingPromptIfNeeded()
        }
        .sheet(isPresented: $showSupport) {
            HRSupportSheet(context: "Solicitud desde asistente RH")
        }
        .sheet(isPresented: $showVacaciones) {
            if let empleado = appState.currentUser {
                NavigationStack { VacacionesView(empleado: empleado) }
            }
        }
        .sheet(isPresented: $showSolicitudes) {
            NavigationStack { SolicitudesView() }
        }
        .sheet(isPresented: $showBienestar) {
            NavigationStack { BienestarView() }
        }
        .sheet(isPresented: $showBenefits) {
            NavigationStack { BenefitsView() }
        }
        .sheet(isPresented: $showNotifications) {
            NavigationStack { ChatNotificationsView() }
        }
    }

    private var chatHeader: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Asistente RH")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.mabeGray900)
                HStack(spacing: 6) {
                    ChatPulsingDot()
                    Text("Siempre disponible")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.mabeGray500)
                }
            }
            Spacer()
            Button {
                showSupport = true
            } label: {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.mabeBlue)
                    .frame(width: 36, height: 36)
                    .background(Color.mabeBlue.opacity(0.1))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Hablar con RH")
        }
        .padding(.horizontal, MabeTheme.horizontalPadding)
        .padding(.vertical, 12)
        .background(Color.mabeSurface)
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation(.easeInOut(duration: 0.25)) {
            if viewModel.isTyping {
                proxy.scrollTo("typing", anchor: .bottom)
            } else if let last = viewModel.mensajes.last {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }

    private func consumePendingPromptIfNeeded() {
        guard let prompt = appState.consumePendingChatPrompt(), !prompt.isEmpty else { return }
        viewModel.textoActual = prompt
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    private func handleQuickAction(_ action: ChatQuickAction) {
        switch action {
        case .vacaciones:
            showVacaciones = true
        case .solicitudes:
            showSolicitudes = true
        case .bienestar:
            showBienestar = true
        case .beneficios:
            showBenefits = true
        case .contactarRH:
            showSupport = true
        case .notificaciones:
            showNotifications = true
        }
    }
}

private struct EscalatedChatsView: View {
    private let chats = MockDataService.chatsEscalados

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Chats escalados")
                        .font(.mabeHeadline)
                        .foregroundStyle(Color.mabeGray900)
                    Text("Conversaciones que requieren seguimiento de RH")
                        .font(.mabeSub)
                        .foregroundStyle(Color.mabeGray400)
                }
                .padding(.bottom, 4)

                ForEach(chats) { chat in
                    MabeCard {
                        HStack(alignment: .top, spacing: 12) {
                            Text(initials(for: chat.empleadoNombre))
                                .font(.callout.weight(.bold))
                                .foregroundStyle(Color.mabeBlue)
                                .frame(width: 42, height: 42)
                                .background(Color.mabeBlue.opacity(0.1))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(chat.empleadoNombre)
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(Color.mabeGray900)
                                    Spacer()
                                    MabeStatusBadge(
                                        status: chat.urgencia.rawValue,
                                        color: chat.urgencia == .alta ? .mabeDanger : .mabeInfo
                                    )
                                }

                                Text("ID \(chat.empleadoId)")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(Color.mabeGray500)

                                Text(chat.ultimoMensaje)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.mabeGray900)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
            .padding(MabeTheme.horizontalPadding)
        }
        .background(Color.mabeBackground)
    }

    private func initials(for name: String) -> String {
        name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined()
    }
}

private enum ChatQuickAction: String {
    case vacaciones
    case solicitudes
    case bienestar
    case beneficios
    case contactarRH
    case notificaciones
}

private struct ChatBubble: View {
    let message: ChatMessage
    let linkedPrestacion: Prestacion?
    let onSuggestion: (String) -> Void
    let onQuickAction: (ChatQuickAction) -> Void

    var body: some View {
        VStack(alignment: message.rol == .usuario ? .trailing : .leading, spacing: 8) {
            if message.rol == .asistente {
                Text("M")
                    .font(.mabeLabel)
                    .foregroundStyle(Color.white)
                    .frame(width: 28, height: 28)
                    .background(Color.mabeBlue)
                    .clipShape(Circle())
                    .mabeCardShadow()
            }

            Text(AttributedString(markdownSafe: message.texto))
                .font(.mabeBody)
                .foregroundStyle(message.rol == .usuario ? Color.white : Color.mabeGray900)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background {
                    if message.rol == .usuario {
                        Color.mabeBlue
                    } else {
                        Color.mabeSurface
                    }
                }
                .clipShape(ChatBubbleShape(isUser: message.rol == .usuario))
                .shadow(
                    color: message.rol == .usuario
                        ? Color.mabeElectric.opacity(0.2) : Color.mabeGray900.opacity(0.06),
                    radius: 8,
                    x: 0,
                    y: message.rol == .usuario ? 4 : 2
                )
                .frame(maxWidth: 290, alignment: message.rol == .usuario ? .trailing : .leading)

            if let linkedPrestacion, message.rol == .asistente {
                PrestacionMiniCard(prestacion: linkedPrestacion)
                    .frame(maxWidth: 290, alignment: .leading)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if message.rol == .asistente {
                if !message.sugerencias.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(message.sugerencias, id: \.self) { suggestion in
                                MabeChip(title: suggestion, isSelected: false) {
                                    Haptics.impact(.light)
                                    onSuggestion(suggestion)
                                }
                                .accessibilityLabel(suggestion)
                            }
                        }
                    }
                }

                if let actionCards = actionCards(for: message), !actionCards.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(actionCards, id: \.title) { card in
                            ChatActionCard(card: card) {
                                onQuickAction(card.action)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: message.rol == .usuario ? .trailing : .leading)
    }

    private func actionCards(for message: ChatMessage) -> [ChatActionCardModel]? {
        let text = message.texto.lowercased()

        // Return a single highest-priority action to avoid repetitive card overload
        if text.contains("escalar") || text.contains("urgente") {
            return [
                ChatActionCardModel(
                    title: "Contactar RH",
                    subtitle: "Abrir soporte directo para seguimiento prioritario.",
                    icon: "person.2.fill",
                    color: Color(hex: "#EC4899"),
                    action: .contactarRH
                )
            ]
        }

        if text.contains("vacacion") {
            return [
                ChatActionCardModel(
                    title: "Gestionar vacaciones",
                    subtitle: "Consulta tu saldo o crea una solicitud en segundos.",
                    icon: "beach.umbrella.fill",
                    color: Color(hex: "#1976FF"),
                    action: .vacaciones
                )
            ]
        }

        if text.contains("solicitud") {
            return [
                ChatActionCardModel(
                    title: "Ver solicitudes RH",
                    subtitle: "Revisa estatus y crea nuevas solicitudes.",
                    icon: "doc.text.fill",
                    color: Color(hex: "#003087"),
                    action: .solicitudes
                )
            ]
        }

        if text.contains("bienestar") || text.contains("cansad") || text.contains("estr") {
            return [
                ChatActionCardModel(
                    title: "Registrar bienestar",
                    subtitle: "Haz tu check-in emocional y recibe recomendaciones.",
                    icon: "heart.fill",
                    color: Color(hex: "#00C27C"),
                    action: .bienestar
                )
            ]
        }

        if text.contains("cupon") || text.contains("beneficio") || text.contains("puntos") {
            return [
                ChatActionCardModel(
                    title: "Explorar beneficios",
                    subtitle: "Descubre cupones que puedes canjear hoy.",
                    icon: "ticket.fill",
                    color: Color(hex: "#D97706"),
                    action: .beneficios
                )
            ]
        }

        return nil
    }
}

private struct ChatActionCardModel {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: ChatQuickAction
}

private struct ChatActionCard: View {
    let card: ChatActionCardModel
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: card.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(card.color)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(card.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.mabeGray900)
                    Text(card.subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.mabeGray500)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.mabeGray400)
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(card.color.opacity(0.14), lineWidth: 1)
            )
            .shadow(color: Color.mabeGray900.opacity(0.05), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

private struct TypingIndicator: View {
    @State private var animating = false

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.mabeGray400)
                        .frame(width: 7, height: 7)
                        .scaleEffect(animating ? 1.0 : 0.5)
                        .opacity(animating ? 1.0 : 0.4)
                        .animation(
                            .easeInOut(duration: 0.5)
                                .repeatForever()
                                .delay(Double(index) * 0.15),
                            value: animating
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.mabeSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            Spacer()
        }
        .accessibilityLabel("El asistente está escribiendo")
        .onAppear { animating = true }
    }
}

private struct ChatBubbleShape: Shape {
    let isUser: Bool

    func path(in rect: CGRect) -> Path {
        let small: CGFloat = 4
        let large: CGFloat = 18
        let topLeft = large
        let topRight = large
        let bottomLeft = isUser ? large : small
        let bottomRight = isUser ? small : large

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + topLeft, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + topRight),
            control: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - bottomLeft),
            control: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topLeft, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY))
        return path
    }
}

private struct PulseDelay: ViewModifier {
    let delay: Double
    @State private var isOn = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isOn ? 1.25 : 0.8)
            .opacity(isOn ? 1 : 0.35)
            .animation(.easeInOut(duration: 0.55).repeatForever().delay(delay), value: isOn)
            .onAppear { isOn = true }
    }
}

private struct ChatPulsingDot: View {
    @State private var scale = 0.8

    var body: some View {
        Circle()
            .fill(Color.mabeSuccess)
            .frame(width: 8, height: 8)
            .scaleEffect(scale)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: scale)
            .onAppear { scale = 1.25 }
            .accessibilityHidden(true)
    }
}

extension AttributedString {
    fileprivate init(markdownSafe text: String) {
        let normalized = text.normalizedChatRendering

        if let attributed = try? AttributedString(markdown: normalized) {
            self = attributed
        } else {
            self = AttributedString(normalized)
        }
    }
}

private struct ChatNotificationsView: View {
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
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
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
                            MabeCard {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(notification.title)
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundStyle(Color.mabeGray900)
                                        Spacer()
                                        Text(notification.kind)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(Color.mabeBlue)
                                    }

                                    Text(notification.body)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(Color.mabeGray600)
                                }
                            }
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

extension String {
    fileprivate var normalizedChatRendering: String {
        var value = self

        // Keep backend/newline formatting visible in markdown rendering
        value = value.replacingOccurrences(of: "\n", with: "  \n")

        // Add missing spaces after punctuation and colons
        value = value.replacingOccurrences(
            of: "([\\.!?;:])(?=\\S)", with: "$1 ", options: .regularExpression)

        // Add a break before important benefit headers when backend text comes compacted
        let sectionHeaders = [
            "Puntos", "Días", "Opciones", "Solicitudes", "Recompensas", "Bienestar",
        ]
        for header in sectionHeaders {
            value = value.replacingOccurrences(
                of: "(?<!\\n)\\b\\Q\(header)\\E:",
                with: "\n\n\(header):",
                options: .regularExpression
            )
        }

        // Split compacted words like "VacacionesConstanciasNómina"
        value = value.replacingOccurrences(
            of: "([a-záéíóúñ])([A-ZÁÉÍÓÚÑ])",
            with: "$1 $2",
            options: .regularExpression
        )

        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
