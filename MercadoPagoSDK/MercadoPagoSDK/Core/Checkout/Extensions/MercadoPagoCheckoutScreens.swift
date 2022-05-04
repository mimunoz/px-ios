import Foundation

extension MercadoPagoCheckout {
    func showSecurityCodeScreen() {
        guard !viewModel.isPXSecurityCodeViewControllerLastVC() else { return }
        let securityCodeViewModel = viewModel.getPXSecurityCodeViewModel(isCallForAuth: true)

        let securityCodeVC = PXSecurityCodeViewController(
            viewModel: securityCodeViewModel,
            finishButtonAnimationCallback: { [weak self] in
                self?.executeNextStep()
            }, collectSecurityCodeCallback: { [weak self] cardInformation, securityCode in
                if let token = cardInformation as? PXToken {
                    self?.getTokenizationService(needToShowLoading: false).createCardToken(securityCode: securityCode, token: token)
                } else {
                    self?.getTokenizationService(needToShowLoading: false).createCardToken(securityCode: securityCode)
                }
            })
        viewModel.pxNavigationHandler.pushViewController(viewController: securityCodeVC, animated: true)
    }

    private func redirectAndFinish(viewModel: PXViewModelTrackingDataProtocol, redirectUrl: URL) {
        PXNewResultUtil.trackScreenAndConversion(viewModel: viewModel)
        PXNewResultUtil.openURL(url: redirectUrl, success: { [weak self] _ in
            guard let self = self else {
                return
            }
            if self.viewModel.pxNavigationHandler.isLoadingPresented() {
                self.viewModel.pxNavigationHandler.dismissLoading()
            }
            self.finish()
        })
    }

    func showPaymentResultScreen() {
        if viewModel.businessResult != nil {
            showBusinessResultScreen()
            return
        }

        if viewModel.paymentResult == nil, let payment = viewModel.payment {
            viewModel.paymentResult = PaymentResult(payment: payment, paymentData: viewModel.paymentData)
        }

        self.genericResultVM = viewModel.resultViewModel()
        guard let resultViewModel = self.genericResultVM else { return }
        if let url = resultViewModel.getRedirectUrl() {
            // If preference has a redirect URL for the current result status, perform redirect and finish checkout
            redirectAndFinish(viewModel: resultViewModel, redirectUrl: url)
            return
        }

        resultViewModel.setCallback(callback: { [weak self] congratsState, remedyText in
            guard let self = self else { return }
            switch congratsState {
            case .CALL_FOR_AUTH:
                if self.viewModel.remedy != nil {
                    // Update PaymentOptionSelected if needed
                    self.viewModel.updatePaymentOptionSelectedWithRemedy()
                    // CVV Remedy. Create new card token
                    self.viewModel.prepareForClone()
                    // Set readyToPay back to true. Otherwise it will go to Review and Confirm as at this moment we only has 1 payment option
                    self.viewModel.readyToPay = true
                } else {
                    self.viewModel.prepareForClone()
                }
                self.showSecurityCodeScreen()
            case .RETRY,
                 .SELECT_OTHER:
                if let changePaymentMethodAction = self.viewModel.lifecycleProtocol?.changePaymentMethodTapped?(),
                    congratsState == .SELECT_OTHER {
                    changePaymentMethodAction()
                } else {
                    self.viewModel.prepareForNewSelection()
                    self.executeNextStep()
                }
            case .RETRY_SECURITY_CODE:
                if let remedyText = remedyText, remedyText.isNotEmpty {
                    // Update PaymentOptionSelected if needed
                    self.viewModel.updatePaymentOptionSelectedWithRemedy()
                    // CVV Remedy. Create new card token
                    self.viewModel.prepareForClone()
                    // Set readyToPay back to true. Otherwise it will go to Review and Confirm as at this moment we only has 1 payment option
                    self.viewModel.readyToPay = true
                    // Set needToShowLoading to false so the button animation can be shown
                    self.getTokenizationService(needToShowLoading: false).createCardToken(securityCode: remedyText)
                } else {
                    self.finish()
                }
            case .RETRY_SILVER_BULLET:
                // Update PaymentOptionSelected if needed
                self.viewModel.updatePaymentOptionSelectedWithRemedy()
                // Silver Bullet remedy
                self.viewModel.prepareForClone()
                // Set readyToPay back to true. Otherwise it will go to Review and Confirm as at this moment we only has 1 payment option
                self.viewModel.readyToPay = true
                self.executeNextStep()
            case .DEEPLINK:
                if let remedyText = remedyText, remedyText.isNotEmpty {
                    PXDeepLinkManager.open(remedyText)
                }
                self.finish()
            default:
                self.finish()
            }
        })

        resultViewModel.toPaymentCongrats().start(using: viewModel.pxNavigationHandler) { [weak self] in
            // Remedy view has an animated button. This closure is called after the animation has finished
            self?.executeNextStep()
        }
    }

    func showBusinessResultScreen() {
        guard let businessResult = viewModel.businessResult else {
            return
        }

        var debinBankName: String?

        if businessResult.getPaymentMethodId() == PXPaymentMethodId.DEBIN.rawValue {
            let id = viewModel.paymentData.transactionInfo?.bankInfo?.accountId
            let paymentMethodId = viewModel.paymentData.paymentMethod?.id
            let paymentTypeId = viewModel.paymentData.paymentMethod?.paymentTypeId
            debinBankName = viewModel.search?.getPayerPaymentMethod(id: id, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId)?.bankInfo?.name
        }

        self.businessResultVM = PXBusinessResultViewModel(businessResult: businessResult,
                                                          paymentData: viewModel.paymentData,
                                                          amountHelper: viewModel.amountHelper,
                                                          pointsAndDiscounts: viewModel.pointsAndDiscounts,
                                                          debinBankName: debinBankName)

        guard let pxBusinessResultViewModel = self.businessResultVM else { return }

        pxBusinessResultViewModel.setCallback(callback: { [weak self] _, _ in
            self?.finish()
        })

        if let url = pxBusinessResultViewModel.getRedirectUrl() {
            // If preference has a redirect URL for the current result status, perform redirect and finish checkout
            redirectAndFinish(viewModel: pxBusinessResultViewModel, redirectUrl: url)
            return
        }

        pxBusinessResultViewModel.toPaymentCongrats().start(using: viewModel.pxNavigationHandler) { [weak self] in
            self?.finish()
        }
    }

    func showErrorScreen() {
        viewModel.pxNavigationHandler.showErrorScreen(error: MercadoPagoCheckoutViewModel.error, callbackCancel: finish, errorCallback: viewModel.errorCallback)
        MercadoPagoCheckoutViewModel.error = nil
    }

    func asyncRefreshInitFlow(cardId: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + InitFlowRefresh.retryDelay) { [weak self] in
            self?.refreshInitFlow(cardId: cardId)
        }
    }

    func startOneTapFlow() {
        guard let search = viewModel.search else { return }

        let paymentFlow = viewModel.createPaymentFlow(paymentErrorHandler: self)

        if viewModel.onetapFlow == nil {
            viewModel.onetapFlow = OneTapFlow(checkoutViewModel: viewModel, search: search, paymentOptionSelected: viewModel.paymentOptionSelected, oneTapResultHandler: self)
        } else {
            viewModel.onetapFlow?.update(checkoutViewModel: viewModel, search: search, paymentOptionSelected: viewModel.paymentOptionSelected)
        }

        guard let onetapFlow = viewModel.onetapFlow else {
            // onetapFlow shouldn't be nil by this point
            return
        }

        onetapFlow.setCustomerPaymentMethods(viewModel.customPaymentOptions)
        onetapFlow.setPaymentFlow(paymentFlow: paymentFlow)

        if shouldUpdateOnetapFlow() {
            onetapFlow.updateOneTapViewModel(cardId: InitFlowRefresh.cardId ?? "")
        } else {
            onetapFlow.start()
        }
        InitFlowRefresh.resetValues()
    }

    private func shouldUpdateOnetapFlow() -> Bool {
        if viewModel.onetapFlow != nil, cardIdExists() {
            return true
        }
        
        if viewModel.onetapFlow != nil, accountIdExists() {
            return true
        }
        // Card should not be updated or number of retries has reached max number
        return false
    }
    
    private func cardIdExists() -> Bool {
        if let cardId = InitFlowRefresh.cardId {
            return cardId.isNotEmpty
        }
        return false
    }
    
    private func accountIdExists() -> Bool {
        if let accountId = InitFlowRefresh.accountId {
            return accountId.isNotEmpty
        }
        return false
    }
}
