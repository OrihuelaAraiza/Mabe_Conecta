import SwiftUI

struct BenefitsView: View {
    @State private var viewModel = CouponViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                summaryCard
                prestacionesShortcut
                filters
                couponsSection
                historySection
            }
            .padding(.horizontal, MabeTheme.horizontalPadding)
            .padding(.top, 16)
            .padding(.bottom, 104)
        }
        .background(Color.mabeBackground)
        .navigationBarHidden(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tus beneficios mabe")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.mabeGray900)
            Text("Aprovecha tus cupones y beneficios antes de que expiren.")
                .font(.mabeSub)
                .foregroundStyle(Color.mabeGray600)
        }
    }

    private var summaryCard: some View {
        MabeCard {
            HStack(spacing: 0) {
                summaryItem(value: "\(viewModel.availableCount)", label: "Disponibles", color: .mabeBlue)
                Divider().frame(height: 46)
                summaryItem(value: "\(viewModel.expiringSoonCount)", label: "Por expirar", color: .mabeWarning)
                Divider().frame(height: 46)
                summaryItem(value: "\(viewModel.usedThisMonthCount)", label: "Usados mes", color: .mabeSuccess)
            }
        }
    }

    private func summaryItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.mabeGray500)
        }
        .frame(maxWidth: .infinity)
    }

    private var prestacionesShortcut: some View {
        NavigationLink {
            PrestacionesView()
        } label: {
            MabeCard {
                HStack(spacing: 14) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(width: 48, height: 48)
                        .background(LinearGradient.mabeHero)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mis Prestaciones")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.mabeGray900)
                        Text("\(MockDataService.numPrestaciones) prestaciones activas · \(MockDataService.valorPaquetePrestaciones)")
                            .font(.mabeCaption)
                            .foregroundStyle(Color.mabeGray500)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.mabeGray400)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var filters: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterButton("Todos", isSelected: viewModel.selectedStatus == nil) {
                        viewModel.selectedStatus = nil
                    }
                    ForEach(CouponStatus.allCases) { status in
                        filterButton(status.title, isSelected: viewModel.selectedStatus == status) {
                            viewModel.selectedStatus = status
                        }
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    categoryButton("Todas", isSelected: viewModel.selectedCategory == nil) {
                        viewModel.selectedCategory = nil
                    }
                    ForEach(CouponCategory.allCases) { category in
                        categoryButton(category.rawValue, isSelected: viewModel.selectedCategory == category) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
            }
        }
    }

    private func filterButton(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? Color.white : Color.mabeGray600)
                .padding(.horizontal, 14)
                .frame(height: 34)
                .background(isSelected ? Color.mabeBlue : Color.mabeSurface)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func categoryButton(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(isSelected ? Color.mabeBlue : Color.mabeGray500)
                .padding(.horizontal, 12)
                .frame(height: 30)
                .background(isSelected ? Color.mabeBlue.opacity(0.1) : Color.mabeSurface)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var couponsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cupones")
                .font(.mabeHeadline)
                .foregroundStyle(Color.mabeGray900)

            ForEach(viewModel.filteredCoupons) { coupon in
                NavigationLink {
                    CouponDetailView(coupon: coupon) {
                        viewModel.markUsed(coupon)
                    }
                } label: {
                    CouponRow(coupon: coupon)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Historial de uso")
                .font(.mabeHeadline)
                .foregroundStyle(Color.mabeGray900)

            ForEach(viewModel.usedCoupons) { coupon in
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.mabeSuccess)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(coupon.title)
                            .font(.mabeCaption.weight(.semibold))
                            .foregroundStyle(Color.mabeGray900)
                        Text("Usado en modo demo")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.mabeGray500)
                    }
                    Spacer()
                }
                .padding(12)
                .background(Color.mabeSurface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }
}

private struct CouponRow: View {
    let coupon: Coupon

    var body: some View {
        MabeCard {
            HStack(spacing: 14) {
                Image(systemName: coupon.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 46, height: 46)
                    .background(LinearGradient.mabeHero)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(coupon.valueText)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.mabeBlue)
                        statusBadge
                    }
                    Text(coupon.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.mabeGray900)
                    Text("\(coupon.partnerName) · \(coupon.category.rawValue)")
                        .font(.mabeCaption)
                        .foregroundStyle(Color.mabeGray500)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.mabeGray400)
            }
        }
    }

    private var statusBadge: some View {
        Text(coupon.status.title)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(coupon.status.color)
            .padding(.horizontal, 8)
            .frame(height: 22)
            .background(coupon.status.color.opacity(0.1))
            .clipShape(Capsule())
    }
}
