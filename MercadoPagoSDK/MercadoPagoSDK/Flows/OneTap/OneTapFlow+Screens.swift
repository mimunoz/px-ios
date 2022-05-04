import Foundation

extension OneTapFlow {
    func showOneTapViewController() {
        let callbackPaymentData: ((PXPaymentData) -> Void) = { [weak self] (_: PXPaymentData) in
            self?.cancelFlowForNewPaymentSelection()
        }
        let callbackConfirm: ((PXPaymentData, Bool) -> Void) = { [weak self] paymentData, splitAccountMoneyEnabled in
            guard let self = self else { return }
            self.model.updateCheckoutModel(paymentData: paymentData, splitAccountMoneyEnabled: splitAccountMoneyEnabled)
            // Deletes default one tap option in payment method search
            self.executeNextStep()
        }
        let callbackUpdatePaymentOption: ((PaymentMethodOption) -> Void) = { [weak self] paymentMethodOption in
            if let cardSliderViewModel = paymentMethodOption as? PXCardSliderViewModel,
               let paymentMethodType = cardSliderViewModel.selectedApplication?.paymentTypeId,
               let customerPaymentMethodOption = self?.getCustomerPaymentMethodOption(cardId: cardSliderViewModel.cardId ?? "", paymentMethodType: paymentMethodType) {
                // Customer card.
                self?.model.paymentOptionSelected = customerPaymentMethodOption
            } else {
                self?.model.paymentOptionSelected = paymentMethodOption
            }
        }
        let callbackRefreshInit: ((String) -> Void) = { [weak self] cardId in
            self?.refreshInitFlow(cardId: cardId)
        }
        
        let callbackNewBankAccount: ((String) -> Void) = { [weak self] accountId in
            self?.refreshInitFlow(withNewAccountId: accountId)
        }
        
        let callbackExit: (() -> Void) = { [weak self] in
            self?.cancelFlow()
        }
        
        let finishButtonAnimation: (() -> Void) = { [weak self] in
            self?.executeNextStep()
        }

        let viewModel = model.oneTapViewModel()
        model.pxOneTapViewModel = viewModel

        let hasInstallments = model.search.payerPaymentMethods.contains { payerPaymentMethod -> Bool in
            guard let paymentOptions = payerPaymentMethod.paymentOptions else { return false }

            return paymentOptions.contains { (_: String, amountConfiguration: PXAmountConfiguration) -> Bool in
                guard let payerCostsCount = amountConfiguration.payerCosts?.count else { return false }

                return  payerCostsCount > 1
            }
        }

        let hasSplit = model.search.payerPaymentMethods.contains { payerPaymentMethod -> Bool in
            guard let paymentOptions = payerPaymentMethod.paymentOptions else { return false }

            return paymentOptions.contains { (_: String, amountConfiguration: PXAmountConfiguration) -> Bool in
                guard let _ = amountConfiguration.splitConfiguration else { return false }

                return true
            }
        }

        let hasDiscounts = model.search.coupons.filter { ( key: String, _: PXDiscountConfiguration ) -> Bool in
            return key != "hash_no_discount"
        }.count > 0

        var hasCharges: Bool = false

        if let chargeRules = model.chargeRules,
           chargeRules.contains(where: { chargeRule -> Bool in
            return chargeRule.amountCharge != 0
           }) {
            hasCharges = true
        }

        let pxOneTapContext = PXOneTapContext(hasInstallments: hasInstallments, hasSplit: hasSplit, hasCharges: hasCharges, hasDiscounts: hasDiscounts)

        let viewController = PXOneTapViewController(viewModel: viewModel,
                                                    pxOneTapContext: pxOneTapContext,
                                                    timeOutPayButton: model.getTimeoutForOneTapReviewController(), 
                                                    callbackNewBankAccount: callbackNewBankAccount,
                                                    callbackPaymentData: callbackPaymentData,
                                                    callbackConfirm: callbackConfirm,
                                                    callbackUpdatePaymentOption: callbackUpdatePaymentOption,
                                                    callbackRefreshInit: callbackRefreshInit,
                                                    callbackExit: callbackExit,
                                                    finishButtonAnimation: finishButtonAnimation)
        pxNavigationHandler.pushViewController(viewController: viewController, animated: true)
    }

    func updateOneTapViewModel(cardId: String) {
        if let oneTapViewController = pxNavigationHandler.navigationController.viewControllers.first(where: { $0 is PXOneTapViewController }) as? PXOneTapViewController {
            let viewModel = model.oneTapViewModel()
            model.pxOneTapViewModel = viewModel
            oneTapViewController.update(viewModel: viewModel, cardId: cardId)
        }
    }

    func showSecurityCodeScreen() {
        guard !isPXSecurityCodeViewControllerLastVC() else { return }
        let securityCodeVc = PXSecurityCodeViewController(viewModel: model.savedCardSecurityCodeViewModel(),
            finishButtonAnimationCallback: { [weak self] in
                self?.executeNextStep()
            }, collectSecurityCodeCallback: { [weak self] _, securityCode in
                self?.getTokenizationService().createCardToken(securityCode: securityCode)
        })
        pxNavigationHandler.pushViewController(viewController: securityCodeVc, animated: true)
    }

    func showKyCScreen() {
        MPXTracker.sharedInstance.trackEvent(event: OneTapTrackingEvents.didTapOnOfflineMethods)
        PXDeepLinkManager.open(model.getKyCDeepLink())
    }
}
