import UIKit

/**
 Main class of this project.
 It provides access to most of the checkout experience. It takes a `MercadoPagoCheckoutBuilder` object.
 */
@objcMembers
open class MercadoPagoCheckout: NSObject {
    enum InitMode {
        case normal
        case lazy
    }

    var initMode: InitMode = .normal
    var initProtocol: PXLazyInitProtocol?
    static var currentCheckout: MercadoPagoCheckout?
    var paymentConfiguration: PXPaymentConfiguration?
    var viewModel: MercadoPagoCheckoutViewModel
    // This struct will hold the value of the new card added by MLCardForm
    // until the init flow is refreshed with this new payment method
    struct InitFlowRefresh {
        static var cardId: String?
        static var accountId: String?
        static let retryDelay: Double = 0.5

        static func resetValues() {
            cardId = nil
            accountId = nil
        }
    }

    var businessResultVM: PXBusinessResultViewModel?
    var genericResultVM: PXResultViewModel?
    var strategyTracking: StrategyTrackings = ImpletationStrategy()

    // MARK: Initialization
    /**
     Mandatory init. Based on `MercadoPagoCheckoutBuilder`
     - parameter builder: MercadoPagoCheckoutBuilder object.
     */
    public init(builder: MercadoPagoCheckoutBuilder) {
        var choPref: PXCheckoutPreference
        if let preferenceId = builder.preferenceId {
            choPref = PXCheckoutPreference(preferenceId: preferenceId)
        } else if let preference = builder.checkoutPreference {
            choPref = preference
        } else {
            fatalError("CheckoutPreference or preferenceId must be mandatory.")
        }
        let checkoutType = builder.paymentConfig?.getProcessorType()
        viewModel = MercadoPagoCheckoutViewModel(checkoutPreference: choPref, publicKey: builder.publicKey, privateKey: builder.privateKey, advancedConfig: builder.advancedConfig, trackingConfig: builder.trackingConfig, checkoutType: checkoutType)

        if let notificationName = builder.postPaymentConfig?.postPaymentNotificationName {
            viewModel.setPostPaymentNotification(postPaymentNotificationName: notificationName)
        }

        // Set Theme.
        if let customTheme = builder.advancedConfig?.theme {
            ThemeManager.shared.setTheme(theme: customTheme)
        } else if let defaultColor = builder.defaultUIColor {
            ThemeManager.shared.setDefaultColor(color: defaultColor)
        }
        if let paymentConfiguration = builder.paymentConfig {
            let (chargeRules, paymentPlugin) = paymentConfiguration.getPaymentConfiguration()

            // Set charge rules
            viewModel.chargeRules = chargeRules

            // Payment plugin (paymentProcessor).
            viewModel.paymentPlugin = paymentPlugin
        }
        viewModel.updateInitFlow()
    }
}

// MARK: Publics
extension MercadoPagoCheckout {
    /**
     Start checkout experience. This method push our ViewController in your navigation stack.
     - parameter navigationController: Instance of your `UINavigationController`.
     - parameter lifeCycleProtocol: Instance of `PXLifeCycleProtocol` implementation. Provide this protocol in order to get notifications related to our checkout lifecycle. (`FinishCheckout` and `CancelCheckout`)
     */
    public func start(navigationController: UINavigationController, lifeCycleProtocol: PXLifeCycleProtocol?=nil) {
        viewModel.lifecycleProtocol = lifeCycleProtocol
        commonInit()
        ThemeManager.shared.initialize()
        viewModel.setNavigationHandler(handler: PXNavigationHandler(navigationController: navigationController))
        ThemeManager.shared.saveNavBarStyleFor(navigationController: navigationController)
        if initMode == .lazy {
            if viewModel.initFlow?.getStatus() == .finished {
                executeNextStep()
            } else {
                if viewModel.initFlow?.getStatus() == .running {
                    return
                } else {
                    // Lazy with "ready" to run.
                    viewModel.pxNavigationHandler.presentInitLoading()
                    executeNextStep()
                }
            }
        } else {
            viewModel.pxNavigationHandler.presentInitLoading()
            executeNextStep()
        }
    }

    /**
     Start checkout init services in lazy mode (without UI). Start our init methods and provide a protocol to notify when the checkout is ready to launch `PXLazyInitProtocol`
     - parameter lazyInitProtocol: Implementation of `PXLazyInitProtocol`.
     */
    public func start(lazyInitProtocol: PXLazyInitProtocol) {
        viewModel.initFlow?.restart()
        initProtocol = lazyInitProtocol
        initMode = .lazy
        commonInit()
        executeNextStep()
    }
}

// MARK: Internals
extension MercadoPagoCheckout {
    func setPaymentResult(paymentResult: PaymentResult) {
        self.viewModel.paymentResult = paymentResult
        self.viewModel.splitAccountMoney = self.viewModel.paymentResult?.splitAccountMoney
        if let paymentData = paymentResult.paymentData {
            self.viewModel.paymentData = paymentData
        }
    }

    func setCheckoutPreference(checkoutPreference: PXCheckoutPreference) {
        self.viewModel.checkoutPreference = checkoutPreference
    }

    func executePreviousStep(animated: Bool = true) {
        viewModel.pxNavigationHandler.navigationController.popViewController(animated: animated)
    }

    func executeNextStep() {
        DispatchQueue.main.async {
            let result = self.viewModel.nextStep()
            self.trackFlow(result.rawValue)

            switch result {
            case .START :
                self.startTracking { [weak self] in
                    guard let self = self else { return }
                    self.initialize()
                }
            case .SERVICE_CREATE_CARD_TOKEN:
                self.createCardToken()
            case .SCREEN_SECURITY_CODE:
                self.showSecurityCodeScreen()
            case .SERVICE_POST_PAYMENT:
                self.createPayment()
            case .SERVICE_GET_REMEDY:
                self.getRemedy()
            case .SCREEN_PAYMENT_RESULT:
                self.showPaymentResultScreen()
            case .ACTION_FINISH:
                self.finish()
            case .SCREEN_ERROR:
                self.showErrorScreen()
            case .SCREEN_PAYMENT_METHOD_PLUGIN_CONFIG:
                self.showPaymentMethodPluginConfigScreen()
            case .FLOW_ONE_TAP:
                self.startOneTapFlow()
            }
        }
    }

    func finish() {
        commonFinish()
        viewModel.pxNavigationHandler.removeRootLoading()
        HtmlStorage.shared.clean()
        // LifecycleProtocol.finishCheckout - defined
        // Exit checkout with payment. (by state machine next)
        if let result = viewModel.getResult(),
            let finishCallback = viewModel.lifecycleProtocol?.finishCheckout() {
            finishCallback(result)
        } else {
            // Default exit.
            defaultExitAction()
        }
    }

    func cancelCheckout() {
        closeCheckout()
    }

    /// :nodoc:
    @objc func closeCheckout() {
        commonFinish()
        // LifecycleProtocol.finishCheckout - defined
        // Exit checkout with payment. (by closeAction)
        if viewModel.getGenericPayment() != nil {
            let result = viewModel.getResult()
            if let finishCallback = viewModel.lifecycleProtocol?.finishCheckout() {
                finishCallback(result)
            } else {
                defaultExitAction()
            }
            return
        }

        // LifecycleProtocol.cancelCheckout - defined
        // Exit checkout without payment. (by back stack action)
        if let lifecycle = viewModel.lifecycleProtocol, let cancelCustomAction = lifecycle.cancelCheckout() {
            cancelCustomAction()
            return
        }

        // Default exit. Without LifecycleProtocol returns.
        defaultExitAction()
    }
}

// MARK: Privates
extension MercadoPagoCheckout {
    private func initialize() {
        MercadoPagoCheckout.currentCheckout = self

        if let currentCheckout = MercadoPagoCheckout.currentCheckout {
            PXNotificationManager.SuscribeTo.attemptToClose(currentCheckout, selector: #selector(closeCheckout))
        }
        viewModel.startInitFlow()
    }

    private func createCardToken() {
        let lastViewController = viewModel.pxNavigationHandler.navigationController.viewControllers.last
        if lastViewController is PXNewResultViewController || lastViewController is PXSecurityCodeViewController {
            getTokenizationService(needToShowLoading: false).createCardToken()
        } else {
            getTokenizationService().createCardToken()
        }
    }

    private func commonInit() {
        PXTrackingStore.sharedInstance.initializeInitDate()
        viewModel.setInitFlowProtocol(flowInitProtocol: self)
        if !viewModel.shouldApplyDiscount() {
            viewModel.clearDiscount()
        }
    }

    private func commonFinish() {
        MPXTracker.sharedInstance.clean()
        PXCheckoutStore.sharedInstance.clean()
        PXNotificationManager.UnsuscribeTo.attemptToClose(self)
        ThemeManager.shared.applyAppNavBarStyle(navigationController: viewModel.pxNavigationHandler.navigationController)
        viewModel.clean()
    }

    private func removeDiscount() {
        viewModel.clearDiscount()
    }

    private func defaultExitAction() {
        viewModel.pxNavigationHandler.goToRootViewController()
    }
}

extension MercadoPagoCheckout {
    private func trackFlow(_ flow: String) {
        strategyTracking.getPropertieFlow(flow: flow)
    }
}
