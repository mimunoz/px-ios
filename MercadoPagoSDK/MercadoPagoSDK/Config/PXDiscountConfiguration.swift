import Foundation

typealias PXDiscountConfigurationType = (discount: PXDiscount?, campaign: PXCampaign?, isAvailable: Bool, reason: PXDiscountReason?, discountDescription: PXDiscountDescription?, discountOverview: PXDiscountOverview?)

/**
 Configuration related to Mercadopago discounts and campaigns. More details: `PXDiscount` and `PXCampaign`.
 */
@objcMembers
open class PXDiscountConfiguration: NSObject, Codable {
    private var discount: PXDiscount?
    private var campaign: PXCampaign?
    private var isAvailable: Bool = true
    private var reason: PXDiscountReason?
    private var discountDescription: PXDiscountDescription?
    private var discountOverview: PXDiscountOverview?

    override init() {
        self.discount = nil
        self.campaign = nil
        isAvailable = false
        self.reason = nil
        self.discountDescription = nil
        self.discountOverview = nil
    }

    /**
     Set Mercado Pago discount that will be applied to total amount.
     When you set a discount with its campaign, we do not check in discount service.
     You have to set a payment processor for discount be applied.
     - parameter discount: Mercado Pago discount.
     - parameter campaign: Discount campaign with discount data.
     */
    public init(discount: PXDiscount, campaign: PXCampaign) {
        self.discount = discount
        self.campaign = campaign
    }

    public init(discount: PXDiscount, campaign: PXCampaign, discountDescription: PXDiscountDescription?, discountOverview: PXDiscountOverview?) {
        self.discount = discount
        self.campaign = campaign
        self.discountDescription = discountDescription
        self.discountOverview = discountOverview
    }

    convenience init(isAvailable: Bool) {
        self.init()
        self.isAvailable = isAvailable
    }

    public enum CodingKeys: String, CodingKey {
        case discount
        case campaign
        case isAvailable = "is_available"
        case reason
        case discountDescription = "discount_description"
        case discountOverview = "discount_overview"
    }

    /**
     When you have the user have wasted all the discounts available
     this kind of configuration will show a generic message to the user.
     */
    public static func initForNotAvailableDiscount() -> PXDiscountConfiguration {
        return PXDiscountConfiguration()
    }

    public func getDiscountOverview() -> PXDiscountOverview? {
        return discountOverview
    }
}

// MARK: - Internals
extension PXDiscountConfiguration {
    func getDiscountConfiguration() -> PXDiscountConfigurationType {
        return (discount, campaign, isAvailable, reason, discountDescription, discountOverview)
    }
}
