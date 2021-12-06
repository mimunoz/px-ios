import Foundation

extension PXCheckoutStore: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXCheckoutStoreCodingKeys.self)
        try container.encodeIfPresent(self.checkoutPreference?.id, forKey: .checkoutPreference)
        try container.encodeIfPresent(self.checkoutPreference?.merchantOrderId, forKey: .merchantOrderId)
        try container.encodeIfPresent(self.paymentDatas, forKey: .paymentDatas)
        try container.encodeIfPresent(self.validationProgramId, forKey: .validationProgramId)
    }

    enum PXCheckoutStoreCodingKeys: String, CodingKey {
        case checkoutPreference = "pref_id"
        case merchantOrderId = "merchant_order_id"
        case paymentDatas = "payment_data"
        case validationProgramId = "validation_program_id"
    }
}
