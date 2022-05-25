import Foundation

public class PXPaymentProcessorAdapter: NSObject, PXSplitPaymentProcessor {
    public let paymentProcessor: PXPaymentProcessor

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

    public func startPayment(checkoutStore: PXCheckoutStore, errorHandler: PXPaymentProcessorErrorHandler, successWithBasePayment: @escaping ((PXBasePayment) -> Void)) {
        ConcurrencyPayments.shared.executeByCriteria(data: checkoutStore) {
            self.paymentProcessor.startPayment?(checkoutStore: checkoutStore, errorHandler: errorHandler, successWithBusinessResult: { businessResult in
                successWithBasePayment(businessResult)
            }, successWithPaymentResult: { genericPayment in
                successWithBasePayment(genericPayment)
            })
        }
    }

    public func didReceive(checkoutStore: PXCheckoutStore) {
        paymentProcessor.didReceive?(checkoutStore: checkoutStore)
    }

    public func didReceive(navigationHandler: PXPaymentProcessorNavigationHandler) {
        paymentProcessor.didReceive?(navigationHandler: navigationHandler)
    }

    public func paymentTimeOut() -> Double {
        return paymentProcessor.paymentTimeOut?() ?? 0
    }

    public func getProcessorType() -> PXCheckoutType {
        return .CUSTOM_REGULAR
    }
}
