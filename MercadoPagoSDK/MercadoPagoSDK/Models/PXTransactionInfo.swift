import Foundation

public final class PXTransactionInfo: Codable {
    public var bankInfo: PXBankInfo?
    public var financialInstitutionId: String?

    enum CodingKeys: String, CodingKey {
        case bankInfo = "bank_info"
        case financialInstitutionId = "financial_institution_id"
    }
}

public final class PXBankInfo: Codable {
    public var accountId: String?

    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
    }
}
