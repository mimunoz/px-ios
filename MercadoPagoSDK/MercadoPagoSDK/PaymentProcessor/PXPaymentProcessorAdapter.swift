import Foundation

public class PXPaymentProcessorAdapter: NSObject, PXSplitPaymentProcessor {
    let paymentProcessor: PXPaymentProcessor

    init(paymentProcessor: PXPaymentProcessor) {
        self.paymentProcessor = paymentProcessor
    }

    public func paymentProcessorViewController() -> UIViewController? {
        return paymentProcessor.paymentProcessorViewController()
    }

    public func support() -> Bool {
        return paymentProcessor.support()
    }

    public func supportSplitPaymentMethodPayment(checkoutStore: PXCheckoutStore) -> Bool {
        return false
    }

    func startPayment(checkoutStore: PXCheckoutStore, errorHandler: PXPaymentProcessorErrorHandler, successWithBasePayment: @escaping ((PXBasePayment) -> Void)) {
        paymentProcessor.startPayment?(checkoutStore: checkoutStore, errorHandler: errorHandler, successWithBusinessResult: { businessResult in
            successWithBasePayment(businessResult)
        }, successWithPaymentResult: { genericPayment in
            successWithBasePayment(genericPayment)
        })
    }

    func didReceive(checkoutStore: PXCheckoutStore) {
        paymentProcessor.didReceive?(checkoutStore: checkoutStore)
    }

    func didReceive(navigationHandler: PXPaymentProcessorNavigationHandler) {
        paymentProcessor.didReceive?(navigationHandler: navigationHandler)
    }

    func paymentTimeOut() -> Double {
        return paymentProcessor.paymentTimeOut?() ?? 0
    }
}
