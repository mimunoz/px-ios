import Foundation

class TokenizationService {
    var paymentOptionSelected: PaymentMethodOption?
    var cardToken: PXCardToken?
    var pxNavigationHandler: PXNavigationHandler
    var needToShowLoading: Bool
    var mercadoPagoServices: MercadoPagoServices
    weak var resultHandler: TokenizationServiceResultHandler?
    var strategyTracking: StrategyTrackings = ImpletationStrategy()

    init(paymentOptionSelected: PaymentMethodOption?, cardToken: PXCardToken?, pxNavigationHandler: PXNavigationHandler, needToShowLoading: Bool, mercadoPagoServices: MercadoPagoServices, gatewayFlowResultHandler: TokenizationServiceResultHandler) {
        self.paymentOptionSelected = paymentOptionSelected
        self.pxNavigationHandler = pxNavigationHandler
        self.needToShowLoading = needToShowLoading
        self.mercadoPagoServices = mercadoPagoServices
        self.resultHandler = gatewayFlowResultHandler
        self.cardToken = cardToken
    }

    func createCardToken(securityCode: String? = nil, token: PXToken? = nil) {
        // Clone token
        if let token = token, token.canBeClone() {
            guard let securityCode = securityCode else {
                return
            }
            cloneCardToken(token: token, securityCode: securityCode)
            return
        }

        // New Card Token
        guard let cardInfo = paymentOptionSelected as? PXCardInformation else {
            createNewCardToken()
            return
        }

        // Saved card with esc token
        let requireESC = PXConfiguratorManager.escProtocol.hasESCEnable()
        if requireESC {
            var savedESCCardToken: PXSavedESCCardToken

            let esc = PXConfiguratorManager.escProtocol.getESC(config: PXConfiguratorManager.escConfig, cardId: cardInfo.getCardId(), firstSixDigits: cardInfo.getFirstSixDigits(), lastFourDigits: cardInfo.getCardLastForDigits())

            if !String.isNullOrEmpty(esc) {
                savedESCCardToken = PXSavedESCCardToken(cardId: cardInfo.getCardId(), esc: esc, requireESC: requireESC)
                trackCurrentStep("TokenizationService - createCardToken \(esc)")
            } else {
                savedESCCardToken = PXSavedESCCardToken(cardId: cardInfo.getCardId(), securityCode: securityCode, requireESC: requireESC)
                trackCurrentStep("TokenizationService - createCardToken")
            }
            createSavedESCCardToken(savedESCCardToken: savedESCCardToken)

        // Saved card token
        } else {
            guard let securityCode = securityCode else {
                return
            }
            createSavedCardToken(cardInformation: cardInfo, securityCode: securityCode)
            trackCurrentStep("TokenizationService - createCardToken - requireESC \(requireESC)")
        }
    }

    func createCardTokenWithoutCVV() {
        // New Card Token
        guard let cardInfo = paymentOptionSelected as? PXCardInformation else {
            createNewCardToken()
            return
        }

        let savedESCCardToken = PXSavedESCCardToken(cardId: cardInfo.getCardId(), securityCode: nil, requireESC: false)
        createSavedESCCardToken(savedESCCardToken: savedESCCardToken)
    }

    private func createNewCardToken() {
        guard let cardToken = cardToken else {
            return
        }
        pxNavigationHandler.presentLoading()

        mercadoPagoServices.createToken(cardToken: cardToken, callback: { token in
            self.resultHandler?.finishFlow(token: token, shouldResetESC: false)
        }, failure: { error in
            self.trackTokenApiError()
            let error = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue)
            if error.apiException?.containsCause(code: ApiUtil.ErrorCauseCodes.INVALID_IDENTIFICATION_NUMBER.rawValue) == true {
                self.resultHandler?.finishInvalidIdentificationNumber()
            } else {
                self.resultHandler?.finishWithError(error: error, securityCode: nil)
            }
        })
    }

    private func createSavedCardToken(cardInformation: PXCardInformation, securityCode: String) {
        guard let cardInformation = paymentOptionSelected as? PXCardInformation else {
            return
        }

        if needToShowLoading {
            self.pxNavigationHandler.presentLoading()
        }

        let saveCardToken = PXSavedCardToken(card: cardInformation, securityCode: securityCode, securityCodeRequired: true)

        mercadoPagoServices.createToken(savedCardToken: saveCardToken, callback: { token in
            if token.lastFourDigits.isEmpty {
                token.lastFourDigits = cardInformation.getCardLastForDigits()
            }
            self.resultHandler?.finishFlow(token: token, shouldResetESC: true)
        }, failure: { error in
            self.trackTokenApiError()
            let error = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue)
            self.resultHandler?.finishWithError(error: error, securityCode: securityCode)
        })
    }

    private func createSavedESCCardToken(savedESCCardToken: PXSavedESCCardToken) {
        if needToShowLoading {
            self.pxNavigationHandler.presentLoading()
        }

        mercadoPagoServices.createToken(savedESCCardToken: savedESCCardToken, callback: { token in
            if token.lastFourDigits.isEmpty {
                let cardInformation = self.paymentOptionSelected as? PXCardInformation
                token.lastFourDigits = cardInformation?.getCardLastForDigits() ?? ""
            }

            var shouldResetESC = false
            if let securityCode = savedESCCardToken.securityCode, securityCode.isNotEmpty {
                shouldResetESC = true
            }
            self.resultHandler?.finishFlow(token: token, shouldResetESC: shouldResetESC)
        }, failure: { error in
            self.trackTokenApiError()
            let error = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue)
            self.trackInvalidESC(error: error, cardId: savedESCCardToken.cardId, esc_length: savedESCCardToken.esc?.count)
            PXConfiguratorManager.escProtocol.deleteESC(config: PXConfiguratorManager.escConfig, cardId: savedESCCardToken.cardId, reason: .UNEXPECTED_TOKENIZATION_ERROR, detail: error.toJSONString())
            self.resultHandler?.finishWithESCError()
        })
    }

    private func cloneCardToken(token: PXToken, securityCode: String) {
        pxNavigationHandler.presentLoading()
        mercadoPagoServices.cloneToken(tokenId: token.id, securityCode: securityCode, callback: { token in
            self.resultHandler?.finishFlow(token: token, shouldResetESC: true)
        }, failure: { error in
            self.trackTokenApiError()
            let error = MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.CREATE_TOKEN.rawValue)
            self.resultHandler?.finishWithError(error: error, securityCode: securityCode)
        })
    }

    func resetESCCap(cardId: String, headers: [String: String]?, onCompletion: @escaping () -> Void) {
        mercadoPagoServices.resetESCCap(cardId: cardId, headers: headers, onCompletion: onCompletion)
    }
}

// MARK: Tracking
private extension TokenizationService {
    func trackTokenApiError() {
        if let securityCodeVC = pxNavigationHandler.navigationController.viewControllers.last as? PXSecurityCodeViewController {
            securityCodeVC.trackEvent(event: GeneralErrorTrackingEvents.error(
                securityCodeVC.viewModel.getFrictionProperties(path: TrackingPaths.Events.SecurityCode.getTokenFrictionPath(), id: "token_api_error"))
            )
        }
    }
}

extension TokenizationService {
    func trackCurrentStep(_ flow: String) {
        strategyTracking.getPropertieFlow(flow: flow)
    }
}
