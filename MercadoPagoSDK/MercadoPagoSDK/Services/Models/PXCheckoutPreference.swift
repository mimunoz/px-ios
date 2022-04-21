import Foundation

/**
 Model that represents `curl -X OPTIONS` (https://api.mercadopago.com/checkout/preferences) `| json_pp`
 It can be not exactly the same because exists custom configurations for open Preference.
 Some values like: binary mode are not present on API call.
 */
@objcMembers open class PXCheckoutPreference: NSObject, Codable {
    // MARK: Public accessors.
    /**
     id
     */
    open var id: String!
    /**
     items
     */
    open var items: [PXItem] = []
    /**
    payer
     */
    open var payer: PXPayer!
    /**
     paymentPreference
     */
    open var paymentPreference: PXPaymentPreference = PXPaymentPreference()
    /**
        siteId
     */
    open var siteId: String = ""
    /**
     expirationDateTo
     */
    open var expirationDateTo: Date?
    /**
     expirationDateFrom
     */
    open var expirationDateFrom: Date?
    /**
     site
     */
    open var site: PXSite?
    /**
     differentialPricing
     */
    open var differentialPricing: PXDifferentialPricing?
    /**
     marketplace
     */
    open var marketplace: String? = "NONE"
    /**
     branch id
     */
    open var branchId: String?
    /**
     operationType
     */
    open var operationType: String?
    /**
     processing mode
     */
    open var processingModes: [String] = PXServicesURLConfigs.MP_DEFAULT_PROCESSING_MODES
    /**
     Additional info - json string.
     */
    open var additionalInfo: String? {
        didSet {
            self.populateAdditionalInfoModel()
        }
    }

    /**
    Collector ID
    */
    open var collectorId: String?

    open var backUrls: PXBackUrls?
    open var redirectUrls: PXBackUrls?
    open var autoReturn: String?
    /**
     Order id
     */
    open var orderId: Int?
    /**
     Merchant Order id
     */
    open var merchantOrderId: Int?

    var binaryModeEnabled: Bool = false
    var pxAdditionalInfo: PXAdditionalInfo?

    // MARK: Initialization
    /**
     Mandatory init.
     - parameter preferenceId: The preference id that represents the payment information.
     */
    public init(preferenceId: String) {
        self.id = preferenceId
    }

    /**
     Mandatory init.
     Builder for custom CheckoutPreference construction.
     It should be only used if you are processing the payment
     with a Payment processor. Otherwise you should use the ID constructor.
     - parameter siteId: Preference site.
     - parameter payerEmail: Payer email.
     - parameter items: Items to pay.
     */
    public init(siteId: String, payerEmail: String, items: [PXItem]) {
        self.items = items
        self.siteId = siteId
        self.payer = PXPayer(email: payerEmail)
    }

    init(id: String, items: [PXItem], payer: PXPayer, paymentPreference: PXPaymentPreference?, siteId: String, expirationDateTo: Date?, expirationDateFrom: Date?, site: PXSite?, differentialPricing: PXDifferentialPricing?, marketplace: String?, branchId: String?, operationType: String?, processingModes: [String] = PXServicesURLConfigs.MP_DEFAULT_PROCESSING_MODES, collectorId: String?, orderId: Int? = nil, merchantOrderId: Int? = nil) {
        self.id = id
        self.items = items
        self.payer = payer
        if let payPref = paymentPreference {
            self.paymentPreference = payPref
        }
        self.siteId = siteId
        self.expirationDateTo = expirationDateTo
        self.expirationDateFrom = expirationDateFrom
        self.site = site
        self.differentialPricing = differentialPricing
        let sanitizedProcessingModes = processingModes.isEmpty ? PXServicesURLConfigs.MP_DEFAULT_PROCESSING_MODES : processingModes
        self.processingModes = sanitizedProcessingModes
        self.branchId = branchId
        self.operationType = operationType
        self.marketplace = marketplace
        self.collectorId = collectorId
        self.orderId = orderId
        self.merchantOrderId = merchantOrderId
    }

    /// :nodoc:
    public enum CodingKeys: String, CodingKey {
        case id
        case items
        case payer = "payer"
        case paymentPreference = "payment_methods"
        case siteId = "site_id"
        case expirationDateTo = "expiration_date_to"
        case expirationDateFrom = "expiration_date_from"
        case differentialPricing = "differential_pricing"
        case site
        case marketplace
        case additionalInfo = "additional_info"
        case backUrls = "back_urls"
        case redirectUrls = "redirect_urls"
        case autoReturn = "auto_return"
        case branchId = "branch_id"
        case operationType = "operation_type"
        case processingModes = "processing_modes"
        case collectorId = "collector_id"
        case orderId = "order_id"
        case merchantOrderId = "merchant_order_id"
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id: String? = try container.decodeIfPresent(String.self, forKey: .id)
        let branchId: String? = try container.decodeIfPresent(String.self, forKey: .branchId)
        let operationType: String? = try container.decodeIfPresent(String.self, forKey: .operationType)
        let processingModes: [String] = try container.decodeIfPresent([String].self, forKey: .processingModes) ?? PXServicesURLConfigs.MP_DEFAULT_PROCESSING_MODES
        let items: [PXItem] = try container.decodeIfPresent([PXItem].self, forKey: .items) ?? []
        let paymentPreference: PXPaymentPreference? = try container.decodeIfPresent(PXPaymentPreference.self, forKey: .paymentPreference)
        let payer: PXPayer = try container.decode(PXPayer.self, forKey: .payer)
        let expirationDateTo: Date? = try container.decodeDateFromStringIfPresent(forKey: .expirationDateTo)
        let expirationDateFrom: Date? = try container.decodeDateFromStringIfPresent(forKey: .expirationDateFrom)
        let siteId: String = try container.decodeIfPresent(String.self, forKey: .siteId) ?? ""
        let site: PXSite? = try container.decodeIfPresent(PXSite.self, forKey: .site)
        let differentialPricing: PXDifferentialPricing? = try container.decodeIfPresent(PXDifferentialPricing.self, forKey: .differentialPricing)
        let marketplace: String? = try container.decodeIfPresent(String.self, forKey: .marketplace)
        let collectorIdNumber: Int? = try container.decodeIfPresent(Int.self, forKey: .collectorId)
        let collectorIdString: String? = collectorIdNumber?.stringValue
        let orderId: Int? = try container.decodeIfPresent(Int.self, forKey: .orderId)
        let merchantOrderId: Int? = try container.decodeIfPresent(Int.self, forKey: .merchantOrderId)

        self.init(id: PXCheckoutPreference.getIdOrDefaultValue(id), items: items, payer: payer, paymentPreference: paymentPreference, siteId: siteId, expirationDateTo: expirationDateTo, expirationDateFrom: expirationDateFrom, site: site, differentialPricing: differentialPricing, marketplace: marketplace, branchId: branchId, operationType: operationType, processingModes: processingModes, collectorId: collectorIdString, orderId: orderId, merchantOrderId: merchantOrderId)

        self.additionalInfo = try container.decodeIfPresent(String.self, forKey: .additionalInfo)
        populateAdditionalInfoModel()
        self.backUrls = try container.decodeIfPresent(PXBackUrls.self, forKey: .backUrls)
        self.redirectUrls = try container.decodeIfPresent(PXBackUrls.self, forKey: .redirectUrls)
        self.autoReturn = try container.decodeIfPresent(String.self, forKey: .autoReturn)
    }
}

extension PXCheckoutPreference {
    static func getIdOrDefaultValue(_ targetId: String?) -> String {
        guard let remoteId = targetId else { return "" }
        return remoteId
    }
}
