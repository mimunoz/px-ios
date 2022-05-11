import Foundation

public class PXPaymentMethodSelector: NSObject {
    static var shared: PXPaymentMethodSelector?

    var viewModel: PXPaymentMethodSelectorViewModel?

    static var currentCheckout: PXPaymentMethodSelector?

    private init(viewModel: PXPaymentMethodSelectorViewModel) {
        self.viewModel = viewModel
    }

    // This struct will hold the value of the new card added by MLCardForm
    // until the init flow is refreshed with this new payment method
    struct InitFlowRefresh {
        static var cardId: String?
        static var accountId: String?
        static let retryDelay: Double = 0.5

        static func resetValues() {
            cardId = nil
        }
    }

    public class Builder {
        var accessToken: String?
        var publicKey: String?
        var preferenceId: String?
        var dynamicDialogConfiguration: [PXDynamicViewControllerProtocol]?
        var customStringConfiguration: AnyObject?
        var discountParamsConfiguration: PXDiscountParamsConfiguration?
        var productId: String?
        var chargeRules: [PXPaymentTypeChargeRule]?
        var trackingConfiguration: PXTrackingConfiguration?
        var paymentMethodBehaviours: [PXPaymentMethodBehaviour]? = []
        var paymentMethodRules: [String]? = []

        public init(publicKey: String, preferenceId: String) {
            self.publicKey = publicKey
            self.preferenceId = preferenceId
        }

        public func setProductId(productId: String) {
            self.productId = productId
        }

        public func setAccessToken(accessToken: String) {
            self.accessToken = accessToken
        }

        public func setChargeRules(chargeRules: [PXPaymentTypeChargeRule]) {
            self.chargeRules = chargeRules
        }

        public func setPaymentMethodBehaviours(paymentMethodBehaviours: [PXPaymentMethodBehaviour]) {
            self.paymentMethodBehaviours = paymentMethodBehaviours
        }

        public func setPaymentMethodRules(paymentMethodRules: [String]) {
            self.paymentMethodRules = paymentMethodRules
        }

        public func setLanguage(_ string: String) {
            Localizator.sharedInstance.setLanguage(string: string)
        }

        public func setTrackingConfiguration(trackingConfiguration: PXTrackingConfiguration) {
            self.trackingConfiguration = trackingConfiguration
        }

        public func build() throws -> PXPaymentMethodSelector? {
            guard let publicKey = publicKey else {
                throw PXPaymentMethodSelectorError.missingPublicKey
            }

            guard let accessToken = accessToken else {
                throw PXPaymentMethodSelectorError.missingAccessToken
            }

            var preference: PXCheckoutPreference

            if let preferenceId = self.preferenceId {
                preference = PXCheckoutPreference(preferenceId: preferenceId)
            } else {
                fatalError("CheckoutPreference or preferenceId are mandatory.")
            }

            let advancedConfiguration = PXAdvancedConfiguration()

            if let productId = productId {
                advancedConfiguration.setProductId(id: productId)
            }

            if let discountParamsConfiguration = discountParamsConfiguration {
                advancedConfiguration.discountParamsConfiguration = self.discountParamsConfiguration
            }

            if let dynamicDialogConfiguration = self.dynamicDialogConfiguration {
                advancedConfiguration.dynamicViewControllersConfiguration = dynamicDialogConfiguration
            }

            if let paymentMethodRules = self.paymentMethodRules {
                advancedConfiguration.paymentMethodRules = paymentMethodRules
            }

            if let paymentMethodBehaviours = paymentMethodBehaviours {
                advancedConfiguration.paymentMethodBehaviours = paymentMethodBehaviours
            }

            let viewModel = PXPaymentMethodSelectorViewModel(checkoutPreference: preference, publicKey: publicKey, accessToken: self.accessToken, advancedConfiguration: advancedConfiguration, trackingConfiguration: self.trackingConfiguration)

            viewModel.chargeRules = chargeRules

            viewModel.updateInitFlow()

            return PXPaymentMethodSelector(viewModel: viewModel)
        }
    }
}

public enum PXPaymentMethodSelectorError: Error {
    case missingAccessToken
    case missingPublicKey
}

public protocol PXPaymentMethodSelectorDelegate: AnyObject {
    func didSelectPaymentMethod() -> ((_ checkoutStore: PXCheckoutStore) -> Void)?

    /**
     User cancel checkout. By any cancel UI button or back navigation action. You can return an optional block, to override the default exit cancel behavior. Default exit cancel behavior is back navigation stack.
     */
    func didCancelPaymentMethodSelection() -> (() -> Void)?
}

extension PXPaymentMethodSelector {
    public func start(navigationController: UINavigationController, delegate: PXPaymentMethodSelectorDelegate?=nil) {
        viewModel?.delegate = delegate

        PXTrackingStore.sharedInstance.initializeInitDate()

        viewModel?.setInitFlowProtocol(flowInitProtocol: self)

        ThemeManager.shared.initialize()

        viewModel?.setNavigationHandler(handler: PXNavigationHandler(navigationController: navigationController))

        ThemeManager.shared.saveNavBarStyleFor(navigationController: navigationController)

        viewModel?.pxNavigationHandler.presentInitLoading()

        self.startTracking { [weak self] in
            guard let self = self else { return }
            self.initialize()
        }
    }

    func finish() {
        commonFinish()
        viewModel?.pxNavigationHandler.removeRootLoading()
        HtmlStorage.shared.clean()

        // Default exit.
        defaultExitAction()
    }

    func exitCheckout() {
        finish()
    }

    @objc func closeCheckout() {
        commonFinish()

        if let _ = viewModel?.getSelectedPaymentMethod() {
            if let didSelectPaymentMethod = viewModel?.delegate?.didSelectPaymentMethod() {
                return didSelectPaymentMethod(PXCheckoutStore())
            } else {
                return defaultExitAction()
            }
        }

        // delegate.cancelCheckout - defined
        // Exit checkout without payment. (by back stack action)
        if let delegate = viewModel?.delegate, let cancelCustomAction = delegate.didCancelPaymentMethodSelection() {
            cancelCustomAction()
            return
        }

        // Default exit. Without LifecycleProtocol returns.
        defaultExitAction()
    }
}

// MARK: Privates
extension PXPaymentMethodSelector {
    private func initialize() {
        PXPaymentMethodSelector.shared = self

        if let currentCheckout = PXPaymentMethodSelector.shared {
            PXNotificationManager.SuscribeTo.attemptToClose(currentCheckout, selector: #selector(closeCheckout))
        }

        viewModel?.startInitFlow()
    }

    private func shouldUpdateOnetapFlow() -> Bool {
        if viewModel?.onetapFlow != nil,
            let cardId = InitFlowRefresh.cardId,
            cardId.isNotEmpty {
            return true
        }
        // Card should not be updated or number of retries has reached max number
        return false
    }

    func startOneTapFlow() {
        guard let viewModel = viewModel, let search = viewModel.search else { return }

        if viewModel.onetapFlow == nil {
            viewModel.onetapFlow = OneTapFlow(paymentMethodSelectorViewModel: viewModel, search: search, paymentOptionSelected: viewModel.paymentOptionSelected, oneTapResultHandler: self)
        } else {
            viewModel.onetapFlow?.update(paymentMethodSelectorViewModel: viewModel, search: search, paymentOptionSelected: viewModel.paymentOptionSelected)
        }

        guard let onetapFlow = viewModel.onetapFlow else {
            // onetapFlow shouldn't be nil by this point
            return
        }

        onetapFlow.setCustomerPaymentMethods(viewModel.customPaymentOptions)

        if shouldUpdateOnetapFlow() {
            onetapFlow.updateOneTapViewModel(cardId: InitFlowRefresh.cardId ?? "")
        } else {
            onetapFlow.start()
        }

        InitFlowRefresh.resetValues()
    }

    func commonFinish() {
        MPXTracker.sharedInstance.clean()
        PXCheckoutStore.sharedInstance.clean()
        PXNotificationManager.UnsuscribeTo.attemptToClose(self)
        ThemeManager.shared.applyAppNavBarStyle(navigationController: viewModel?.pxNavigationHandler.navigationController)
        viewModel?.clean()
    }

    func defaultExitAction() {
        viewModel?.pxNavigationHandler.goToRootViewController()
    }

    func showErrorScreen() {
        viewModel?.pxNavigationHandler.showErrorScreen(error: PXPaymentMethodSelectorViewModel.error, callbackCancel: finish, errorCallback: viewModel?.errorCallback)
        PXPaymentMethodSelectorViewModel.error = nil
    }
}

extension PXPaymentMethodSelector: InitFlowProtocol {
    func didFinishInitFlow() {
        self.startOneTapFlow()
    }

    func didFailInitFlow(flowError: InitFlowError) {
        var errorDetail = ""
        #if DEBUG
            errorDetail = flowError.errorStep.rawValue
        #endif

        let customError = MPSDKError(message: "Error".localized, errorDetail: errorDetail, retry: flowError.shouldRetry, requestOrigin: flowError.requestOrigin?.rawValue)

        viewModel?.errorInputs(error: customError, errorCallback: { [weak self] in
            if flowError.shouldRetry {
                self?.viewModel?.pxNavigationHandler.presentLoading()
                self?.viewModel?.initFlow?.setFlowRetry(step: flowError.errorStep)
                self?.viewModel?.startInitFlow()
            } else {
                self?.showErrorScreen()
            }
        })

        self.showErrorScreen()
    }
}
