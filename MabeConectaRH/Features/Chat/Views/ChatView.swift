import SwiftUI

struct ChatView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = ChatViewModel()
    @State private var showSupport = false

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
                                    ChatBubble(message: mensaje) { suggestion in
                                        Task { await viewModel.enviar(suggestion) }
                                    }
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
                        .background(Color.mabeBackground)
                        .scrollDismissesKeyboard(.interactively)
                        .onChange(of: viewModel.mensajes.count) {
                            scrollToBottom(proxy)
                        }
                        .onChange(of: viewModel.isTyping) {
                            scrollToBottom(proxy)
                        }
                    }

                    HStack(spacing: 10) {
                        MabeTextField(placeholder: "Escribe tu consulta...", text: $viewModel.textoActual)
                            .frame(maxHeight: 52)

                        Button {
                            Task { await viewModel.enviar() }
                        } label: {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Color.white)
                                .frame(width: 42, height: 42)
                                .background(LinearGradient.mabeHero)
                                .clipShape(Circle())
                                .scaleEffect(viewModel.textoActual.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.72 : 1)
                                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: viewModel.textoActual.isEmpty)
                        }
                        .disabled(viewModel.textoActual.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isTyping)
                        .opacity(viewModel.textoActual.isEmpty ? 0.55 : 1)
                        .accessibilityLabel("Enviar mensaje")
                    }
                    .padding(.horizontal, MabeTheme.horizontalPadding)
                    .padding(.vertical, 12)
                    .padding(.bottom, 88)
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
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showSupport) {
            HRSupportSheet(context: "Solicitud desde asistente RH")
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

private struct ChatBubble: View {
    let message: ChatMessage
    let onSuggestion: (String) -> Void

    var body: some View {
        VStack(alignment: message.rol == .usuario ? .trailing : .leading, spacing: 8) {
            if message.rol == .asistente {
                Text("M")
                    .font(.mabeLabel)
                    .foregroundStyle(Color.white)
                    .frame(width: 28, height: 28)
                    .background(LinearGradient.mabeHero)
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
                        LinearGradient.mabeHero
                    } else {
                        Color.mabeSurface
                    }
                }
                .clipShape(ChatBubbleShape(isUser: message.rol == .usuario))
                .shadow(
                    color: message.rol == .usuario ? Color.mabeElectric.opacity(0.2) : Color.mabeGray900.opacity(0.06),
                    radius: 8,
                    x: 0,
                    y: message.rol == .usuario ? 4 : 2
                )
                .frame(maxWidth: 290, alignment: message.rol == .usuario ? .trailing : .leading)

            if message.rol == .asistente, !message.sugerencias.isEmpty {
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
        }
        .frame(maxWidth: .infinity, alignment: message.rol == .usuario ? .trailing : .leading)
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
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + topRight), control: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - bottomLeft), control: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        path.addQuadCurve(to: CGPoint(x: rect.minX + topLeft, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
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

private extension AttributedString {
    init(markdownSafe text: String) {
        if let attributed = try? AttributedString(markdown: text) {
            self = attributed
        } else {
            self = AttributedString(text)
        }
    }
}
