import Foundation

extension PXResultViewModel {
    func hasReceiptComponent() -> Bool {
        if self.paymentResult.paymentId == nil {
            return false
        }
        if paymentResult.isApproved() {
            let isPaymentMethodPlugin = self.paymentResult.paymentData?.getPaymentMethod()?.paymentTypeId == PXPaymentTypes.PAYMENT_METHOD_PLUGIN.rawValue

            if isPaymentMethodPlugin {
                let hasReceiptId = !String.isNullOrEmpty(self.paymentResult.paymentId)
                if hasReceiptId {
                    return true
                }
            } else if !self.preference.isPaymentIdDisable() {
                return true
            }
        }
        return false
    }
}
