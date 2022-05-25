import Foundation

protocol PXPaymentResultHandlerProtocol: NSObjectProtocol {
    func finishPaymentFlow(paymentResult: PaymentResult, instructionsInfo: PXInstruction?, pointsAndDiscounts: PXPointsAndDiscounts?, checkoutPreference: PXCheckoutPreference?)
    func finishPaymentFlow(businessResult: PXBusinessResult, pointsAndDiscounts: PXPointsAndDiscounts?)
    func finishPaymentFlow(error: MPSDKError)
}
