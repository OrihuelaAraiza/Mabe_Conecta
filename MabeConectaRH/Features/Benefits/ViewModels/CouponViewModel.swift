import Foundation
import Observation

@Observable
final class CouponViewModel {
    var coupons: [Coupon]
    var selectedStatus: CouponStatus?
    var selectedCategory: CouponCategory?

    init(coupons: [Coupon] = MockDataService.coupons) {
        self.coupons = coupons
    }

    var filteredCoupons: [Coupon] {
        coupons.filter { coupon in
            let statusMatches = selectedStatus == nil || coupon.status == selectedStatus
            let categoryMatches = selectedCategory == nil || coupon.category == selectedCategory
            return statusMatches && categoryMatches
        }
    }

    var availableCount: Int {
        coupons.filter { $0.status == .available || $0.status == .expiringSoon }.count
    }

    var expiringSoonCount: Int {
        coupons.filter { $0.status == .expiringSoon }.count
    }

    var usedThisMonthCount: Int {
        coupons.filter { $0.status == .used }.count
    }

    var usedCoupons: [Coupon] {
        coupons.filter { $0.status == .used }
    }

    func markUsed(_ coupon: Coupon) {
        guard let index = coupons.firstIndex(where: { $0.id == coupon.id }) else { return }
        coupons[index].status = .used
        coupons[index].usedDate = Date()
    }
}
