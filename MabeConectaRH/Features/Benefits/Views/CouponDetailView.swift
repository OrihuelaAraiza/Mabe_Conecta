import SwiftUI

struct CouponDetailView: View {
    @State private var coupon: Coupon
    @State private var showSupport = false
    let onUse: () -> Void

    init(coupon: Coupon, onUse: @escaping () -> Void) {
        _coupon = State(initialValue: coupon)
        self.onUse = onUse
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                hero
                detailCard
                codeCard
                actionButton
                supportButton
            }
            .padding(.horizontal, MabeTheme.horizontalPadding)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(Color.mabeBackground)
        .navigationTitle("Detalle")
        .mabeNavigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSupport) {
            HRSupportSheet(context: "Problema con cupón: \(coupon.title)")
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: coupon.iconName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 58, height: 58)
                    .background(LinearGradient.mabeHero)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                Spacer()
                Text(coupon.status.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(coupon.status.color)
                    .padding(.horizontal, 12)
                    .frame(height: 30)
                    .background(coupon.status.color.opacity(0.12))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(coupon.valueText)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.mabeBlue)
                Text(coupon.title)
                    .font(.mabeHeadline)
                    .foregroundStyle(Color.mabeGray900)
            }
        }
        .padding(20)
        .background(Color.mabeSurface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.mabeGray900.opacity(0.07), radius: 16, x: 0, y: 4)
    }

    private var detailCard: some View {
        MabeCard {
            VStack(alignment: .leading, spacing: 14) {
                infoRow("Descripción", coupon.description)
                infoRow("Categoría", coupon.category.rawValue)
                infoRow("Vigencia", coupon.expirationDate.formatted(date: .abbreviated, time: .omitted))
                infoRow("Aliado", coupon.partnerName)

                Divider()

                VStack(alignment: .leading, spacing: 6) {
                    Label("Recomendación inteligente", systemImage: "sparkles")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.mabeBlue)
                    Text(coupon.recommendedReason ?? "Este beneficio puede ayudarte a reducir gastos personales este mes.")
                        .font(.mabeSub)
                        .foregroundStyle(Color.mabeGray600)
                }
            }
        }
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.mabeCaption)
                .foregroundStyle(Color.mabeGray500)
                .frame(width: 92, alignment: .leading)
            Text(value)
                .font(.mabeCaption.weight(.semibold))
                .foregroundStyle(Color.mabeGray900)
            Spacer()
        }
    }

    private var codeCard: some View {
        MabeCard {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.mabeGray100)
                        .frame(height: 96)
                    VStack(spacing: 8) {
                        Image(systemName: "qrcode")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(Color.mabeBlue)
                        Text("Código: MABE-2026-RH")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.mabeGray900)
                    }
                }

                Label("Este beneficio es personal e intransferible.", systemImage: "lock.fill")
                    .font(.mabeCaption)
                    .foregroundStyle(Color.mabeGray500)
            }
        }
    }

    private var actionButton: some View {
        Button {
            guard coupon.isUsable else { return }
            coupon.status = .used
            coupon.usedDate = Date()
            onUse()
        } label: {
            Text(actionTitle)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(coupon.isUsable ? LinearGradient.mabeHero : LinearGradient(colors: [Color.mabeGray400], startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .disabled(!coupon.isUsable)
    }

    private var actionTitle: String {
        switch coupon.status {
        case .available, .expiringSoon: "Usar cupón"
        case .used: "Cupón usado"
        case .expired: "Cupón expirado"
        }
    }

    private var supportButton: some View {
        Button {
            showSupport = true
        } label: {
            Label("Tengo un problema con este beneficio", systemImage: "person.crop.circle.badge.questionmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.mabeBlue)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Color.mabeBlue.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}
