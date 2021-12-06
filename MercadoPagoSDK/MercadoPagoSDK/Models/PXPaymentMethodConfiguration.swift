import UIKit

class PXPaymentMethodConfiguration: NSObject {
    let paymentOptionID: String
    let paymentMethodId: String?
    let paymentTypeId: String?
    let discountInfo: String?
    let creditsInfo: String?
    let paymentOptionsConfigurations: [PXPaymentOptionConfiguration]
    let selectedAmountConfiguration: String?

    init(customOptionSearchItem: PXCustomOptionSearchItem, paymentOptionsConfigurations: [PXPaymentOptionConfiguration]) {
        self.paymentOptionID = customOptionSearchItem.id
        self.paymentMethodId = customOptionSearchItem.paymentMethodId
        self.paymentTypeId = customOptionSearchItem.paymentTypeId
        self.discountInfo = customOptionSearchItem.discountInfo
        self.creditsInfo = customOptionSearchItem.comment
        self.paymentOptionsConfigurations = paymentOptionsConfigurations
        self.selectedAmountConfiguration = customOptionSearchItem.couponToApply
        super.init()
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let otherConfiguration = object as? PXPaymentMethodConfiguration else {
            return false
        }
        // Return true if id, paymentMethodId and paymentTypeId are equal
        return paymentOptionID == otherConfiguration.paymentOptionID && paymentMethodId == otherConfiguration.paymentMethodId && paymentTypeId == otherConfiguration.paymentTypeId
    }

    func getCreditsComment() -> String? {
        if paymentOptionID == PXPaymentTypes.CONSUMER_CREDITS.rawValue {
            return creditsInfo
        }
        return nil
    }
}

class PXPaymentOptionConfiguration: NSObject {
    let id: String
    let discountConfiguration: PXDiscountConfiguration?
    let amountConfiguration: PXAmountConfiguration?

    init(id: String, discountConfiguration: PXDiscountConfiguration? = nil, payerCostConfiguration: PXAmountConfiguration? = nil) {
        self.id = id
        self.discountConfiguration = discountConfiguration
        self.amountConfiguration = payerCostConfiguration
        super.init()
    }
}
