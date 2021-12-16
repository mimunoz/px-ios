import Foundation

public class PXScheduledPaymentProcessorAdapter: PXPaymentProcessorAdapter {
    override public func supportSplitPaymentMethodPayment(checkoutStore: PXCheckoutStore) -> Bool {
        return false
    }

    override public func support() -> Bool {
        return true
    }

    override public func getProcessorType() -> PXCheckoutType {
        .CUSTOM_SCHEDULED
    }

    override public func startPayment(checkoutStore: PXCheckoutStore, errorHandler: PXPaymentProcessorErrorHandler, successWithBasePayment: @escaping ((PXBasePayment) -> Void)) {
        paymentProcessor.startPayment?(checkoutStore: checkoutStore, errorHandler: errorHandler, successWithBusinessResult: { businessResult in
            successWithBasePayment(businessResult)
        }, successWithPaymentResult: { genericPayment in
            successWithBasePayment(genericPayment)
        })
    }
}
