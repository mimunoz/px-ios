import Foundation

class PXPaymentMethodSelectorViewModel {
    var errorCallback: (() -> Void)?

    var checkoutPreference: PXCheckoutPreference
    var publicKey: String
    var accessToken: String?

    private var advancedConfig: PXAdvancedConfiguration = PXAdvancedConfiguration()

    var trackingConfiguration: PXTrackingConfiguration?

    weak var delegate: PXPaymentMethodSelectorDelegate?

    var selectedPaymentMethodId: String?

    var pxNavigationHandler: PXNavigationHandler = PXNavigationHandler.getDefault()

    // Init Flow
    var initFlow: InitFlow?
    weak var initFlowProtocol: InitFlowProtocol?

    var search: PXInitDTO?

    static var error: MPSDKError?

    var mercadoPagoServices: MercadoPagoServices

    var readyToPay: Bool = false
    var initWithPaymentData = false
    private var checkoutComplete = false

    var cardToken: PXCardToken?

    var paymentData = PXPaymentData()
    var splitAccountMoney: PXPaymentData?
    var disabledOption: PXDisabledOption?
    open var payerCosts: [PXPayerCost]?
    @available(*, deprecated, message: "No longer used")
    open var issuers: [PXIssuer]?
    open var entityTypes: [EntityType]?
    open var financialInstitutions: [PXFinancialInstitution]?
    open var instructionsInfo: PXInstruction?

    // Payment methods disponibles en selección de medio de pago
    var paymentMethodOptions: [PaymentMethodOption]?
    var paymentOptionSelected: PaymentMethodOption?
    // Payment method disponibles correspondientes a las opciones que se muestran en selección de medio de pago
    var availablePaymentMethods: [PXPaymentMethod]?

    var rootPaymentMethodOptions: [PaymentMethodOption]?

    // Discount and charges
    var chargeRules: [PXPaymentTypeChargeRule]?

    var customPaymentOptions: [CustomerPaymentMethod]?

    // OneTap Flow
    var onetapFlow: OneTapFlow?

    // Discounts bussines service.
    var paymentConfigurationService = PXPaymentConfigurationServices()

    // In order to ensure data updated create new instance for every usage
    var amountHelper: PXAmountHelper {
        guard let paymentData = paymentData.copy() as? PXPaymentData else {
            fatalError("Cannot find payment data")
        }

        return PXAmountHelper(preference: checkoutPreference, paymentData: paymentData, chargeRules: chargeRules, paymentConfigurationService: paymentConfigurationService, splitAccountMoney: splitAccountMoney)
    }

    func setNavigationHandler(handler: PXNavigationHandler) {
        pxNavigationHandler = handler
    }

    func clean() {
        initFlow = nil
        onetapFlow = nil
    }

    func getSelectedPaymentMethod() -> String? {
        return selectedPaymentMethodId
    }

    // Returns list with all cards ids with esc
    func getCardsIdsWithESC() -> [String] {
        guard let customPaymentOptions = customPaymentOptions else { return [] }
        let savedCardIds = PXConfiguratorManager.escProtocol.getSavedCardIds(config: PXConfiguratorManager.escConfig)
        return customPaymentOptions
        .filter { $0.containsSavedId(savedCardIds) }
        .filter { PXConfiguratorManager.escProtocol.getESC(config: PXConfiguratorManager.escConfig,
                                                           cardId: $0.getCardId(),
                                                           firstSixDigits: $0.getFirstSixDigits(),
                                                           lastFourDigits: $0.getCardLastForDigits()) != nil
        }
        .map { $0.getCardId() }
    }

    func getAdvancedConfiguration() -> PXAdvancedConfiguration {
        return advancedConfig
    }

    func updateCustomTexts() {
        // If AdditionalInfo has custom texts override the ones set by MercadoPagoCheckoutBuilder
        if let customTexts = checkoutPreference.pxAdditionalInfo?.pxCustomTexts {
            if let translation = customTexts.payButton {
                Localizator.sharedInstance.addCustomTranslation(.pay_button, translation)
            }
            if let translation = customTexts.payButtonProgress {
                Localizator.sharedInstance.addCustomTranslation(.pay_button_progress, translation)
            }
            if let translation = customTexts.totalDescription {
                Localizator.sharedInstance.addCustomTranslation(.total_to_pay_onetap, translation)
            }
        }
    }

    func getPaymentOptionConfigurations(paymentMethodSearch: PXInitDTO) -> Set<PXPaymentMethodConfiguration> {
        let discountConfigurationsKeys = paymentMethodSearch.coupons.keys
        var configurations = Set<PXPaymentMethodConfiguration>()
        for customOption in paymentMethodSearch.payerPaymentMethods {
            var paymentOptionConfigurations = [PXPaymentOptionConfiguration]()
            for key in discountConfigurationsKeys {
                guard let discountConfiguration = paymentMethodSearch.coupons[key], let payerCostConfiguration = customOption.paymentOptions?[key] else {
                    continue
                }
                let paymentOptionConfiguration = PXPaymentOptionConfiguration(id: key, discountConfiguration: discountConfiguration, payerCostConfiguration: payerCostConfiguration)
                paymentOptionConfigurations.append(paymentOptionConfiguration)
            }
            let paymentMethodConfiguration = PXPaymentMethodConfiguration(customOptionSearchItem: customOption, paymentOptionsConfigurations: paymentOptionConfigurations)
            configurations.insert(paymentMethodConfiguration)
        }
        return configurations
    }

    public func updateCheckoutModel(paymentMethodSearch: PXInitDTO) {
        let configurations = getPaymentOptionConfigurations(paymentMethodSearch: paymentMethodSearch)
        self.paymentConfigurationService.setConfigurations(configurations)
        self.paymentConfigurationService.setDefaultDiscountConfiguration(paymentMethodSearch.selectedDiscountConfiguration)

        self.search = paymentMethodSearch

        guard let search = self.search else {
            return
        }

        self.paymentMethodOptions = self.rootPaymentMethodOptions
        self.availablePaymentMethods = paymentMethodSearch.availablePaymentMethods
        customPaymentOptions?.removeAll()

        for pxCustomOptionSearchItem in search.payerPaymentMethods {
            let customerPaymentMethod = pxCustomOptionSearchItem.getCustomerPaymentMethod()
            customPaymentOptions = Array.safeAppend(customPaymentOptions, customerPaymentMethod)
        }

        let totalPaymentMethodSearchCount = (search.oneTap?.filter { $0.status.enabled })?.count

        if totalPaymentMethodSearchCount == 0 {
            self.errorInputs(error: MPSDKError(message: "Hubo un error".localized, errorDetail: "No se ha podido obtener los métodos de pago con esta preferencia".localized, retry: false), errorCallback: { () in
            })
        }

        if let defaultPM = getPreferenceDefaultPaymentOption() {
            updateCheckoutModel(paymentOptionSelected: defaultPM)
        }
    }

    public func updateCheckoutModel(token: PXToken) {
        if let esc = token.esc, !String.isNullOrEmpty(esc) {
            PXConfiguratorManager.escProtocol.saveESC(config: PXConfiguratorManager.escConfig, token: token, esc: esc)
        } else {
            PXConfiguratorManager.escProtocol.deleteESC(config: PXConfiguratorManager.escConfig, token: token, reason: .NO_ESC, detail: nil)
        }
        self.paymentData.updatePaymentDataWith(token: token)
    }

    public func updateCheckoutModel(paymentMethodOptions: [PaymentMethodOption]) {
        if self.rootPaymentMethodOptions != nil {
            self.rootPaymentMethodOptions!.insert(contentsOf: paymentMethodOptions, at: 0)
        } else {
            self.rootPaymentMethodOptions = paymentMethodOptions
        }
        self.paymentMethodOptions = self.rootPaymentMethodOptions
    }

    func updateCheckoutModel(paymentData: PXPaymentData) {
        self.paymentData = paymentData
        if paymentData.getPaymentMethod() == nil {
            prepareForNewSelection()
            self.initWithPaymentData = false
        } else {
            self.readyToPay = !self.needToCompletePayerInfo()
        }
    }

    func needToCompletePayerInfo() -> Bool {
        if let paymentMethod = self.paymentData.getPaymentMethod() {
            if paymentMethod.isPayerInfoRequired {
                return !self.isPayerSetted()
            }
        }

        return false
    }

    // MARK: PAYMENT METHOD OPTION SELECTION
    public func updateCheckoutModel(paymentOptionSelected: PaymentMethodOption) {
        if !self.initWithPaymentData {
            resetInFormationOnNewPaymentMethodOptionSelected()
        }
        resetPaymentOptionSelectedWith(newPaymentOptionSelected: paymentOptionSelected)
    }

    func errorInputs(error: MPSDKError, errorCallback: (() -> Void)?) {
        PXPaymentMethodSelectorViewModel.error = error
        self.errorCallback = errorCallback
    }

    func populateCheckoutStore() {
        PXCheckoutStore.sharedInstance.paymentDatas = [self.paymentData]
//        if let splitAccountMoney = amountHelper.splitAccountMoney {
//            PXCheckoutStore.sharedInstance.paymentDatas.append(splitAccountMoney)
//        }
        PXCheckoutStore.sharedInstance.checkoutPreference = self.checkoutPreference
    }

    init(checkoutPreference: PXCheckoutPreference, publicKey: String, accessToken: String?, advancedConfiguration: PXAdvancedConfiguration?, trackingConfiguration: PXTrackingConfiguration? = nil) {
        self.checkoutPreference = checkoutPreference
        self.publicKey = publicKey
        self.accessToken = accessToken
        self.advancedConfig = advancedConfiguration ?? PXAdvancedConfiguration()
        self.trackingConfiguration = trackingConfiguration
        mercadoPagoServices = MercadoPagoServices(publicKey: publicKey, privateKey: accessToken, checkoutType: PXCheckoutType.DEFAULT_REGULAR.getString())

        if String.isNullOrEmpty(checkoutPreference.id), checkoutPreference.payer != nil {
            paymentData.updatePaymentDataWith(payer: checkoutPreference.getPayer())
        }

        PXConfiguratorManager.escConfig = PXESCConfig.createConfig()
        PXConfiguratorManager.threeDSConfig = PXThreeDSConfig.createConfig(privateKey: accessToken)

        // Create Init Flow
        createInitFlow()
    }
}

// MARK: Clean and reset functions
extension PXPaymentMethodSelectorViewModel {
    func resetGroupSelection() {
        self.paymentOptionSelected = nil
        guard let search = self.search else {
            return
        }
        self.updateCheckoutModel(paymentMethodSearch: search)
    }

    func resetInFormationOnNewPaymentMethodOptionSelected() {
        resetInformation()
    }

    func resetInformation() {
        self.clearCollectedData()
        self.cardToken = nil
        self.entityTypes = nil
        self.financialInstitutions = nil
        cleanPayerCostSearch()
//        resetPaymentMethodConfigPlugin()
    }

    func clearCollectedData() {
        self.paymentData.clearPaymentMethodData()
        self.paymentData.clearPayerData()

        // Se setea nuevamente el payer que tenemos en la preferencia para no perder los datos
        paymentData.updatePaymentDataWith(payer: checkoutPreference.getPayer())
    }

    func isPayerSetted() -> Bool {
        if let payerData = self.paymentData.getPayer(),
            let payerIdentification = payerData.identification {
            let validPayer = payerIdentification.number != nil
            return validPayer
        }

        return false
    }

    func cleanPayerCostSearch() {
        self.payerCosts = nil
    }

//    func cleanRemedy() {
//        self.remedy = nil
//    }

    func cleanPaymentResult() {
//        self.payment = nil
//        self.paymentResult = nil
        self.readyToPay = false
        self.setIsCheckoutComplete(isCheckoutComplete: false)
//        self.paymentFlow?.cleanPayment()
    }

    func prepareForClone() {
        self.cleanPaymentResult()
    }

    func prepareForNewSelection() {
        self.resetInformation()
        self.resetGroupSelection()
    }

    func isPXSecurityCodeViewControllerLastVC() -> Bool {
        return pxNavigationHandler.navigationController.viewControllers.last is PXSecurityCodeViewController
    }

    static func clearEnviroment() {
        MercadoPagoCheckoutViewModel.error = nil
    }

    func inRootGroupSelection() -> Bool {
        guard let root = rootPaymentMethodOptions, let actual = paymentMethodOptions else {
            return true
        }
        if let hashableSet = NSSet(array: actual) as? Set<AnyHashable> {
            return NSSet(array: root).isEqual(to: hashableSet)
        }
        return true
    }

    public func resetPaymentOptionSelectedWith(newPaymentOptionSelected: PaymentMethodOption) {
        self.paymentOptionSelected = newPaymentOptionSelected

//        if let targetPlugin = paymentOptionSelected as? PXPaymentMethodPlugin {
//            self.paymentMethodPluginToPaymentMethod(plugin: targetPlugin)
//            return
//        }

        if newPaymentOptionSelected.hasChildren() {
            self.paymentMethodOptions = newPaymentOptionSelected.getChildren()
        }

        if self.paymentOptionSelected!.isCustomerPaymentMethod() {
            self.findAndCompletePaymentMethodFor(paymentMethodId: newPaymentOptionSelected.getId())
        } else if !newPaymentOptionSelected.isCard() && !newPaymentOptionSelected.hasChildren() {
            self.paymentData.updatePaymentDataWith(paymentMethod: Utils.findPaymentMethod(self.availablePaymentMethods!, paymentMethodId: newPaymentOptionSelected.getId()), paymentOptionId: newPaymentOptionSelected.getId())
        }
    }

    public func isCheckoutComplete() -> Bool {
        return checkoutComplete
    }

    public func setIsCheckoutComplete(isCheckoutComplete: Bool) {
        self.checkoutComplete = isCheckoutComplete
    }

    func findAndCompletePaymentMethodFor(paymentMethodId: String) {
        guard let availablePaymentMethods = availablePaymentMethods else {
            fatalError("availablePaymentMethods cannot be nil")
        }
        if paymentMethodId == PXPaymentTypes.ACCOUNT_MONEY.rawValue {
            paymentData.updatePaymentDataWith(paymentMethod: Utils.findPaymentMethod(availablePaymentMethods, paymentMethodId: paymentMethodId), paymentOptionId: paymentOptionSelected?.getId())
        } else if let cardInformation = paymentOptionSelected as? PXCardInformation {
            if let paymentMethod = Utils.findPaymentMethod(availablePaymentMethods, paymentMethodId: cardInformation.getPaymentMethodId()) {
                cardInformation.setupPaymentMethodSettings(paymentMethod.settings)
                cardInformation.setupPaymentMethod(paymentMethod)
            }
            paymentData.updatePaymentDataWith(paymentMethod: cardInformation.getPaymentMethod())
            paymentData.updatePaymentDataWith(issuer: cardInformation.getIssuer())
        }
    }
}
