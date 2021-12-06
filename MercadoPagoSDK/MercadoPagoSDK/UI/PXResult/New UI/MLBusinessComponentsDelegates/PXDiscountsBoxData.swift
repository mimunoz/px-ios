import UIKit
import MLBusinessComponents

class PXDiscountsBoxData: NSObject, MLBusinessDiscountBoxData {
    let discounts: PXDiscounts

    init(discounts: PXDiscounts) {
        self.discounts = discounts
    }

    func getTitle() -> String? {
        return discounts.title
    }

    func getSubtitle() -> String? {
        return discounts.subtitle
    }

    func getItems() -> [MLBusinessSingleItemProtocol] {
        var itemProtocols = [MLBusinessSingleItemProtocol]()
        for item in discounts.items {
            itemProtocols.append(PXDiscountItemData(item: item))
        }
        return itemProtocols
    }

    func getDiscountTracker() -> MLBusinessDiscountTrackerProtocol? {
        return PXDiscountTracker(touchPointId: "px_congrats")
    }
}
