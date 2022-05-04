public struct PXModal: Codable {
    let title: PXText?
    let description: PXText?
    let mainButton: PXRemoteAction?
    let secondaryButton: PXRemoteAction?
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case mainButton = "main_button"
        case secondaryButton = "secondary_button"
        case imageUrl = "image_url"
    }
}

import Foundation
/// :nodoc:
final class PXInitDTO: NSObject, Codable {
    public var preference: PXCheckoutPreference?
    public var oneTap: [PXOneTapDto]?
    public var currency: PXCurrency
    public var site: PXSite
    public var generalCoupon: String
    public var coupons: [String: PXDiscountConfiguration]
    public var payerPaymentMethods: [PXCustomOptionSearchItem] = []
    public var availablePaymentMethods: [PXPaymentMethod] = []
    public var selectedDiscountConfiguration: PXDiscountConfiguration?
    public var experiments: [PXExperiment]?
    public var payerCompliance: PXPayerCompliance?
    public var configurations: PXInitConfigurations?
    var modals: [String: PXModal]?
    public var customCharges: PXCustomCharges?
    public var retry: PXRetry?

    public init(preference: PXCheckoutPreference?,
                oneTap: [PXOneTapDto]?,
                currency: PXCurrency,
                site: PXSite,
                generalCoupon: String,
                coupons: [String: PXDiscountConfiguration],
                payerPaymentMethods: [PXCustomOptionSearchItem],
                availablePaymentMethods: [PXPaymentMethod],
                experiments: [PXExperiment]?,
                payerCompliance: PXPayerCompliance?,
                configurations: PXInitConfigurations?,
                modals: [String: PXModal],
                customCharges: PXCustomCharges?,
                retry: PXRetry?) {
        self.preference = preference
        self.oneTap = oneTap
        self.payerCompliance = payerCompliance
        self.currency = currency
        self.site = site
        self.generalCoupon = generalCoupon
        self.coupons = coupons
        self.payerPaymentMethods = payerPaymentMethods
        self.availablePaymentMethods = availablePaymentMethods
        self.experiments = experiments
        self.configurations = configurations
        self.modals = modals
        self.customCharges = customCharges
        self.retry = retry

        if let selectedDiscountConfiguration = coupons[generalCoupon] {
            self.selectedDiscountConfiguration = selectedDiscountConfiguration
        }
    }

    enum CodingKeys: String, CodingKey {
        case preference
        case oneTap = "one_tap"
        case payerCompliance = "payer_compliance"
        case currency
        case site
        case generalCoupon = "general_coupon"
        case coupons
        case payerPaymentMethods = "payer_payment_methods"
        case availablePaymentMethods = "available_payment_methods"
        case experiments
        case configurations
        case modals
        case customCharges = "custom_charges"
        case retry
    }

    func getPaymentOptionsCount() -> Int {
        return payerPaymentMethods.count
    }

    func hasCheckoutDefaultOption() -> Bool {
        return oneTap != nil
    }

    func deleteCheckoutDefaultOption() {
        oneTap = nil
    }

    func getPaymentMethodInExpressCheckout(customerPaymentMethod: CustomerPaymentMethod) -> PXOneTapDto? {
        guard let expressResponse = oneTap else { return nil }
        for expressNode in expressResponse {
            guard let paymentMethodId = expressNode.paymentMethodId else {
                return nil
            }

            var cardCaseCondition = false
            if let oneTapCard = expressNode.oneTapCard,
               oneTapCard.cardId == customerPaymentMethod.getId(),
               paymentMethodId == customerPaymentMethod.getPaymentMethodId(),
               expressNode.paymentTypeId == customerPaymentMethod.getPaymentTypeId() {
                cardCaseCondition = true
            }
            let creditsCaseCondition = PXPaymentTypes(rawValue: paymentMethodId) == PXPaymentTypes.CONSUMER_CREDITS
            if cardCaseCondition || creditsCaseCondition {
                return expressNode
            }
        }
        return nil
    }

    func getPayerPaymentMethod(id: String?, paymentMethodId: String?, paymentTypeId: String?) -> PXCustomOptionSearchItem? {
        return payerPaymentMethods.first(where: { $0.id == id && $0.paymentMethodId == paymentMethodId && $0.paymentTypeId == paymentTypeId })
    }
    
    func retryIsNeeded() -> Bool {
        self.retry?.isNeeded ?? false
    }
}
