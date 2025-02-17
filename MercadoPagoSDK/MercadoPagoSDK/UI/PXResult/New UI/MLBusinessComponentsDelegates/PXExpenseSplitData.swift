import Foundation
import MLBusinessComponents

class PXExpenseSplitData: NSObject {
    let expenseSplitData: PXExpenseSplit

    init(expenseSplitData: PXExpenseSplit) {
        self.expenseSplitData = expenseSplitData
    }
}

extension PXExpenseSplitData: MLBusinessActionCardViewData {
    func getTitle() -> String {
        return expenseSplitData.title.message ?? " "
    }

    func getTitleColor() -> String {
        return expenseSplitData.title.textColor ?? ""
    }

    func getTitleBackgroundColor() -> String {
        return expenseSplitData.title.backgroundColor ?? ""
    }

    func getTitleWeight() -> String {
        return expenseSplitData.title.weight ?? ""
    }

    func getImageUrl() -> String {
        return expenseSplitData.imageUrl
    }

    func getAffordanceText() -> String {
        return expenseSplitData.action.label
    }
}
