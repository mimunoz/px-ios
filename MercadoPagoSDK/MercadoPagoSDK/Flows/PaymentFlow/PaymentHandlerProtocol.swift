import Foundation

protocol PaymentHandlerProtocol {
    func handlePayment(payment: PXPayment)
    func handlePayment(business: PXBusinessResult)
    func handlePayment(basePayment: PXBasePayment)
}
