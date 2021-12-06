import Foundation

extension PXPaymentFlow {
    func showPaymentProcessor(paymentProcessor: PXSplitPaymentProcessor?, programId: String?) {
        guard let paymentProcessor = paymentProcessor else {
            return
        }

        model.assignToCheckoutStore(programId: programId)

        paymentProcessor.didReceive?(navigationHandler: PXPaymentProcessorNavigationHandler(flow: self))

        if let paymentProcessorVC = paymentProcessor.paymentProcessorViewController() {
            pxNavigationHandler.addDynamicView(viewController: paymentProcessorVC)

            if let shouldSkipRyC = paymentProcessor.shouldSkipUserConfirmation?(), shouldSkipRyC, pxNavigationHandler.isLoadingPresented() {
                pxNavigationHandler.dismissLoading()
            }
            pxNavigationHandler.navigationController.pushViewController(paymentProcessorVC, animated: false)
        }
    }
}
