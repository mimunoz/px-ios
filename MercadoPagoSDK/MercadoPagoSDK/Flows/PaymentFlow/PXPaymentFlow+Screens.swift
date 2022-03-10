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

        strategyTracking.getPropertieFlow(flow: "showPaymentProcessor")
    }

    // MARK: - Post Payment Loader Screen
    func showLoaderIfNeeded() {
        if model.postPaymentStatus == .continuing {
            let rootViewController = UIApplication.shared.keyWindow?.rootViewController
            let animationLoader = PXLoadingViewController()

            animationLoader.willMove(toParent: rootViewController)
            rootViewController?.addChild(animationLoader)
            rootViewController?.view.addSubview(animationLoader.view)
            animationLoader.didMove(toParent: rootViewController)
            animationLoader.view.bounds = rootViewController?.view.bounds ?? CGRect.zero
        }
    }

    func hideLoaderIfNeeded() {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let animationLoader = rootViewController?.children.last
        if let loaderViewController = animationLoader,
           loaderViewController.isKind(of: PXLoadingViewController.self) {
            animationLoader?.view.removeFromSuperview()
            animationLoader?.removeFromParent()
            animationLoader?.didMove(toParent: nil)
        }
    }
}
