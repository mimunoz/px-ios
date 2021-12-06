import Foundation

extension PXSplitConfiguration {
    func getSplitAmountToPay() -> Double {
        guard let amount = secondaryPaymentMethod?.amount else {
            return 0
        }
        if let discountAmountOff = secondaryPaymentMethod?.discount?.couponAmount {
            return amount - discountAmountOff
        } else {
            return amount
        }
    }
}
