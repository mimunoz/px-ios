import Foundation

final class PXPaymentFlow: NSObject, PXFlow {
    private var validationProgramId: String?
    let model: PXPaymentFlowModel
    weak var resultHandler: PXPaymentResultHandlerProtocol?
    weak var paymentErrorHandler: PXPaymentErrorHandlerProtocol?
    var splitAccountMoney: PXPaymentData?

    var pxNavigationHandler: PXNavigationHandler
    var strategyTracking: StrategyTrackings = ImpletationStrategy()
    var isPaymentToggle = IsPaymentToggle.noPaying

    let paymentFlow = "PXPaymentFlow+PaymentHandlerProtocol - payment "
    let businessFlow = "PXPaymentFlow+PaymentHandlerProtocol - handlePayment - business "
    let basePaymentBusiness = "PXPaymentFlow+PaymentHandlerProtocol - basePayment - business "
    let basePaymentPayment = "PXPaymentFlow+PaymentHandlerProtocol - basePayment - payment "
    let handlePayment = "PXPaymentFlow+PaymentHandlerProtocol - handlePayment "

    init(paymentPlugin: PXSplitPaymentProcessor?, mercadoPagoServices: MercadoPagoServices, paymentErrorHandler: PXPaymentErrorHandlerProtocol, navigationHandler: PXNavigationHandler, amountHelper: PXAmountHelper, checkoutPreference: PXCheckoutPreference?, ESCBlacklistedStatus: [String]?) {
        model = PXPaymentFlowModel(paymentPlugin: paymentPlugin, mercadoPagoServices: mercadoPagoServices, ESCBlacklistedStatus: ESCBlacklistedStatus)
        self.paymentErrorHandler = paymentErrorHandler
        self.pxNavigationHandler = navigationHandler
        self.model.amountHelper = amountHelper
        self.model.checkoutPreference = checkoutPreference
    }

    func setData(amountHelper: PXAmountHelper, checkoutPreference: PXCheckoutPreference, resultHandler: PXPaymentResultHandlerProtocol, splitAccountMoney: PXPaymentData? = nil) {
        self.model.amountHelper = amountHelper
        self.model.checkoutPreference = checkoutPreference
        self.resultHandler = resultHandler
        self.splitAccountMoney = splitAccountMoney

        let paymentData = amountHelper.getPaymentData()
        if let discountToken = amountHelper.paymentConfigurationService.getAmountConfigurationForPaymentMethod(
            paymentOptionID: paymentData.paymentOptionId,
            paymentMethodId: paymentData.paymentMethod?.getId(),
            paymentTypeId: paymentData.paymentMethod?.paymentTypeId
        )?.discountToken,
            amountHelper.splitAccountMoney == nil {
            self.model.amountHelper?.getPaymentData().discount?.id = discountToken.stringValue
            self.model.amountHelper?.getPaymentData().campaign?.id = discountToken
        }
    }

    func setupValidationProgramId(validationProgramId: String?) {
        self.validationProgramId = validationProgramId
    }

    func setProductIdForPayment(_ productId: String) {
        model.productId = productId
    }

    deinit {
        #if DEBUG
            print("DEINIT FLOW - \(self)")
        #endif
    }

    func start() {
        executeNextStep()
    }

    func executeNextStep() {
        DispatchQueue.main.async {
            switch self.model.nextStep() {
            case .createDefaultPayment:
                if !(self.isPaymentToggle.isPayment() ?? false) {
                    self.createPayment(programId: self.validationProgramId)
                }
            case .createPaymentPlugin:
                self.createPaymentWithPlugin(plugin: self.model.paymentPlugin, programId: self.validationProgramId)
            case .createPaymentPluginScreen:
                self.showPaymentProcessor(paymentProcessor: self.model.paymentPlugin, programId: self.validationProgramId)
            case .goToPostPayment:
                self.goToPostPayment()
            case .getPointsAndDiscounts:
                self.showLoaderIfNeeded()
                self.getPointsAndDiscounts()
            case .finish:
                self.hideLoaderIfNeeded()
                self.finishFlow()
            }
        }
    }

    func goToPostPayment() {
        PXNotificationManager.SuscribeTo.didFinishButtonAnimation(self, selector: #selector(showPostPayment))
        PXNotificationManager.Post.animateButton(
            with: PXAnimatedButtonNotificationObject(
                status: "",
                postPaymentStatus: model.postPaymentStatus
            )
        )
        trackPostPaymentEvent()
    }

    @objc
    func showPostPayment() {
        guard case let .pending(notification) = model.postPaymentStatus,
              let basePayment = getBasePayment()
        else {
            model.postPaymentStatus = nil
            executeNextStep()
            return
        }
        MercadoPagoCheckout.NotificationCenter.PublishTo.postPaymentAction(
            withName: notification,
            payment: basePayment
        ) { [unowned self] basePayment in
            model.postPaymentStatus = .continuing
            if let basePayment = basePayment {
                self.cleanPayment()
                self.handlePayment(basePayment: basePayment)
            } else {
                executeNextStep()
            }
        }
    }

    private func getBasePayment() -> PXBasePayment? {
        var basePayment: PXBasePayment?

        if let business = model.businessResult {
            basePayment = business
        } else if let paymentResult = model.paymentResult,
                  let id = Int64(paymentResult.paymentId ?? "") {
            let payment = PXPayment(id: id, status: paymentResult.status)
            payment.paymentMethodId = model.amountHelper?.getPaymentData().paymentMethod?.id
            payment.paymentTypeId = model.amountHelper?.getPaymentData().paymentMethod?.paymentTypeId
            basePayment = payment
        }

        return basePayment
    }

    func getPaymentTimeOut() -> TimeInterval {
        let instructionTimeOut: TimeInterval = model.isOfflinePayment() ? 15 : 0
        if let paymentPluginTimeOut = model.paymentPlugin?.paymentTimeOut?(), paymentPluginTimeOut > 0 {
            return paymentPluginTimeOut + instructionTimeOut
        } else {
            return model.mercadoPagoServices.getTimeOut() + instructionTimeOut
        }
    }

    func needToShowPaymentPluginScreen() -> Bool {
        return model.needToShowPaymentPluginScreenForPaymentPlugin()
    }

    func hasPaymentPluginScreen() -> Bool {
        return model.hasPluginPaymentScreen()
    }

    func finishFlow() {
        strategyTracking.getPropertieFlow(flow: "finishFlow")

        if let paymentResult = model.paymentResult {
            self.resultHandler?.finishPaymentFlow(paymentResult: paymentResult, instructionsInfo: model.instructionsInfo, pointsAndDiscounts: model.pointsAndDiscounts, checkoutPreference: model.checkoutPreference)
        } else if let businessResult = model.businessResult {
            self.resultHandler?.finishPaymentFlow(businessResult: businessResult, pointsAndDiscounts: model.pointsAndDiscounts)
        }
    }

    func cancelFlow() {}

    func exitCheckout() {}

    func cleanPayment() {
        model.cleanData()
    }
}

/** :nodoc: */
extension PXPaymentFlow: PXPaymentProcessorErrorHandler {
    func showError() {
        let error = MPSDKError(message: "Hubo un error".localized, errorDetail: "", retry: false)
        error.requestOrigin = ApiUtil.RequestOrigin.CREATE_PAYMENT.rawValue
        showError(error: error)
    }

    func showError(error: MPSDKError) {
        resultHandler?.finishPaymentFlow(error: error)
    }
}

private extension PXPaymentFlow {
    func trackPostPaymentEvent() {
        guard case let .pending(notification) = model.postPaymentStatus else { return }
        var properties: [String: Any] = [:]
        properties["destination"] = notification.rawValue
        MPXTracker.sharedInstance.trackEvent(event: PostPaymentTrackingEvents.willNavigateToPostPayment(properties))

        strategyTracking.getPropertieFlow(flow: "goToPostPayment - destination \(notification.rawValue)")
    }
}
