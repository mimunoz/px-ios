import Foundation

typealias PXPaymentConfigurationType = (chargeRules: [PXPaymentTypeChargeRule]?, paymentPlugin: PXSplitPaymentProcessor)

/**
 Any configuration related to the Payment. You can set you own `PXPaymentProcessor`. Configuration of discounts, charges and custom Payment Method Plugin.
 */
@objcMembers
open class PXPaymentConfiguration: NSObject {
    private let splitPaymentProcessor: PXSplitPaymentProcessor
    private var chargeRules: [PXPaymentTypeChargeRule] = [PXPaymentTypeChargeRule]()
    private var paymentMethodPlugins: [PXPaymentMethodPlugin] = [PXPaymentMethodPlugin]()
    private var choiceProcessorType: PXCheckoutType?

    // MARK: Init.
    /**
     Builder for `PXPaymentConfiguration` construction.
     - parameter paymentProcessor: Your custom implementation of `PXPaymentProcessor`.
     */
    public init(paymentProcessor: PXPaymentProcessor) {
        self.splitPaymentProcessor = PXPaymentProcessorAdapter(paymentProcessor: paymentProcessor)
        self.choiceProcessorType = splitPaymentProcessor.getProcessorType?()
    }

    public init(splitPaymentProcessor: PXSplitPaymentProcessor) {
        self.choiceProcessorType = splitPaymentProcessor.getProcessorType?()
        self.splitPaymentProcessor = splitPaymentProcessor
    }

    public init(scheduledPaymentProcessor: PXPaymentProcessor) {
        self.splitPaymentProcessor = PXScheduledPaymentProcessorAdapter(paymentProcessor: scheduledPaymentProcessor)
        self.choiceProcessorType = splitPaymentProcessor.getProcessorType?()
    }
}

// MARK: - Builder
extension PXPaymentConfiguration {
    /**
     Add your own payment method option to pay.
     - parameter plugin: Your custom payment method plugin.
     */
    @available(*, deprecated, message: "Payment method plugins is no longer available.")
    /// :nodoc
    open func addPaymentMethodPlugin(plugin: PXPaymentMethodPlugin) -> PXPaymentConfiguration {
        return self
    }

    /**
     Add extra charges that will apply to total amount.
     - parameter charges: the list (array) of charges that could apply.
     */
    open func addChargeRules(charges: [PXPaymentTypeChargeRule]) -> PXPaymentConfiguration {
        self.chargeRules.append(contentsOf: charges)
        return self
    }

    /**
     `PXDiscountConfiguration` is an object that represents the discount to be applied or error information to present to the user. It's mandatory to handle your discounts by hand if you set a payment processor.
     - parameter config: Your custom discount configuration
     */
    @available(*, deprecated)
    open func setDiscountConfiguration(config: PXDiscountConfiguration) -> PXPaymentConfiguration {
        return self
    }
}

// MARK: - Internals
extension PXPaymentConfiguration {
    func getPaymentConfiguration() -> PXPaymentConfigurationType {
        return (chargeRules, splitPaymentProcessor)
    }
}

extension PXPaymentConfiguration {
    internal func getProcessorType() -> String? {
        switch choiceProcessorType ?? .CUSTOM_REGULAR {
        case .CUSTOM_SCHEDULED:
            return PXCheckoutType.CUSTOM_SCHEDULED.getString()
        case .CUSTOM_REGULAR:
            return PXCheckoutType.CUSTOM_REGULAR.getString()
        case .DEFAULT_REGULAR:
            return PXCheckoutType.DEFAULT_REGULAR.getString()
        }
    }
}
