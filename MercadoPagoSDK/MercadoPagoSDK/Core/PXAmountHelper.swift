import Foundation

struct PXAmountHelper {
    let preference: PXCheckoutPreference
    private let paymentData: PXPaymentData
    let chargeRules: [PXPaymentTypeChargeRule]?
    let paymentConfigurationService: PXPaymentConfigurationServices
    var splitAccountMoney: PXPaymentData?

    init (preference: PXCheckoutPreference, paymentData: PXPaymentData, chargeRules: [PXPaymentTypeChargeRule]?, paymentConfigurationService: PXPaymentConfigurationServices, splitAccountMoney: PXPaymentData?) {
        self.preference = preference
        self.paymentData = paymentData
        self.chargeRules = chargeRules
        self.paymentConfigurationService = paymentConfigurationService
        self.splitAccountMoney = splitAccountMoney
    }

    var consumedDiscount: Bool {
        return paymentData.consumedDiscount ?? false
    }

    var discount: PXDiscount? {
        return paymentData.discount
    }

    var campaign: PXCampaign? {
        return paymentData.campaign
    }

    var preferenceAmount: Double {
        return self.preference.getTotalAmount()
    }

    var preferenceAmountWithCharges: Double {
        // preferenceAmount + chargeRuleAmount
        let decimalPreferenceAmount = PXAmountHelper.getRoundedAmountAsNsDecimalNumber(amount: preferenceAmount)
        let decimalChargeRuleAmount = PXAmountHelper.getRoundedAmountAsNsDecimalNumber(amount: chargeRuleAmount)

        let sum = decimalPreferenceAmount.adding(decimalChargeRuleAmount)

        guard let doubleSum = Double(sum.stringValue) else { return preferenceAmount + chargeRuleAmount }

        return doubleSum
    }

    var amount: Double? {
        return paymentData.amount
    }

    var taxFreeAmount: Double? {
        return paymentData.taxFreeAmount
    }

    var noDiscountAmount: Double? {
        return paymentData.noDiscountAmount
    }

    var amountToPay: Double {
        if let payerCost = paymentData.payerCost {
            return payerCost.totalAmount
        }
        return amountToPayWithoutPayerCost
    }

    var isSplitPayment: Bool {
        return splitAccountMoney != nil
    }

    func getAmountToPayWithoutPayerCost(paymentOptionID: String?, paymentMethodId: String?, paymentTypeId: String?) -> Double {
        guard let paymentMethodId = paymentMethodId,
              let amountFromPaymentMethod = paymentConfigurationService.getAmountToPayWithoutPayerCostForPaymentMethod(paymentOptionID: paymentOptionID, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) else {
            return amountToPayWithoutPayerCost
        }
        return amountFromPaymentMethod
    }

    private var amountToPayWithoutPayerCost: Double {
        if let couponAmount = paymentData.discount?.couponAmount {
            // preferenceAmount - couponAmount + chargeRuleAmount
            let decimalPreferenceAmount = PXAmountHelper.getRoundedAmountAsNsDecimalNumber(amount: preferenceAmount)
            let decimalCouponAmount = PXAmountHelper.getRoundedAmountAsNsDecimalNumber(amount: couponAmount)
            let decimalChargeRuleAmount = PXAmountHelper.getRoundedAmountAsNsDecimalNumber(amount: chargeRuleAmount)

            let sum = (decimalPreferenceAmount.subtracting(decimalCouponAmount)).adding(decimalChargeRuleAmount)

            guard let doubleSum = Double(sum.stringValue) else { return preferenceAmount + chargeRuleAmount }

            return doubleSum
        } else {
            // preferenceAmount + chargeRuleAmount
            return preferenceAmountWithCharges
        }
    }

    var amountOff: Double {
        guard let discount = self.paymentData.discount else {
            return 0
        }
        return discount.couponAmount
    }

    var maxCouponAmount: Double? {
        if let maxCouponAmount = paymentData.campaign?.maxCouponAmount, maxCouponAmount > 0.0 {
            return maxCouponAmount
        }
        return nil
    }

    var chargeRuleAmount: Double {
        guard let rules = chargeRules else {
            return 0
        }
        for rule in rules {
            if rule.paymentTypeId == paymentData.paymentMethod?.paymentTypeId {
                return rule.amountCharge
            }
        }
        return 0
    }

    var chargeRuleLabel: String? {
        guard let rules = chargeRules else {
            return nil
        }

        for rule in rules {
            if rule.paymentTypeId == paymentData.paymentMethod?.paymentTypeId {
                return rule.label
            }
        }
        return nil
    }

    func getPaymentData() -> PXPaymentData {
        // Set total card amount with charges without discount
        if paymentData.transactionAmount == nil || paymentData.transactionAmount == 0 {
            if let paymentMethod = paymentData.paymentMethod,
               let paymentOptionId = paymentData.paymentOptionId,
               let amount = paymentConfigurationService.getAmount(paymentOptionId: paymentOptionId, paymentMethodId: paymentMethod.id, paymentTypeId: paymentMethod.paymentTypeId),
               let taxFreeAmount = paymentConfigurationService.getTaxFreeAmount(paymentOptionId: paymentOptionId, paymentMethodId: paymentMethod.id, paymentTypeId: paymentMethod.paymentTypeId),
               let noDiscountAmount = paymentConfigurationService.getNoDiscountAmount(paymentOptionId: paymentOptionId, paymentMethodId: paymentMethod.id, paymentTypeId: paymentMethod.paymentTypeId) {
                self.paymentData.transactionAmount = NSDecimalNumber(floatLiteral: taxFreeAmount)
                self.paymentData.amount = amount
                self.paymentData.taxFreeAmount = taxFreeAmount
                self.paymentData.noDiscountAmount = noDiscountAmount
            } else {
                self.paymentData.transactionAmount = NSDecimalNumber(floatLiteral: preferenceAmountWithCharges)
            }
        }
        return paymentData
    }
}

extension PXAmountHelper {
    static func getRoundedAmountAsNsDecimalNumber(amount: Double?, forInit: Bool = false) -> NSDecimalNumber {
         guard let targetAmount = amount else { return 0 }
         let decimalPlaces: Double = forInit ? 2 : Double(SiteManager.shared.getCurrency().getDecimalPlacesOrDefault())
         let amountRounded: Double = Double(round(pow(10, decimalPlaces) * Double(targetAmount)) / pow(10, decimalPlaces))
         let amountString = String(format: "%\(decimalPlaces / 10)f", amountRounded)
         return NSDecimalNumber(string: amountString)
     }
}

// MARK: Tracking usage
extension PXAmountHelper {
    func getDiscountCouponAmountForTracking() -> Decimal {
        guard let couponAmount = paymentData.getDiscount()?.getCouponAmount()?.decimalValue else { return 0 }
        if let amPaymentDataAmount = splitAccountMoney?.getDiscount()?.getCouponAmount() {
            return amPaymentDataAmount.decimalValue + couponAmount
        }
        return couponAmount
    }
}
