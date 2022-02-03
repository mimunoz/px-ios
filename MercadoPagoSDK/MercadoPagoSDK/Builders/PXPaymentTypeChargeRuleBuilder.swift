import Foundation

@objc public class PXPaymentTypeChargeRuleBuilder: NSObject {
    private var paymentTypeId: String
    private var amount: Double

    public private(set) var taxable: Bool = true
    public private(set) var label: String?
    public private(set) var detailModal: UIViewController?

    public init(paymentTypeId: String, amount: Double) throws {
        if amount == 0.0 {
            throw PXPaymentTypeChargeRuleBuilderError.invalidAmount
        }

        self.paymentTypeId = paymentTypeId
        self.amount = amount
    }

    @discardableResult
    public func setTaxable(_ taxable: Bool) -> PXPaymentTypeChargeRuleBuilder {
        self.taxable = taxable
        return self
    }

    @discardableResult
    public func setLabel(_ label: String) -> PXPaymentTypeChargeRuleBuilder {
        self.label = label
        return self
    }

    @discardableResult
    public func setDetailModal(_ detailModal: UIViewController) -> PXPaymentTypeChargeRuleBuilder {
        self.detailModal = detailModal
        return self
    }

    public func build() -> PXPaymentTypeChargeRule {
        let chargeRule = PXPaymentTypeChargeRule(paymentTypeId: paymentTypeId, amountCharge: amount, detailModal: detailModal)

        chargeRule.label = label
        chargeRule.taxable = taxable

        return chargeRule
    }
}

public enum PXPaymentTypeChargeRuleBuilderError: Error {
    case invalidAmount
}

extension PXPaymentTypeChargeRuleBuilderError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return NSLocalizedString(
                "Charge rule amount cannot be zero",
                comment: ""
            )
        }
    }
}
