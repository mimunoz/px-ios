import Foundation

// MARK: Init Flow
extension MercadoPagoCheckoutViewModel {
    func createInitFlow() {
        // Create init flow props.
        let initFlowProperties: InitFlowProperties
        initFlowProperties.checkoutPreference = checkoutPreference
        initFlowProperties.paymentData = paymentData
        initFlowProperties.paymentPlugin = paymentPlugin
        initFlowProperties.paymentMethodSearchResult = search
        initFlowProperties.chargeRules = chargeRules
        initFlowProperties.serviceAdapter = mercadoPagoServices
        initFlowProperties.advancedConfig = getAdvancedConfiguration()
        initFlowProperties.paymentConfigurationService = paymentConfigurationService
        initFlowProperties.privateKey = privateKey
        initFlowProperties.productId = getAdvancedConfiguration().productId

        configureBiometricModule()

        // Create init flow.
        initFlow = InitFlow(flowProperties: initFlowProperties, finishInitCallback: { [weak self] checkoutPreference, initSearch  in
            guard let self = self else { return }
            self.checkoutPreference = checkoutPreference
            self.updateCustomTexts()
            self.updateCheckoutModel(paymentMethodSearch: initSearch)
            self.paymentData.updatePaymentDataWith(payer: checkoutPreference.getPayer())
            PXTrackingStore.sharedInstance.addData(forKey: PXTrackingStore.cardIdsESC, value: self.getCardsIdsWithESC())

            let selectedDiscountConfigurartion = initSearch.selectedDiscountConfiguration
            self.attemptToApplyDiscount(selectedDiscountConfigurartion)

            self.initFlowProtocol?.didFinishInitFlow()
        }, errorInitCallback: { [weak self] initFlowError in
            self?.initFlowProtocol?.didFailInitFlow(flowError: initFlowError)
        })
    }

    func setInitFlowProtocol(flowInitProtocol: InitFlowProtocol) {
        initFlowProtocol = flowInitProtocol
    }

    func startInitFlow() {
        initFlow?.start()
    }

    func refreshInitFlow(cardId: String) {
        initFlow?.initFlowModel.updateInitModel(paymentMethodsResponse: nil)
        initFlow?.newCardId = cardId
        initFlow?.start()
    }
    
    func refreshAddAccountFlow(accountId: String) {
        initFlow?.initFlowModel.updateInitModel(paymentMethodsResponse: nil)
        initFlow?.newAccountId = accountId
        initFlow?.start()
    }

    func updateInitFlow() {
        initFlow?.updateModel(paymentPlugin: self.paymentPlugin, chargeRules: self.chargeRules)
    }

    func configureBiometricModule() {
        // We use productId as unique identifier
        PXConfiguratorManager.biometricConfig = PXBiometricConfig.createConfig(withFlowIdentifier: getAdvancedConfiguration().productId, andAmount: paymentData.getRawAmount())
    }
}
