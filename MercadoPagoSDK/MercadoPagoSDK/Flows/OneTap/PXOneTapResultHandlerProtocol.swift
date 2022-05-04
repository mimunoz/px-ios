import Foundation

protocol PXOneTapResultHandlerProtocol: NSObjectProtocol {
    func finishOneTap(paymentResult: PaymentResult, instructionsInfo: PXInstruction?, pointsAndDiscounts: PXPointsAndDiscounts?, paymentOptionSelected: PaymentMethodOption?)
    func finishOneTap(businessResult: PXBusinessResult, paymentData: PXPaymentData, splitAccountMoney: PXPaymentData?, pointsAndDiscounts: PXPointsAndDiscounts?)
    func finishOneTap(paymentData: PXPaymentData, splitAccountMoney: PXPaymentData?, pointsAndDiscounts: PXPointsAndDiscounts?)
    func refreshInitFlow(cardId: String)
    func refreshAddAccountFlow(accountId: String)
    func cancelOneTap()
    func cancelOneTapForNewPaymentMethodSelection()
    func exitCheckout()
}
