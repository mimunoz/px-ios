import Foundation

struct PointsAndDiscountsViewModel {
    let pointsAndDiscounts: PXPointsAndDiscounts

    init(_ withModel: PXPointsAndDiscounts) {
        self.pointsAndDiscounts = withModel
    }
}
