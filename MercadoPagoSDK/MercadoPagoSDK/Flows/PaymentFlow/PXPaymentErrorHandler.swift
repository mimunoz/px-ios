import Foundation

@objc protocol PXPaymentErrorHandlerProtocol: NSObjectProtocol {
    func escError(reason: PXESCDeleteReason)
    func exitCheckout()
}
