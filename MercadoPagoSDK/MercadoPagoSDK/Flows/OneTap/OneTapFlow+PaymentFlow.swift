import Foundation

extension OneTapFlow {
    func startPaymentFlow() {
        guard let paymentFlow = model.paymentFlow else {
            model.paymentData.cleanToken()
            return
        }
        model.invalidESCReason = nil
        paymentFlow.paymentErrorHandler = self
        if isShowingLoading() {
            pxNavigationHandler.presentLoading()
        }
        paymentFlow.setData(amountHelper: model.amountHelper, checkoutPreference: model.checkoutPreference, resultHandler: self, splitAccountMoney: model.splitAccountMoney)
        paymentFlow.setupValidationProgramId(validationProgramId: model.getProgramValidation())
        paymentFlow.start()
    }

    func isShowingLoading() -> Bool {
        return pxNavigationHandler.isLoadingPresented() || pxNavigationHandler.isShowingDynamicViewController()
    }

    private func finishPaymentFlow(status: String, statusDetail: String? = nil) {
        if isShowingLoading() {
            executeNextStep()
        } else {
            PXAnimatedButton.animateButtonWith(status: status, statusDetail: statusDetail)
        }
    }
}

extension OneTapFlow: PXPaymentResultHandlerProtocol {
    func finishPaymentFlow(error: MPSDKError) {
        DispatchQueue.main.async {
            let lastViewController = self.pxNavigationHandler.navigationController.viewControllers.last
            if let oneTapViewController = lastViewController as? PXOneTapViewController {
                self.dismissLoading(finishCallback: {
                    oneTapViewController.resetButton(error: error)
                })
            } else if let securityCodeVC = lastViewController as? PXSecurityCodeViewController {
                self.dismissLoading(finishCallback: { [weak self] in
                    self?.resetButtonAndCleanToken(securityCodeVC: securityCodeVC, error: error)
                })
            }
        }
    }

    private func dismissLoading(finishCallback:(() -> Void)? = nil) {
        if pxNavigationHandler.isLoadingPresented() {
            pxNavigationHandler.dismissLoading(animated: true, finishCallback: {
                if let callback = finishCallback {
                    callback()
                }
            })
            return
        }
        if let callback = finishCallback {
            callback()
        }
    }

    private func resetButtonAndCleanToken(securityCodeVC: PXSecurityCodeViewController, error: MPSDKError) {
        model.paymentData.cleanToken()
        securityCodeVC.resetButton()
    }

    func finishPaymentFlow(paymentResult: PaymentResult, instructionsInfo: PXInstruction?, pointsAndDiscounts: PXPointsAndDiscounts?, checkoutPreference: PXCheckoutPreference?) {
        if paymentResult.isApproved() {
            isPaymentToggle.toggle()
            strategyTrackings.getPropertieFlowSuccess(flow: "Pagamento aprovado payment: \(isPaymentToggle)")
        }
        if paymentResult.isRejected() {
            ConcurrencyPayments.shared.revert(data: checkoutPreference)
            MPXTracker.sharedInstance.trackScreen(event: PXPaymentsInfoGeneralEvents.infoGeneral_Follow_Reject)
        }
        if paymentResult.isPending() {
            MPXTracker.sharedInstance.trackScreen(event: PXPaymentsInfoGeneralEvents.infoGeneral_Follow_Pending)
        }

        model.paymentResult = paymentResult
        model.instructionsInfo = instructionsInfo
        model.pointsAndDiscounts = pointsAndDiscounts
        finishPaymentFlow(status: paymentResult.status, statusDetail: paymentResult.statusDetail)
    }

    func finishPaymentFlow(businessResult: PXBusinessResult, pointsAndDiscounts: PXPointsAndDiscounts?) {
        if businessResult.isApproved() {
            isPaymentToggle.toggle()
            strategyTrackings.getPropertieFlowSuccess(flow: "Pagamento aprovado business: \(isPaymentToggle)")
        }
        if businessResult.isError() {
            MPXTracker.sharedInstance.trackScreen(event: PXPaymentsInfoGeneralEvents.infoGeneral_Follow_Reject)
        }
        if businessResult.isWarning() {
            MPXTracker.sharedInstance.trackScreen(event: PXPaymentsInfoGeneralEvents.infoGeneral_Follow_Pending)
        }
        model.businessResult = businessResult
        model.pointsAndDiscounts = pointsAndDiscounts
        finishPaymentFlow(status: businessResult.getBusinessStatus().getDescription())
    }
}

extension OneTapFlow: PXPaymentErrorHandlerProtocol {
    func escError(reason: PXESCDeleteReason) {
        model.readyToPay = true
        model.invalidESCReason = reason
        if let token = model.paymentData.getToken() {
            PXConfiguratorManager.escProtocol.deleteESC(config: PXConfiguratorManager.escConfig, token: token, reason: reason, detail: nil)
        }
        model.paymentData.cleanToken()
        executeNextStep()
    }
}
