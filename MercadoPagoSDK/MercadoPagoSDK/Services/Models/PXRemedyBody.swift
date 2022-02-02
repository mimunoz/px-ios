import Foundation

struct PXRemedyBody: Codable {
    let customStringConfiguration: PXCustomStringConfiguration?
    let payerPaymentMethodRejected: PXPayerPaymentMethodRejected?
    let alternativePayerPaymentMethods: [PXRemedyPaymentMethod]?
}

struct PXPayerPaymentMethodRejected: Codable {
    let bin: String?
    let customOptionId: String?
    let paymentMethodId: String?
    let paymentTypeId: String?
    let issuerName: String?
    let lastFourDigit: String?
    let securityCodeLocation: String?
    let securityCodeLength: Int?
    let totalAmount: Double?
    let installments: Int?
    let escStatus: String?
    let paymentMethodName: String?
    let bankInfo: PXPayerPaymentMethodBankInfo?
}

struct PXCustomStringConfiguration: Codable {
    let customPayButtonProgessText: String?
    let customPayButtonText: String?
    let totalDescriptionText: String?
}
