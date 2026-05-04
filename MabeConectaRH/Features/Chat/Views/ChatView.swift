import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

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
                .background(Color.mabeGray100)
                .onChange(of: viewModel.mensajes.count) {
                    scrollToBottom(proxy)
                }
                .onChange(of: viewModel.isTyping) {
                    scrollToBottom(proxy)
                }
            }

            HStack(spacing: 10) {
                MabeTextField(placeholder: "Escribe tu consulta", text: $viewModel.textoActual)
                    .frame(maxHeight: 52)

                Button {
                    Task { await viewModel.enviar() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(Color.mabeBlue)
                        .frame(width: 44, height: 44)
                }
                .disabled(viewModel.textoActual.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isTyping)
                .opacity(viewModel.textoActual.isEmpty ? 0.55 : 1)
                .accessibilityLabel("Enviar mensaje")
            }
            .padding(.horizontal, MabeTheme.horizontalPadding)
            .padding(.vertical, 12)
            .background(Color.white)
        }
        .mabeNavigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var chatHeader: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Asistente RH")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.mabeGray900)
                HStack(spacing: 6) {
                    PulsingDot()
                    Text("Siempre disponible")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.mabeGray500)
                }
            }
            Spacer()
        }
        .padding(.horizontal, MabeTheme.horizontalPadding)
        .padding(.vertical, 12)
        .background(Color.white)
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

private struct ChatBubble: View {
    let message: ChatMessage
    let onSuggestion: (String) -> Void

    var body: some View {
        VStack(alignment: message.rol == .usuario ? .trailing : .leading, spacing: 8) {
            if message.rol == .asistente {
                Text("M")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.mabeBlue)
                    .frame(width: 26, height: 26)
                    .background(Color.white)
                    .clipShape(Circle())
                    .mabeCardShadow()
            }

            Text(AttributedString(markdownSafe: message.texto))
                .font(.body)
                .foregroundStyle(message.rol == .usuario ? Color.white : Color.mabeGray900)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(message.rol == .usuario ? Color.mabeBlue : Color.mabeGray100)
                .overlay {
                    if message.rol == .asistente {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.mabeGray200, lineWidth: 1)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .frame(maxWidth: 290, alignment: message.rol == .usuario ? .trailing : .leading)

            if message.rol == .asistente, !message.sugerencias.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(message.sugerencias, id: \.self) { suggestion in
                            Button {
                                Haptics.impact(.light)
                                onSuggestion(suggestion)
                            } label: {
                                Text(suggestion)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.mabeBlue)
                                    .padding(.horizontal, 12)
                                    .frame(height: 34)
                                    .background(Color.white)
                                    .overlay {
                                        Capsule().stroke(Color.mabeBlue.opacity(0.35), lineWidth: 1)
                                    }
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
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
    var body: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.mabeBlue)
                        .frame(width: 7, height: 7)
                        .scaleEffect(1.0)
                        .opacity(0.45)
                        .modifier(PulseDelay(delay: Double(index) * 0.15))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(Capsule())
            .mabeCardShadow()
            Spacer()
        }
        .accessibilityLabel("El asistente está escribiendo")
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

private struct PulsingDot: View {
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
