import Foundation

extension OneTapFlow {
    func returnSelectedPaymentMethod() {
        resultHandler?.finishOneTap(paymentData: model.paymentData, splitAccountMoney: model.splitAccountMoney, pointsAndDiscounts: model.pointsAndDiscounts)
    }
}
