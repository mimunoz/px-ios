import Foundation

final class InitFlow {
    let initFlowModel: InitFlowModel
    let maxRetry: Int = 3
    var newCardId: String?
    var newAccountId: String?
    var currentRetry: Int = 1

    private var status: PXFlowStatus = .ready
    private let finishInitCallback: ((PXCheckoutPreference, PXInitDTO) -> Void)
    private let errorInitCallback: ((InitFlowError) -> Void)

    init(flowProperties: InitFlowProperties, finishInitCallback: @escaping ((PXCheckoutPreference, PXInitDTO) -> Void), errorInitCallback: @escaping ((InitFlowError) -> Void)) {
        self.finishInitCallback = finishInitCallback
        self.errorInitCallback = errorInitCallback
        initFlowModel = InitFlowModel(flowProperties: flowProperties)
        PXTrackingStore.sharedInstance.cleanChoType()
    }

    func updateModel(paymentPlugin: PXSplitPaymentProcessor?, chargeRules: [PXPaymentTypeChargeRule]?) {
        initFlowModel.update(paymentPlugin: paymentPlugin, chargeRules: chargeRules)
    }

    deinit {
        #if DEBUG
            print("DEINIT FLOW - \(self)")
        #endif
    }
}

extension InitFlow: PXFlow {
    func start() {
        if status != .running {
            status = .running
            executeNextStep()
        }
    }

    func executeNextStep() {
        DispatchQueue.main.async {
            let nextStep = self.initFlowModel.nextStep()
            switch nextStep {
            case .SERVICE_GET_INIT:
                self.getInitSearch()
            case .FINISH:
                self.finishFlow()
            case .ERROR:
                self.cancelFlow()
            }
        }
    }

    func finishFlow() {
        status = .finished
        if let paymentMethodsSearch = initFlowModel.getPaymentMethodSearch() {
            setCheckoutTypeForTracking()

            // Return the preference we retrieved or the one the integrator created
            let preference = paymentMethodsSearch.preference ?? initFlowModel.properties.checkoutPreference
            finishInitCallback(preference, paymentMethodsSearch)
        } else {
            cancelFlow()
        }
    }

    func cancelFlow() {
        status = .finished
        errorInitCallback(initFlowModel.getError())
        initFlowModel.resetError()
    }

    func exitCheckout() {}
}

// MARK: - Getters
extension InitFlow {
    func setFlowRetry(step: InitFlowModel.Steps) {
        status = .ready
        initFlowModel.setPendingRetry(forStep: step)
    }

    func disposePendingRetry() {
        initFlowModel.removePendingRetry()
    }

    func getStatus() -> PXFlowStatus {
        return status
    }

    func restart() {
        if status != .running {
            status = .ready
        }
    }
}

// MARK: - Privates
extension InitFlow {
    private func setCheckoutTypeForTracking() {
        if let paymentMethodsSearch = initFlowModel.getPaymentMethodSearch() {
            PXTrackingStore.sharedInstance.setChoType(paymentMethodsSearch.oneTap != nil ? .one_tap : .traditional)
        }
    }
}
