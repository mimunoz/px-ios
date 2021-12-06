import Foundation
/// :nodoc:
open class PXSite: NSObject, Codable {
    open var id: String!
    open var currencyId: String?
    open var termsAndConditionsUrl: String
    open var shouldWarnAboutBankInterests: Bool?

    public init(id: String, currencyId: String?, termsAndConditionsUrl: String, shouldWarnAboutBankInterests: Bool?) {
        self.id = id
        self.currencyId = currencyId
        self.termsAndConditionsUrl = termsAndConditionsUrl
        self.shouldWarnAboutBankInterests = shouldWarnAboutBankInterests
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case currencyId = "currency_id"
        case termsAndConditionsUrl = "terms_and_conditions_url"
        case shouldWarnAboutBankInterests = "should_warn_about_bank_interests"
    }
}
