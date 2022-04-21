import Foundation

final class OneTapFlow: NSObject, PXFlow {
    var model: OneTapFlowModel
    let pxNavigationHandler: PXNavigationHandler

    weak var resultHandler: PXOneTapResultHandlerProtocol?

    let advancedConfig: PXAdvancedConfiguration

    var strategyTrackings: StrategyTrackings = ImpletationStrategy()
    var isPaymentToggle = IsPaymentToggle.noPaying

    init(checkoutViewModel: MercadoPagoCheckoutViewModel, search: PXInitDTO, paymentOptionSelected: PaymentMethodOption?, oneTapResultHandler: PXOneTapResultHandlerProtocol) {
        pxNavigationHandler = checkoutViewModel.pxNavigationHandler
        resultHandler = oneTapResultHandler
        advancedConfig = checkoutViewModel.getAdvancedConfiguration()
        model = OneTapFlowModel(checkoutViewModel: checkoutViewModel, search: search, paymentOptionSelected: paymentOptionSelected)
        super.init()
        model.oneTapFlow = self
    }

    func update(checkoutViewModel: MercadoPagoCheckoutViewModel, search: PXInitDTO, paymentOptionSelected: PaymentMethodOption?) {
        model = OneTapFlowModel(checkoutViewModel: checkoutViewModel, search: search, paymentOptionSelected: paymentOptionSelected)
        model.oneTapFlow = self
    }

    deinit {
        #if DEBUG
        print("DEINIT FLOW - \(self)")
        #endif
    }

    func setPaymentFlow(paymentFlow: PXPaymentFlow) {
        model.paymentFlow = paymentFlow
    }

    func start() {
        executeNextStep()
    }

    func executeNextStep() {
        DispatchQueue.main.async {
            let result = self.model.nextStep()
            self.strategyTrackings.getPropertieFlow(flow: result.rawValue)

            switch result {
            case .screenOneTap:
                self.showOneTapViewController()
            case .screenSecurityCode:
                self.showSecurityCodeScreen()
            case .serviceCreateOptionalToken:
                self.getTokenizationService().createCardTokenWithoutCVV()
            case .serviceCreateESCCardToken:
                self.getTokenizationService().createCardToken()
            case .serviceCreateWebPayCardToken:
                self.getTokenizationService().createCardToken(securityCode: "")
            case .screenKyC:
                self.showKyCScreen()
            case .service3DS:
                guard let program = self.model.getProgramValidation(), let cardHolderName = self.model.getCardHolderName() else { return }
                self.getThreeDSService().authorize3DS(programUsed: program, cardHolderName: cardHolderName)
            case .payment:
                self.startPaymentFlow()
            case .finish:
                self.finishFlow()
            }
        }
    }

    func refreshInitFlow(cardId: String) {
        resultHandler?.refreshInitFlow(cardId: cardId)
    }

    // Cancel one tap and go to checkout
    func cancelFlow() {
        model.search.deleteCheckoutDefaultOption()
        resultHandler?.cancelOneTap()
    }

    // Cancel one tap and go to checkout
    func cancelFlowForNewPaymentSelection() {
        model.search.deleteCheckoutDefaultOption()
        resultHandler?.cancelOneTapForNewPaymentMethodSelection()
    }

    // Finish one tap and continue with checkout
    func finishFlow() {
        if let paymentResult = model.paymentResult {
            resultHandler?.finishOneTap(paymentResult: paymentResult, instructionsInfo: model.instructionsInfo, pointsAndDiscounts: model.pointsAndDiscounts, paymentOptionSelected: model.paymentOptionSelected)
        } else if let businessResult = model.businessResult {
            resultHandler?.finishOneTap(businessResult: businessResult, paymentData: model.paymentData, splitAccountMoney: model.splitAccountMoney, pointsAndDiscounts: model.pointsAndDiscounts)
        } else {
            resultHandler?.finishOneTap(paymentData: model.paymentData, splitAccountMoney: model.splitAccountMoney, pointsAndDiscounts: model.pointsAndDiscounts)
        }
    }

    // Exit checkout
    func exitCheckout() {
        resultHandler?.exitCheckout()
    }

    func setCustomerPaymentMethods(_ customPaymentMethods: [CustomerPaymentMethod]?) {
        model.customerPaymentOptions = customPaymentMethods
    }

    func needSecurityCodeValidation() -> Bool {
        model.readyToPay = true
        return model.nextStep() == .screenSecurityCode
    }

    func isPXSecurityCodeViewControllerLastVC() -> Bool {
        return pxNavigationHandler.navigationController.viewControllers.last is PXSecurityCodeViewController
    }
}

extension OneTapFlow {
    /// Returns a auto selected payment option from a paymentMethodSearch object. If no option can be selected it returns nil
    ///
    /// - Parameters:
    ///   - search: payment method search item
    /// - Returns: selected payment option if possible
    static func autoSelectOneTapOption(search: PXInitDTO, customPaymentOptions: [CustomerPaymentMethod]?, amountHelper: PXAmountHelper) -> PaymentMethodOption? {
        var selectedPaymentOption: PaymentMethodOption?
        if search.hasCheckoutDefaultOption() {
            // Check if can autoselect customer card
            guard let customerPaymentMethods = customPaymentOptions else {
                return nil
            }

            if let suggestedAccountMoney = search.oneTap?.first?.accountMoney {
                selectedPaymentOption = suggestedAccountMoney
            } else if let oneTapDto = search.oneTap?.first {
                let customOptionsFound = customerPaymentMethods.filter {
                    if let oneTapCard = oneTapDto.oneTapCard {
                        return $0.getCardId() == oneTapCard.cardId && $0.getPaymentMethodId() == oneTapDto.paymentMethodId && $0.getPaymentType() == oneTapDto.paymentTypeId
                    }
                    return $0.getPaymentMethodId() == oneTapDto.paymentMethodId && $0.getPaymentType() == oneTapDto.paymentTypeId
                }
                if let customerPaymentMethod = customOptionsFound.first {
                    // Check if one tap response has payer costs
                    if let expressNode = search.getPaymentMethodInExpressCheckout(customerPaymentMethod: customerPaymentMethod),
                       let selected = selectPaymentMethod(expressNode: expressNode, customerPaymentMethod: customerPaymentMethod, amountHelper: amountHelper) {
                        selectedPaymentOption = selected
                    }
                }
            }
        }
        return selectedPaymentOption
    }

    static func selectPaymentMethod(expressNode: PXOneTapDto, customerPaymentMethod: CustomerPaymentMethod, amountHelper: PXAmountHelper) -> PaymentMethodOption? {
        // payment method id and payment type id must coincide between the express node and the customer payment method to continue
        if expressNode.paymentMethodId != customerPaymentMethod.getPaymentMethodId() ||
            expressNode.paymentTypeId != customerPaymentMethod.getPaymentTypeId() {
            return nil
        }

        var selectedPaymentOption: PaymentMethodOption?
        // the selected payment option is a one tap card, therefore has the required node and has related payer costs
        if let expressPaymentMethod = expressNode.oneTapCard, amountHelper.paymentConfigurationService.getSelectedPayerCostsForPaymentMethod(paymentOptionID: expressPaymentMethod.cardId, paymentMethodId: expressNode.paymentMethodId, paymentTypeId: expressNode.paymentTypeId) != nil {
            selectedPaymentOption = customerPaymentMethod
        }

        // the selected payment option is the credits option
        if expressNode.oneTapCreditsInfo != nil {
            selectedPaymentOption = customerPaymentMethod
        }
        return selectedPaymentOption
    }

    func getCustomerPaymentMethodOption(cardId: String, paymentMethodType: String) -> PaymentMethodOption? {
        guard let customerPaymentMethods = model.customerPaymentOptions else {
            return nil
        }
        return customerPaymentMethods.first(where: { $0.getCardId() == cardId && $0.getPaymentType() == paymentMethodType })
    }
}
