import Foundation
/// :nodoc:
@objcMembers
open class PXTransactionDetails: NSObject, Codable {
    open var externalResourceUrl: String?
    open var financialInstitution: String?
    open var installmentAmount: Double?
    open var netReceivedAmount: Double?
    open var overpaidAmount: Double?
    open var totalPaidAmount: Double?
    open var paymentMethodReferenceId: String?

    public init(externalResourceUrl: String?, financialInstitution: String?, installmentAmount: Double?, netReivedAmount: Double?, overpaidAmount: Double?, totalPaidAmount: Double?, paymentMethodReferenceId: String?) {
        self.externalResourceUrl = externalResourceUrl
        self.financialInstitution = financialInstitution
        self.installmentAmount = installmentAmount
        self.netReceivedAmount = netReivedAmount
        self.overpaidAmount = overpaidAmount
        self.totalPaidAmount = totalPaidAmount
        self.paymentMethodReferenceId = paymentMethodReferenceId
    }

    public enum PXTransactionDetailsKeys: String, CodingKey {
        case externalResourceUrl = "external_resource_url"
        case financialInstitution = "financial_institution"
        case installmentAmount = "installment_amount"
        case netReivedAmount = "net_received_amount"
        case overPaidAmount = "overpaid_amount"
        case totalPaidAmount = "total_paid_amount"
        case paymentMethodReferenceId = "payment_method_reference_id"
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXTransactionDetailsKeys.self)
        let externalResourceUrl: String? = try container.decodeIfPresent(String.self, forKey: .externalResourceUrl)
        let financialInstitution: String? = try container.decodeIfPresent(String.self, forKey: .financialInstitution)
        let installmentAmount: Double? = try container.decodeIfPresent(Double.self, forKey: .installmentAmount)
        let netReivedAmount: Double? = try container.decodeIfPresent(Double.self, forKey: .netReivedAmount)
        let overpaidAmount: Double? = try container.decodeIfPresent(Double.self, forKey: .overPaidAmount)
        let totalPaidAmount: Double? = try container.decodeIfPresent(Double.self, forKey: .totalPaidAmount)
        let paymentMethodReferenceId: String? = try container.decodeIfPresent(String.self, forKey: .paymentMethodReferenceId)

        self.init(externalResourceUrl: externalResourceUrl, financialInstitution: financialInstitution, installmentAmount: installmentAmount, netReivedAmount: netReivedAmount, overpaidAmount: overpaidAmount, totalPaidAmount: totalPaidAmount, paymentMethodReferenceId: paymentMethodReferenceId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXTransactionDetailsKeys.self)
        try container.encodeIfPresent(self.externalResourceUrl, forKey: .externalResourceUrl)
        try container.encodeIfPresent(self.financialInstitution, forKey: .financialInstitution)
        try container.encodeIfPresent(self.installmentAmount, forKey: .installmentAmount)
        try container.encodeIfPresent(self.netReceivedAmount, forKey: .netReivedAmount)
        try container.encodeIfPresent(self.overpaidAmount, forKey: .overPaidAmount)
        try container.encodeIfPresent(self.totalPaidAmount, forKey: .totalPaidAmount)
        try container.encodeIfPresent(self.paymentMethodReferenceId, forKey: .paymentMethodReferenceId)
    }
}
