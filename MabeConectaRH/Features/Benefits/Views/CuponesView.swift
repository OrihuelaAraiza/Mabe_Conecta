import SwiftUI

struct CuponesView: View {
    let showsBackButton: Bool
    let title: String

    @State private var selectedCategory: CuponCategory = .todos
    @State private var redeemedCoupons: Set<String> = []
    @State private var showingRedeemSheet = false
    @State private var selectedCoupon: Cupon?
    @State private var confettiCounter = 0
    @State private var isLoadingCoupons = true
    @State private var cuponesBackend: [Cupon] = []
    @State private var backendCouponIDsByUIID: [String: String] = [:]
    @State private var errorMessage: String?

    private let api = BackendAPI()
    @Environment(\.dismiss) private var dismiss
    @Environment(RewardService.self) private var rewardService

    private var cuponesFiltrados: [Cupon] {
        let source = cuponesBackend.isEmpty ? MockDataService.cupones : cuponesBackend
        return selectedCategory == .todos
            ? source
            : source.filter { $0.categoria == selectedCategory }
    }

    init(showsBackButton: Bool = true, title: String = "Mis Cupones") {
        self.showsBackButton = showsBackButton
        self.title = title
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                benefitsSummary
                categoryScroller

                Divider().opacity(0.3)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        prestacionesShortcut

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Cupones disponibles")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(Color(hex: "#0D1B3E"))

                            Group {
                                if isLoadingCoupons {
                                    couponSkeletonGrid
                                        .transition(.opacity)
                                } else {
                                    couponGrid
                                        .transition(.opacity)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }

            if confettiCounter > 0 {
                ConfettiBurst(trigger: confettiCounter)
                    .allowsHitTesting(false)
            }
        }
        .navigationBarHidden(true)
        .background(Color(hex: "#F8F9FC"))
        .task {
            await loadCoupons()
        }
        .sheet(isPresented: $showingRedeemSheet) {
            if let selectedCoupon {
                CuponDetailSheet(
                    cupon: selectedCoupon,
                    isRedeemed: redeemedCoupons.contains(selectedCoupon.id),
                    onRedeem: {
                        Task {
                            await redeemCoupon(selectedCoupon)
                        }
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
            }
        }
    }

    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(minimum: 145), spacing: 12),
            GridItem(.flexible(minimum: 145), spacing: 12),
        ]
    }

    private var couponGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            ForEach(cuponesFiltrados) { cupon in
                PhysicalCouponCard(
                    cupon: cupon,
                    isRedeemed: redeemedCoupons.contains(cupon.id),
                    onTap: {
                        selectedCoupon = cupon
                        showingRedeemSheet = true
                    }
                )
                .frame(height: 190)
            }
        }
    }

    private var couponSkeletonGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            ForEach(0..<6, id: \.self) { index in
                CouponSkeletonCard(index: index)
                    .frame(height: 190)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            if showsBackButton {
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
                .accessibilityLabel("Regresar")
            }

            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "#0D1B3E"))
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#D97706"))
                Text("\(rewardService.profile.puntosDisponibles) pts")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "#D97706"))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(hex: "#D97706").opacity(0.1))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(Color(hex: "#F8F9FC"))
    }

    private var benefitsSummary: some View {
        HStack(spacing: 0) {
            summaryItem(
                value: "\(max(0, MockDataService.cupones.count - redeemedCoupons.count))",
                label: "Disponibles",
                color: Color(hex: "#003087")
            )
            Divider().frame(height: 38)
            summaryItem(value: "2", label: "Por expirar", color: Color(hex: "#D97706"))
            Divider().frame(height: 38)
            summaryItem(
                value: "\(redeemedCoupons.count)", label: "Usados", color: Color(hex: "#00C27C"))
        }
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color(hex: "#0D1B3E").opacity(0.06), radius: 12, x: 0, y: 4)
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    private func summaryItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 21, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(hex: "#9AA5BE"))
        }
        .frame(maxWidth: .infinity)
    }

    private var prestacionesShortcut: some View {
        NavigationLink {
            PrestacionesView()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 46, height: 46)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#003087"), Color(hex: "#1976FF")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Mis Prestaciones")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(hex: "#0D1B3E"))
                    Text(
                        "\(MockDataService.numPrestaciones) prestaciones activas · \(MockDataService.valorPaquetePrestaciones)"
                    )
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#9AA5BE"))
                    .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "#DDE3F0"))
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color(hex: "#0D1B3E").opacity(0.06), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var categoryScroller: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CuponCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.label,
                        icon: category.icon,
                        isSelected: selectedCategory == category,
                        action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedCategory = category
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
        .padding(.bottom, 8)
    }
}

private struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : Color(hex: "#4B5675"))
            .padding(.horizontal, 12)
            .frame(height: 34)
            .background(isSelected ? Color(hex: "#003087") : Color.white)
            .clipShape(Capsule())
            .shadow(color: Color(hex: "#0D1B3E").opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

private struct CuponCard: View {
    let cupon: Cupon
    let isRedeemed: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(cupon.gradient)
                        .frame(height: 90)
                        .overlay(alignment: .bottomTrailing) {
                            Image(systemName: cupon.icon)
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.25))
                                .offset(x: 16, y: 16)
                        }

                    Text(cupon.categoria.label)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(.white.opacity(0.25))
                        .clipShape(Capsule())
                        .padding(8)

                    if isRedeemed {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.black.opacity(0.45))
                            .frame(height: 90)
                            .overlay {
                                VStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                    Text("Canjeado")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(cupon.titulo)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(hex: "#0D1B3E"))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(cupon.empresa)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "#9AA5BE"))

                    Spacer().frame(height: 6)

                    HStack(spacing: 0) {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "#D97706"))
                            Text("\(cupon.puntosCosto)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "#D97706"))
                        }

                        Spacer()

                        Text("Vence \(cupon.vencimiento)")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(Color(hex: "#9AA5BE"))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(
                color: Color(hex: "#0D1B3E").opacity(isRedeemed ? 0.03 : 0.07), radius: 10, x: 0,
                y: 3
            )
            .opacity(isRedeemed ? 0.65 : 1.0)
        }
        .buttonStyle(ScrollFriendlyPressButtonStyle(scale: 0.97))
        .animation(.spring(response: 0.3), value: isRedeemed)
    }
}

private struct CouponSkeletonCard: View {
    let index: Int
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#DDE3F0"),
                            Color(hex: "#EFF3FA"),
                            Color(hex: "#DDE3F0"),
                        ],
                        startPoint: pulse ? .trailing : .leading,
                        endPoint: pulse ? .leading : .trailing
                    )
                )
                .frame(height: 100)

            DashedDivider()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .foregroundColor(Color(hex: "#DDE3F0"))
                .frame(height: 1)

            VStack(alignment: .leading, spacing: 9) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: "#DDE3F0"))
                    .frame(height: 12)
                    .frame(maxWidth: .infinity)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: "#EFF3FA"))
                    .frame(width: 82, height: 10)
                Spacer()
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: "#DDE3F0"))
                    .frame(height: 18)
                    .opacity(0.7)
            }
            .padding(10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color(hex: "#0D1B3E").opacity(0.05), radius: 10, x: 0, y: 3)
        .opacity(pulse ? 0.7 : 1.0)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(
                    Double(index) * 0.04)
            ) {
                pulse = true
            }
        }
    }
}

private struct PhysicalCouponCard: View {
    let cupon: Cupon
    let isRedeemed: Bool
    let onTap: () -> Void

    @State private var shimmerPhase: CGFloat = 0

    var body: some View {
        Button(action: onTap) {
            ZStack {
                VStack(spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        Color(hex: "#003087")
                            .frame(height: 100)

                        cupon.gradient
                            .frame(height: 100)

                        HStack(spacing: 6) {
                            ForEach(0..<8, id: \.self) { _ in
                                VStack(spacing: 6) {
                                    ForEach(0..<5, id: \.self) { _ in
                                        Circle()
                                            .fill(.white.opacity(0.08))
                                            .frame(width: 3, height: 3)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                        .padding(.trailing, 8)

                        Image(systemName: cupon.icon)
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.15))
                            .offset(x: 100, y: 20)

                        HStack(spacing: 4) {
                            Image(systemName: cupon.icon)
                                .font(.system(size: 10, weight: .bold))
                            Text(cupon.empresa)
                                .font(.system(size: 10, weight: .bold))
                                .lineLimit(1)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                        .padding(10)

                        LinearGradient(
                            colors: [.clear, .white.opacity(0.12), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: 72)
                        .rotationEffect(.degrees(18))
                        .offset(x: shimmerPhase * 260 - 110)
                        .onAppear {
                            withAnimation(
                                .linear(duration: 3).repeatForever(autoreverses: false).delay(
                                    Double.random(in: 0...2))
                            ) {
                                shimmerPhase = 1
                            }
                        }
                        .allowsHitTesting(false)
                        .clipped()
                    }
                    .frame(height: 100)
                    .clipped()

                    DashedDivider()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundColor(Color(hex: "#DDE3F0"))
                        .frame(height: 1)
                        .overlay(alignment: .leading) {
                            Circle()
                                .fill(Color(hex: "#F8F9FC"))
                                .frame(width: 16, height: 16)
                                .offset(x: -8)
                        }
                        .overlay(alignment: .trailing) {
                            Circle()
                                .fill(Color(hex: "#F8F9FC"))
                                .frame(width: 16, height: 16)
                                .offset(x: 8)
                        }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(cupon.titulo)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "#0D1B3E"))
                            .lineLimit(2)
                            .frame(minHeight: 32, alignment: .topLeading)

                        HStack {
                            HStack(spacing: 3) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 9))
                                    .foregroundColor(Color(hex: "#D97706"))
                                Text("\(cupon.puntosCosto) pts")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(hex: "#D97706"))
                            }
                            Spacer()
                            Text("vence \(cupon.vencimiento)")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "#9AA5BE"))
                        }

                        BarcodeStripes()
                            .frame(height: 20)
                            .opacity(0.25)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(Color.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color(hex: "#0D1B3E").opacity(0.08), radius: 12, x: 0, y: 4)

                if isRedeemed {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.black.opacity(0.35))
                        .overlay {
                            Text("CANJEADO")
                                .font(.system(size: 18, weight: .black))
                                .foregroundColor(.white.opacity(0.9))
                                .rotationEffect(.degrees(-25))
                                .overlay {
                                    Text("CANJEADO")
                                        .font(.system(size: 18, weight: .black))
                                        .foregroundColor(Color(hex: "#F03E3E").opacity(0.6))
                                        .rotationEffect(.degrees(-25))
                                        .offset(x: 1, y: 1)
                                }
                        }
                        .allowsHitTesting(false)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 190)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(ScrollFriendlyPressButtonStyle(scale: 0.96))
    }
}

private struct ScrollFriendlyPressButtonStyle: ButtonStyle {
    let scale: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(
                .spring(response: 0.22, dampingFraction: 0.82), value: configuration.isPressed)
    }
}

private struct DashedDivider: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}

private struct BarcodeStripes: View {
    private let pattern: [CGFloat] = [
        2, 1, 3, 1, 2, 2, 1, 2, 3, 1, 2, 1, 3, 2, 1, 2, 1, 3, 1, 2, 2, 1, 3,
    ]

    var body: some View {
        HStack(spacing: 1) {
            ForEach(pattern.indices, id: \.self) { index in
                Rectangle()
                    .fill(Color(hex: "#0D1B3E"))
                    .frame(width: pattern[index])
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct CuponDetailSheet: View {
    let cupon: Cupon
    let isRedeemed: Bool
    let onRedeem: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showingCode = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .fill(cupon.gradient)
                    .frame(height: 160)

                Image(systemName: cupon.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.15))
                    .offset(x: 200, y: 20)

                VStack(alignment: .leading, spacing: 4) {
                    Text(cupon.empresa)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                    Text(cupon.titulo)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(20)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(cupon.descripcion)
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "#4B5675"))
                        .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Condiciones")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#0D1B3E"))
                        ForEach(cupon.terminos, id: \.self) { termino in
                            HStack(alignment: .top, spacing: 8) {
                                Circle()
                                    .fill(Color(hex: "#9AA5BE"))
                                    .frame(width: 5, height: 5)
                                    .padding(.top, 6)
                                Text(termino)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "#6B7280"))
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    if showingCode {
                        VStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.white)
                                    .frame(width: 160, height: 160)
                                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                                Image(systemName: "qrcode")
                                    .font(.system(size: 100))
                                    .foregroundColor(Color(hex: "#0D1B3E"))
                            }

                            Text(cupon.codigoPromo)
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(hex: "#003087"))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color(hex: "#EFF3FA"))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                            Text("Muestra este código al momento del pago")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#9AA5BE"))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                    }
                }
                .padding(.vertical, 20)
            }

            Spacer()
            footerButton
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
        }
        .buttonStyle(.plain)
        .ignoresSafeArea(edges: .top)
    }

    @ViewBuilder
    private var footerButton: some View {
        if isRedeemed && showingCode {
            Button("Cerrar") { dismiss() }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "#4B5675"))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color(hex: "#EFF3FA"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        } else if isRedeemed {
            Button {
                withAnimation(.spring(response: 0.4)) { showingCode = true }
            } label: {
                Label("Ver mi código", systemImage: "qrcode")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(hex: "#003087"))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        } else {
            Button {
                onRedeem()
                withAnimation(.spring(response: 0.4).delay(0.3)) { showingCode = true }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                    Text("Canjear por \(cupon.puntosCosto) puntos")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color(hex: "#003087"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: Color(hex: "#1976FF").opacity(0.35), radius: 12, x: 0, y: 6)
            }
        }
    }
}

extension CuponesView {
    @MainActor
    fileprivate func loadCoupons() async {
        guard isLoadingCoupons else { return }

        guard let session = SessionService.load(),
            let authToken = session.authToken
        else {
            try? await Task.sleep(nanoseconds: 180_000_000)
            withAnimation(.easeInOut(duration: 0.22)) {
                isLoadingCoupons = false
            }
            return
        }

        do {
            async let availableTask = api.listCoupons(authToken: authToken)
            async let purchasedTask = api.listBoughtCoupons(authToken: authToken)

            let available = try await availableTask
            let purchased = try await purchasedTask

            var mapped = available.map { $0.toCupon() }
            var usedSet = Set<String>()
            var idMap: [String: String] = [:]

            for backendCoupon in available {
                idMap[backendCoupon.coupon_id] = backendCoupon.coupon_id
            }

            for purchase in purchased where purchase.used {
                usedSet.insert(purchase.coupon_id)
            }

            mapped = mapped.map { coupon in
                var mutable = coupon
                if usedSet.contains(coupon.id) {
                    mutable = Cupon(
                        id: coupon.id,
                        titulo: coupon.titulo,
                        empresa: coupon.empresa,
                        descripcion: coupon.descripcion,
                        icon: coupon.icon,
                        gradient: coupon.gradient,
                        categoria: coupon.categoria,
                        puntosCosto: coupon.puntosCosto,
                        vencimiento: coupon.vencimiento,
                        codigoPromo: coupon.codigoPromo,
                        terminos: coupon.terminos
                    )
                }
                return mutable
            }

            withAnimation(.easeInOut(duration: 0.25)) {
                cuponesBackend = mapped
                redeemedCoupons = usedSet
                backendCouponIDsByUIID = idMap
                isLoadingCoupons = false
            }
        } catch {
            try? await Task.sleep(nanoseconds: 180_000_000)
            withAnimation(.easeInOut(duration: 0.22)) {
                errorMessage = error.localizedDescription
                isLoadingCoupons = false
            }
        }
    }

    @MainActor
    fileprivate func redeemCoupon(_ coupon: Cupon) async {
        guard let session = SessionService.load(),
            let authToken = session.authToken,
            let backendCouponID = backendCouponIDsByUIID[coupon.id]
        else {
            redeemLocally(coupon)
            return
        }

        do {
            _ = try await api.buyCoupon(couponID: backendCouponID, authToken: authToken)
            redeemLocally(coupon)
        } catch {
            // Keep demo resilient: local fallback if backend redemption fails
            redeemLocally(coupon)
        }
    }

    @MainActor
    fileprivate func redeemLocally(_ coupon: Cupon) {
        redeemedCoupons.insert(coupon.id)
        rewardService.ganarPuntos(
            tipo: .cuponCanjeado,
            descripcion: "Cupón canjeado: \(coupon.titulo)"
        )
        rewardService.canjearPuntos(coupon.puntosCosto)
        showingRedeemSheet = false
        confettiCounter += 1
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

private struct ConfettiBurst: View {
    let trigger: Int
    @State private var burst = false

    var body: some View {
        ZStack {
            ForEach(0..<40, id: \.self) { index in
                Circle()
                    .fill(
                        [
                            Color(hex: "#003087"), Color(hex: "#7C5CFC"), Color(hex: "#00C27C"),
                            .white,
                        ][index % 4]
                    )
                    .frame(width: CGFloat(5 + index % 4), height: CGFloat(5 + index % 4))
                    .offset(
                        x: burst ? CGFloat((index % 9) - 4) * 28 : 0,
                        y: burst ? -CGFloat(80 + (index % 8) * 24) : 0
                    )
                    .opacity(burst ? 0 : 1)
                    .animation(.easeOut(duration: 1.1).delay(Double(index) * 0.015), value: burst)
            }
        }
        .onAppear { burst = true }
        .onChange(of: trigger) { _, _ in
            burst = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                burst = true
            }
        }
    }
}
