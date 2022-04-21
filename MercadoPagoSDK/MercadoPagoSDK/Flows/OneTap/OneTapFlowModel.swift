import Foundation

final class OneTapFlowModel: PXFlowModel {
    enum Steps: String {
        case finish
        case screenOneTap
        case screenSecurityCode
        case serviceCreateOptionalToken
        case serviceCreateESCCardToken
        case serviceCreateWebPayCardToken
        case screenKyC
        case service3DS
        case payment
        case returnSelectedPaymentMethod
    }
    var hasPostPaymentFlow = false
    var publicKey: String = ""
    var privateKey: String?
    var siteId: String = ""
    var paymentData: PXPaymentData
    let checkoutPreference: PXCheckoutPreference
    var paymentOptionSelected: PaymentMethodOption?
    let search: PXInitDTO
    var threeDSAuthorization: Bool = false
    var readyToPay: Bool = false
    var paymentResult: PaymentResult?
    var instructionsInfo: PXInstruction?
    var pointsAndDiscounts: PXPointsAndDiscounts?
    var businessResult: PXBusinessResult?
    var customerPaymentOptions: [CustomerPaymentMethod]?
    var splitAccountMoney: PXPaymentData?
    var disabledOption: PXDisabledOption?
    var pxOneTapViewModel: PXOneTapViewModel?

    var justReturnSelectedPaymentMethod: Bool = false

    // MARK: - Private properties
    private var didCall3ds = false

    // Payment flow
    var paymentFlow: PXPaymentFlow?
    weak var paymentResultHandler: PXPaymentResultHandlerProtocol?

    // One Tap Flow
    weak var oneTapFlow: OneTapFlow?

    var chargeRules: [PXPaymentTypeChargeRule]?

    var invalidESCReason: PXESCDeleteReason?

    // In order to ensure data updated create new instance for every usage
    var amountHelper: PXAmountHelper {
        return PXAmountHelper(preference: self.checkoutPreference, paymentData: self.paymentData, chargeRules: chargeRules, paymentConfigurationService: self.paymentConfigurationService, splitAccountMoney: splitAccountMoney)
    }

    let advancedConfiguration: PXAdvancedConfiguration
    let mercadoPagoServices: MercadoPagoServices
    let paymentConfigurationService: PXPaymentConfigurationServices

    init(checkoutViewModel: MercadoPagoCheckoutViewModel, search: PXInitDTO, paymentOptionSelected: PaymentMethodOption?) {
        hasPostPaymentFlow = checkoutViewModel.postPaymentNotificationName != nil
        publicKey = checkoutViewModel.publicKey
        privateKey = checkoutViewModel.privateKey
        siteId = checkoutViewModel.search?.site.id ?? ""
        paymentData = checkoutViewModel.paymentData.copy() as? PXPaymentData ?? checkoutViewModel.paymentData
        checkoutPreference = checkoutViewModel.checkoutPreference
        self.search = search
        self.paymentOptionSelected = paymentOptionSelected
        advancedConfiguration = checkoutViewModel.getAdvancedConfiguration()
        mercadoPagoServices = checkoutViewModel.mercadoPagoServices
        paymentConfigurationService = checkoutViewModel.paymentConfigurationService
        disabledOption = checkoutViewModel.disabledOption

        // Process custom charges and charge rules

        var mergedChargeRules: [PXPaymentTypeChargeRule] = []

        if let customCharges = search.customCharges {
            // If there is custom charges iterate each one
            customCharges.keys.forEach { customChargeKey in
                if let customCharge = customCharges[customChargeKey] as? PXCustomCharge {
                    if let chargeRule = checkoutViewModel.chargeRules?.first(where: { chargeRule -> Bool in
                        return chargeRule.paymentTypeId == customChargeKey
                    }) {
                        var newChargeRule: PXPaymentTypeChargeRule
                        // If a chargeRule for this custom charge already exists, then override its properties
                        if let detailModal = chargeRule.detailModal {
                            // If the chargeRule has detailModal, create the new one using the modal
                            newChargeRule = PXPaymentTypeChargeRule(paymentTypeId: chargeRule.paymentTypeId, amountCharge: customCharge.charge, detailModal: detailModal)
                        } else if let message = chargeRule.message, customCharge.charge == 0 {
                            // If the chargeRule has message and the customCharge charge is still 0, use the message
                            newChargeRule = PXPaymentTypeChargeRule(paymentTypeId: chargeRule.paymentTypeId, message: message)
                        } else {
                            // If the original chargeRule don't have detailModal nor message use the basic init
                            newChargeRule = PXPaymentTypeChargeRule(paymentTypeId: chargeRule.paymentTypeId, amountCharge: customCharge.charge)
                        }

                        if let label = customCharge.label {
                            newChargeRule.label = label
                        }

                        mergedChargeRules.append(newChargeRule)
                    } else {
                        // If there isn't a chargeRule for this customCharge then create one and add it to the mergedChargeRules array
                        var newChargeRule = PXPaymentTypeChargeRule(paymentTypeId: customChargeKey, amountCharge: customCharge.charge)

                        if let label = customCharge.label {
                            newChargeRule.label = label
                        }

                        mergedChargeRules.append(newChargeRule)
                    }
                }
            }
            self.chargeRules = mergedChargeRules
            checkoutViewModel.chargeRules = mergedChargeRules
        } else {
            // TODO: Remove when IDC is fully implemented
            // If customCharges is nil then use the integrator provided chargeRules
            self.chargeRules = checkoutViewModel.chargeRules
        }

        // Payer cost pre selection.
        let firstOneTapItem = search.oneTap?.first
        let paymentMethodId = firstOneTapItem?.paymentMethodId
        let paymentTypeId = firstOneTapItem?.paymentTypeId
        let firstCardID = firstOneTapItem?.oneTapCard?.cardId
        let creditsCase = paymentMethodId == PXPaymentTypes.CONSUMER_CREDITS.rawValue
        let cardCase = firstCardID != nil

        if cardCase || creditsCase {
            if let pmIdentifier = cardCase ? firstCardID : paymentMethodId,
                let payerCost = amountHelper.paymentConfigurationService.getSelectedPayerCostsForPaymentMethod(paymentOptionID: pmIdentifier, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) {
                updateCheckoutModel(payerCost: payerCost)
            }
        }
    }

    // MARK: Init with PXPaymentMethodSelectorViewModel
    init(paymentMethodSelectorViewModel: PXPaymentMethodSelectorViewModel, search: PXInitDTO, paymentOptionSelected: PaymentMethodOption?) {
        justReturnSelectedPaymentMethod = true
        hasPostPaymentFlow = false
        publicKey = paymentMethodSelectorViewModel.publicKey
        privateKey = paymentMethodSelectorViewModel.accessToken
        siteId = paymentMethodSelectorViewModel.search?.site.id ?? ""
        paymentData = paymentMethodSelectorViewModel.paymentData.copy() as? PXPaymentData ?? paymentMethodSelectorViewModel.paymentData
        checkoutPreference = paymentMethodSelectorViewModel.checkoutPreference
        self.search = search
        self.paymentOptionSelected = paymentOptionSelected
        advancedConfiguration = paymentMethodSelectorViewModel.getAdvancedConfiguration()
        mercadoPagoServices = paymentMethodSelectorViewModel.mercadoPagoServices
        paymentConfigurationService = paymentMethodSelectorViewModel.paymentConfigurationService
        disabledOption = paymentMethodSelectorViewModel.disabledOption

        // Process custom charges and charge rules

        var mergedChargeRules: [PXPaymentTypeChargeRule] = []

        if let customCharges = search.customCharges {
            // If there is custom charges iterate each one
            customCharges.keys.forEach { customChargeKey in
                if let customCharge = customCharges[customChargeKey] as? PXCustomCharge {
                    if let chargeRule = paymentMethodSelectorViewModel.chargeRules?.first(where: { chargeRule -> Bool in
                        return chargeRule.paymentTypeId == customChargeKey
                    }) {
                        var newChargeRule: PXPaymentTypeChargeRule
                        // If a chargeRule for this custom charge already exists, then override its properties
                        if let detailModal = chargeRule.detailModal {
                            // If the chargeRule has detailModal, create the new one using the modal
                            newChargeRule = PXPaymentTypeChargeRule(paymentTypeId: chargeRule.paymentTypeId, amountCharge: customCharge.charge, detailModal: detailModal)
                        } else if let message = chargeRule.message, customCharge.charge == 0 {
                            // If the chargeRule has message and the customCharge charge is still 0, use the message
                            newChargeRule = PXPaymentTypeChargeRule(paymentTypeId: chargeRule.paymentTypeId, message: message)
                        } else {
                            // If the original chargeRule don't have detailModal nor message use the basic init
                            newChargeRule = PXPaymentTypeChargeRule(paymentTypeId: chargeRule.paymentTypeId, amountCharge: customCharge.charge)
                        }

                        if let label = customCharge.label {
                            newChargeRule.label = label
                        }

                        mergedChargeRules.append(newChargeRule)
                    } else {
                        // If there isn't a chargeRule for this customCharge then create one and add it to the mergedChargeRules array
                        var newChargeRule = PXPaymentTypeChargeRule(paymentTypeId: customChargeKey, amountCharge: customCharge.charge)

                        if let label = customCharge.label {
                            newChargeRule.label = label
                        }

                        mergedChargeRules.append(newChargeRule)
                    }
                }
            }
            self.chargeRules = mergedChargeRules
            paymentMethodSelectorViewModel.chargeRules = mergedChargeRules
        } else {
            // TODO: Remove when IDC is fully implemented
            // If customCharges is nil then use the integrator provided chargeRules
            self.chargeRules = paymentMethodSelectorViewModel.chargeRules
        }

        // Payer cost pre selection.
        let firstOneTapItem = search.oneTap?.first
        let paymentMethodId = firstOneTapItem?.paymentMethodId
        let paymentTypeId = firstOneTapItem?.paymentTypeId
        let firstCardID = firstOneTapItem?.oneTapCard?.cardId
        let creditsCase = paymentMethodId == PXPaymentTypes.CONSUMER_CREDITS.rawValue
        let cardCase = firstCardID != nil

        if cardCase || creditsCase {
            if let pmIdentifier = cardCase ? firstCardID : paymentMethodId,
                let payerCost = amountHelper.paymentConfigurationService.getSelectedPayerCostsForPaymentMethod(paymentOptionID: pmIdentifier, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) {
                updateCheckoutModel(payerCost: payerCost)
            }
        }
    }

    public func nextStep() -> Steps {
        if needShowOneTap() { return .screenOneTap }
        if needSecurityCode() { return .screenSecurityCode }
        if needCreateOptionalToken() { return .serviceCreateOptionalToken }
        if needCreateESCToken() { return .serviceCreateESCCardToken }
        if needCreateWebPayToken() { return .serviceCreateWebPayCardToken }
        if needKyC() { return .screenKyC }
        if need3DS() { return .service3DS }
        if needCreatePayment() { return .payment }
        if needToReturnSelectedPaymentMethod() { return .returnSelectedPaymentMethod }
        return .finish
    }
}

// MARK: Create view model
extension OneTapFlowModel {
    func savedCardSecurityCodeViewModel() -> PXSecurityCodeViewModel {
        guard let cardInformation = self.paymentOptionSelected as? PXCardInformation else {
            fatalError("Cannot convert payment option selected to CardInformation")
        }

        guard let paymentMethod = paymentData.paymentMethod else {
            fatalError("Don't have paymentData to open Security View Controller")
        }

        let reason = PXSecurityCodeViewModel.getSecurityCodeReason(invalidESCReason: invalidESCReason)
        let cardSliderViewModel = pxOneTapViewModel?.getCardSliderViewModel(cardId: paymentOptionSelected?.getId())
        let cardUI = cardSliderViewModel?.cardUI ?? TemplateCard()
        let cardData = cardSliderViewModel?.selectedApplication?.cardData ?? PXCardDataFactory()

        return PXSecurityCodeViewModel(paymentMethod: paymentMethod, cardInfo: cardInformation, reason: reason, cardUI: cardUI, cardData: cardData, internetProtocol: mercadoPagoServices)
    }

    func oneTapViewModel() -> PXOneTapViewModel {
        let viewModel = PXOneTapViewModel(amountHelper: amountHelper, paymentOptionSelected: paymentOptionSelected, advancedConfig: advancedConfiguration, userLogged: false, disabledOption: disabledOption, currentFlow: oneTapFlow, payerPaymentMethods: search.payerPaymentMethods, experiments: search.experiments)
        viewModel.publicKey = publicKey
        viewModel.privateKey = privateKey
        viewModel.siteId = siteId
        viewModel.excludedPaymentTypeIds = checkoutPreference.getExcludedPaymentTypesIds()
        viewModel.expressData = search.oneTap
        viewModel.payerCompliance = search.payerCompliance
        viewModel.paymentMethods = search.availablePaymentMethods
        viewModel.items = checkoutPreference.items
        viewModel.additionalInfoSummary = checkoutPreference.pxAdditionalInfo?.pxSummary
        viewModel.modals = search.modals
        return viewModel
    }
}

// MARK: Update view models
extension OneTapFlowModel {
    func updateCheckoutModel(paymentData: PXPaymentData, splitAccountMoneyEnabled: Bool) {
        self.paymentData = paymentData

        if splitAccountMoneyEnabled,
           let paymentOptionSelected = paymentOptionSelected {
            let splitConfiguration = amountHelper.paymentConfigurationService.getSplitConfigurationForPaymentMethod(paymentOptionID: paymentOptionSelected.getId(), paymentMethodId: paymentData.paymentMethod?.id, paymentTypeId: paymentOptionSelected.getPaymentType())

            // Set total amount to pay with card without discount
            paymentData.transactionAmount = PXAmountHelper.getRoundedAmountAsNsDecimalNumber(amount: splitConfiguration?.primaryPaymentMethod?.amount)

            let accountMoneyPMs = search.availablePaymentMethods.filter { paymentMethod -> Bool in
                return paymentMethod.id == splitConfiguration?.secondaryPaymentMethod?.id
            }
            if let accountMoneyPM = accountMoneyPMs.first {
                splitAccountMoney = PXPaymentData()
                // Set total amount to pay with account money without discount
                splitAccountMoney?.transactionAmount = PXAmountHelper.getRoundedAmountAsNsDecimalNumber(amount: splitConfiguration?.secondaryPaymentMethod?.amount)
                splitAccountMoney?.updatePaymentDataWith(paymentMethod: accountMoneyPM)

                let discountConfiguration = amountHelper.paymentConfigurationService.getDiscountConfigurationForPaymentMethodOrDefault(paymentOptionID: paymentOptionSelected.getId(), paymentMethodId: paymentData.paymentMethod?.id, paymentTypeId: paymentOptionSelected.getPaymentType())
                let campaign = discountConfiguration?.getDiscountConfiguration().campaign
                let isDiscountAvailable = discountConfiguration?.getDiscountConfiguration().isAvailable
                if let discount = splitConfiguration?.primaryPaymentMethod?.discount, let campaign = campaign, let isDiscountAvailable = isDiscountAvailable {
                    paymentData.setDiscount(discount, withCampaign: campaign, consumedDiscount: !isDiscountAvailable)
                }
                if let discount = splitConfiguration?.secondaryPaymentMethod?.discount, let campaign = campaign, let isDiscountAvailable = isDiscountAvailable {
                    splitAccountMoney?.setDiscount(discount, withCampaign: campaign, consumedDiscount: !isDiscountAvailable)
                }
            }
        } else {
            splitAccountMoney = nil
        }

        self.readyToPay = true
    }

    func updateCheckoutModel(token: PXToken) {
        self.paymentData.updatePaymentDataWith(token: token)
    }

    func updateCheckoutModel(threeDSAuthorization: Bool) {
        self.threeDSAuthorization = threeDSAuthorization
    }

    func updateCheckoutModel(payerCost: PXPayerCost) {
        guard let paymentOptionSelected = paymentOptionSelected else {
            return
        }

        let isCredits = paymentOptionSelected.getId() == PXPaymentTypes.CONSUMER_CREDITS.rawValue
        if paymentOptionSelected.isCard() || isCredits {
            self.paymentData.updatePaymentDataWith(payerCost: payerCost)
            self.paymentData.cleanToken()
        }
    }
}

// MARK: Flow logic
extension OneTapFlowModel {
    func needShowOneTap() -> Bool {
        if readyToPay {
            return false
        }

        return true
    }

    func needSecurityCode() -> Bool {
        guard let paymentMethod = self.paymentData.getPaymentMethod() else {
            return false
        }

        guard let paymentOptionSelected = paymentOptionSelected else {
            return false
        }

        if !readyToPay {
            return false
        }

        let hasInstallmentsIfNeeded = paymentData.hasPayerCost() || !paymentMethod.isCreditCard
        let paymentOptionSelectedId = paymentData.paymentMethod?.id == PXPaymentMethodId.DEBIN.rawValue ? paymentData.transactionInfo?.bankInfo?.accountId : paymentOptionSelected.getId()
        let isCustomerCard = paymentOptionSelected.isCustomerPaymentMethod() && paymentOptionSelectedId != PXPaymentTypes.ACCOUNT_MONEY.rawValue && paymentOptionSelectedId != PXPaymentTypes.CONSUMER_CREDITS.rawValue
        // Debit cards in Chile created by webpay return 0 security code length and shouldn't ask for CVV

        if isCustomerCard &&
            !paymentData.hasToken() &&
            hasInstallmentsIfNeeded &&
            hasSecurityCode(),
            search.oneTap?.first(where: { $0.oneTapCard?.cardId == paymentOptionSelected.getId() })?.oneTapCard?.cardUI?.securityCode?.mode == .mandatory {
            var paymentMethodId: String?
            if let cardInformation = paymentOptionSelected as? PXCardInformation {
                paymentMethodId = cardInformation.getPaymentMethodId()
            }
            if let customOptionSearchItem = search.getPayerPaymentMethod(id: paymentOptionSelectedId, paymentMethodId: paymentMethodId, paymentTypeId: paymentOptionSelected.getPaymentType()) {
                if hasSavedESC() {
                    if customOptionSearchItem.escStatus == PXESCStatus.REJECTED.rawValue {
                        invalidESCReason = .ESC_CAP
                        return true
                    } else {
                        return false
                    }
                } else {
                    return true
                }
            } else {
                return true
            }
        }
        return false
    }

    func needCreateESCToken() -> Bool {
        guard let paymentMethod = self.paymentData.getPaymentMethod() else {
            return false
        }

        let hasInstallmentsIfNeeded = self.paymentData.getPayerCost() != nil || !paymentMethod.isCreditCard
        let savedCardWithESC = !paymentData.hasToken() && paymentMethod.isCard && hasSavedESC() && hasInstallmentsIfNeeded

        return savedCardWithESC
    }

    func needCreateOptionalToken() -> Bool {
        guard let paymentMethod = self.paymentData.getPaymentMethod(),
                let paymentOptionSelected = paymentOptionSelected,
                readyToPay,
                !paymentData.hasToken() else {
          return false
        }

        let hasInstallmentsIfNeeded = paymentData.hasPayerCost() || !paymentMethod.isCreditCard
        let paymentOptionSelectedId = paymentOptionSelected.getId()
        let isCustomerCard = paymentOptionSelected.isCustomerPaymentMethod() && paymentOptionSelectedId != PXPaymentTypes.ACCOUNT_MONEY.rawValue && paymentOptionSelectedId != PXPaymentTypes.CONSUMER_CREDITS.rawValue

        if isCustomerCard &&
            !paymentData.hasToken() &&
            hasInstallmentsIfNeeded &&
            hasSecurityCode(),
           search.oneTap?.first(where: { $0.oneTapCard?.cardId == paymentOptionSelected.getId() })?.oneTapCard?.cardUI?.securityCode?.mode == .optional {
            return true
        }

        return false
    }

    func needCreateWebPayToken() -> Bool {
        guard let paymentMethod = self.paymentData.getPaymentMethod(),
              !hasSecurityCode() else {
            return false
        }

        let needToCreateWebPayToken = !paymentData.hasToken() && paymentMethod.isCard

        return needToCreateWebPayToken
    }

    func needKyC() -> Bool {
        return !(search.payerCompliance?.offlineMethods.isCompliant ?? true) && paymentOptionSelected?.additionalInfoNeeded?() ?? false
    }

    func need3DS() -> Bool {
        if getProgramValidation() == "stp", didCall3ds == false {
            didCall3ds = true
            return true
        }

        return false
    }

    func getProgramValidation() -> String? {
        return search.oneTap?.first(where: { $0.oneTapCard?.cardId == paymentOptionSelected?.getId() })?.applications?.first(where: { $0.paymentMethod.id == pxOneTapViewModel?.getCardSliderViewModel(cardId: paymentOptionSelected?.getId())?.selectedApplication?.paymentMethodId })?.validationPrograms?.first?.id
    }

    func getCardHolderName() -> String? {
        return search.oneTap?.first(where: { $0.oneTapCard?.cardId == paymentOptionSelected?.getId() })?.oneTapCard?.cardUI?.name
    }

    func needCreatePayment() -> Bool {
        if !readyToPay {
            return false
        }

        if justReturnSelectedPaymentMethod {
            return false
        }

        return paymentData.isComplete(shouldCheckForToken: false) && paymentFlow != nil && paymentResult == nil && businessResult == nil
    }

    func needToReturnSelectedPaymentMethod () -> Bool {
        if !justReturnSelectedPaymentMethod {
            return false
        }

        return paymentData.isComplete(shouldCheckForToken: false)
    }

    func hasSavedESC() -> Bool {
        if let card = paymentOptionSelected as? PXCardInformation {
            return PXConfiguratorManager.escProtocol.getESC(config: PXConfiguratorManager.escConfig, cardId: card.getCardId(), firstSixDigits: card.getFirstSixDigits(), lastFourDigits: card.getCardLastForDigits()) == nil ? false : true
        }
        return false
    }

    func needToShowLoading() -> Bool {
        guard let paymentMethod = paymentData.getPaymentMethod() else {
            return true
        }
        if let paymentFlow = paymentFlow, paymentMethod.isAccountMoney || hasSavedESC() {
            return paymentFlow.hasPaymentPluginScreen()
        }
        // Debit cards in Chile created by webpay should tokenize and pay whithout loading screen
        return hasSecurityCode()
    }

    func getTimeoutForOneTapReviewController() -> TimeInterval {
        if let paymentFlow = paymentFlow {
            paymentFlow.model.amountHelper = amountHelper
            let tokenTimeOut: TimeInterval = mercadoPagoServices.getTimeOut()
            // Payment Flow timeout + tokenization TimeOut
            return paymentFlow.getPaymentTimeOut() + tokenTimeOut
        } else {
            // Just tokenization timeout
            return mercadoPagoServices.getTimeOut()
        }
        return 0
    }

    func getKyCDeepLink() -> String? {
        return search.payerCompliance?.offlineMethods.turnComplianceDeepLink
    }

    func hasSecurityCode() -> Bool {
        guard let paymentOptionSelected = paymentOptionSelected,
              let cardInformation = paymentOptionSelected as? PXCardInformation,
              let paymentMethod = paymentData.paymentMethod,
              cardInformation.getPaymentMethodId() == paymentMethod.getId() else {
            return false
        }
        cardInformation.setupPaymentMethodSettings(paymentMethod.settings)
        // Debit cards in Chile created by webpay return 0 security code length
        let hasSecurityCode = cardInformation.getCardSecurityCode()?.length ?? 1 > 0
        return hasSecurityCode
    }
}
