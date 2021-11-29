import Foundation

public class PXScheduledPaymentProcessorAdapter: PXPaymentProcessorAdapter {
    override public func supportSplitPaymentMethodPayment(checkoutStore: PXCheckoutStore) -> Bool {
        return false
    }
}
