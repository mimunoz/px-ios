import UIKit

/**
 Data needed for payment.
 */
@objcMembers public class PXPaymentData: NSObject, NSCopying {
    var paymentMethod: PXPaymentMethod?
    var issuer: PXIssuer? {
        didSet {
            processIssuer()
        }
    }
    var payerCost: PXPayerCost?
    var token: PXToken?
    var payer: PXPayer?
    var transactionAmount: NSDecimalNumber?
    var transactionDetails: PXTransactionDetails?
    private(set) var discount: PXDiscount?
    private(set) var campaign: PXCampaign?
    private(set) var consumedDiscount: Bool?
    private(set) var discountDescription: PXDiscountDescription?
    private let paymentTypesWithoutInstallments = [PXPaymentTypes.PREPAID_CARD.rawValue]
    var paymentOptionId: String?
    var amount: Double?
    var taxFreeAmount: Double?
    var noDiscountAmount: Double?

    /// :nodoc:
    public func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = PXPaymentData()
        copyObj.paymentMethod = paymentMethod
        copyObj.issuer = issuer
        copyObj.payerCost = payerCost
        copyObj.token = token
        copyObj.payerCost = payerCost
        copyObj.transactionDetails = transactionDetails
        copyObj.discount = discount
        copyObj.campaign = campaign
        copyObj.consumedDiscount = consumedDiscount
        copyObj.discountDescription = discountDescription
        copyObj.payer = payer
        copyObj.paymentOptionId = paymentOptionId
        copyObj.amount = amount
        copyObj.taxFreeAmount = taxFreeAmount
        copyObj.noDiscountAmount = noDiscountAmount
        return copyObj
    }

    func isComplete(shouldCheckForToken: Bool = true) -> Bool {
        guard let paymentMethod = self.paymentMethod else {
            return false
        }

        if paymentMethod.isEntityTypeRequired && payer?.entityType == nil {
            return false
        }

        if paymentMethod.isPayerInfoRequired {
            guard let identification = payer?.identification else {
                return false
            }
            if !identification.isComplete {
                return false
            }
        }

        if paymentMethod.id == PXPaymentTypes.ACCOUNT_MONEY.rawValue || !paymentMethod.isOnlinePaymentMethod {
            return true
        }

        if paymentMethod.isIssuerRequired && self.issuer == nil {
            return false
        }

        if paymentMethod.isCard && payerCost == nil &&
            !paymentTypesWithoutInstallments.contains(paymentMethod.paymentTypeId) {
            return false
        }

        if paymentMethod.isDigitalCurrency && payerCost == nil {
            return false
        }

        if paymentMethod.isCard && !hasToken() && shouldCheckForToken {
            return false
        }
        return true
    }

    func hasToken() -> Bool {
        return token != nil
    }

    func hasIssuer() -> Bool {
        return issuer != nil
    }

    func hasPayerCost() -> Bool {
        return payerCost != nil
    }

    func hasPaymentMethod() -> Bool {
        return paymentMethod != nil
    }

    func hasCustomerPaymentOption() -> Bool {
        return hasPaymentMethod() && (self.paymentMethod!.isAccountMoney || (hasToken() && !String.isNullOrEmpty(self.token!.cardId)))
    }
}

// MARK: Getters
extension PXPaymentData {
    /**
     getToken
     */
    public func getToken() -> PXToken? {
        return token
    }

    /**
     getPayerCost
     */
    public func getPayerCost() -> PXPayerCost? {
        return payerCost
    }

    /**
     getNumberOfInstallments
     */
    public func getNumberOfInstallments() -> Int {
        guard let installments = payerCost?.installments else {
            return 0
        }
        return installments
    }

    /**
     getIssuer
     */
    public func getIssuer() -> PXIssuer? {
        return issuer
    }

    /**
     getPayer
     */
    public func getPayer() -> PXPayer? {
        return payer
    }

    /**
     getPaymentMethod
     */
    public func getPaymentMethod() -> PXPaymentMethod? {
        return paymentMethod
    }

    /**
     getDiscount
     */
    public func getDiscount() -> PXDiscount? {
        return discount
    }

    /**
     getRawAmount
     */
    public func getRawAmount() -> NSDecimalNumber? {
        return transactionAmount
    }

    /**
     backend payment_option amount
     */
    public func getAmount() -> Double? {
        return amount
    }

    /**
     backend paymentt_option tax_free_amount
     */
    public func getTaxFreeAmount() -> Double? {
        return taxFreeAmount
    }

    /**
     backend paymentt_option no_discount_amount
     */
    public func getNoDiscountAmount() -> Double? {
        return noDiscountAmount
    }

    func getTransactionAmountWithDiscount() -> Double? {
        if let transactionAmount = transactionAmount {
            let transactionAmountDouble = transactionAmount.doubleValue

            if let discount = discount {
                return transactionAmountDouble - discount.couponAmount
            } else {
                return transactionAmountDouble
            }
        }
        return nil
    }
}

// MARK: Setters
extension PXPaymentData {
    func setDiscount(_ discount: PXDiscount?, withCampaign campaign: PXCampaign, consumedDiscount: Bool, discountDescription: PXDiscountDescription? = nil) {
        self.discount = discount
        self.campaign = campaign
        self.consumedDiscount = consumedDiscount
        self.discountDescription = discountDescription
    }

    func updatePaymentDataWith(paymentMethod: PXPaymentMethod?) {
        guard let paymentMethod = paymentMethod else {
            return
        }
        cleanIssuer()
        cleanToken()
        cleanPayerCost()
        cleanPaymentOptionId()
        self.paymentMethod = paymentMethod
    }

    func updatePaymentDataWith(paymentMethod: PXPaymentMethod?, paymentOptionId: String?) {
        guard let paymentMethod = paymentMethod else {
            return
        }
        cleanIssuer()
        cleanToken()
        cleanPayerCost()
        cleanPaymentOptionId()
        self.paymentMethod = paymentMethod
        self.paymentOptionId = paymentOptionId
    }

    func updatePaymentDataWith(token: PXToken?) {
        guard let token = token else {
            return
        }
        self.token = token
    }

    func updatePaymentDataWith(payerCost: PXPayerCost?) {
        guard let payerCost = payerCost else {
            return
        }
        self.payerCost = payerCost
    }

    func updatePaymentDataWith(issuer: PXIssuer?) {
        guard let issuer = issuer else {
            return
        }
        cleanPayerCost()
        self.issuer = issuer
    }

    func updatePaymentDataWith(payer: PXPayer?) {
        guard let payer = payer else {
            return
        }
        self.payer = payer
    }
}

// MARK: Clears
extension PXPaymentData {
    func cleanToken() {
        self.token = nil
    }

    func cleanPayerCost() {
        self.payerCost = nil
    }

    func cleanIssuer() {
        self.issuer = nil
    }

    func cleanPaymentMethod() {
        self.paymentMethod = nil
    }

    func cleanPaymentOptionId() {
        self.paymentOptionId = nil
    }

    func clearCollectedData() {
        clearPaymentMethodData()
        clearPayerData()
    }

    func clearPaymentMethodData() {
        self.paymentMethod = nil
        self.issuer = nil
        self.payerCost = nil
        self.token = nil
        self.transactionDetails = nil
        self.paymentOptionId = nil
        // No borrar el descuento
    }

    func clearPayerData() {
        self.payer = self.payer?.copy() as? PXPayer
        self.payer?.clearCollectedData()
    }

    func clearDiscount() {
        self.discount = nil
        self.campaign = nil
        self.consumedDiscount = nil
        self.discountDescription = nil
    }
}

// MARK: Private
extension PXPaymentData {
    private func processIssuer() {
        if let newIssuer = issuer, newIssuer.id.isEmpty {
            cleanIssuer()
        }
    }
}
