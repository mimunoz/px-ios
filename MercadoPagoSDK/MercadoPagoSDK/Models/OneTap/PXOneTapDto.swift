import Foundation
/// :nodoc:
open class PXOneTapDto: NSObject, Codable {
    open var paymentMethodId: String?
    open var paymentTypeId: String?
    open var offlineTapCard: PXOneTapOfflineCard?
    open var oneTapCard: PXOneTapCardDto?
    open var oneTapCreditsInfo: PXOneTapCreditsDto?
    open var accountMoney: PXAccountMoneyDto?
    open var newCard: PXOneTapNewPaymentMethodDto?
    open var benefits: PXBenefits?
    open var status: PXStatus
    open var offlineMethods: PXOneTapNewPaymentMethodDto?
    open var behaviours: [String: PXBehaviour]?
    open var displayInfo: PXOneTapDisplayInfo?
    open var applications: [PXOneTapApplication]?
    open var bankTransfer: BankTransferDto?

    public init(
        paymentMethodId: String?,
        paymentTypeId: String?,
        oneTapCard: PXOneTapCardDto?,
        oneTapCreditsInfo: PXOneTapCreditsDto?,
        accountMoney: PXAccountMoneyDto?,
        newCard: PXOneTapNewPaymentMethodDto?,
        status: PXStatus,
        benefits: PXBenefits? = nil,
        offlineMethods: PXOneTapNewPaymentMethodDto?,
        behaviours: [String: PXBehaviour]?,
        displayInfo: PXOneTapDisplayInfo?,
        applications: [PXOneTapApplication]?,
        bankTransfer: BankTransferDto?
    ) {
        self.paymentMethodId = paymentMethodId
        self.paymentTypeId = paymentTypeId
        self.oneTapCard = oneTapCard
        self.oneTapCreditsInfo = oneTapCreditsInfo
        self.accountMoney = accountMoney
        self.newCard = newCard
        self.status = status
        self.benefits = benefits
        self.offlineMethods = offlineMethods
        self.behaviours = behaviours
        self.displayInfo = displayInfo
        self.applications = applications
        self.bankTransfer = bankTransfer
    }

    public enum CodingKeys: String, CodingKey {
        case paymentMethodId = "payment_method_id"
        case paymentTypeId = "payment_type_id"
        case offlineTapCard = "offline_method_card"
        case oneTapCard = "card"
        case oneTapCreditsInfo = "consumer_credits"
        case accountMoney = "account_money"
        case newCard = "new_card"
        case status
        case benefits = "benefits"
        case offlineMethods = "offline_methods"
        case behaviours
        case displayInfo = "display_info"
        case applications = "applications"
        case bankTransfer = "bank_transfer"
    }
}
