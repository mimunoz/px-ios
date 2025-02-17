import Foundation

extension MercadoPagoCheckoutViewModel {
    func shouldSkipReviewAndConfirm() -> Bool {
        // Check if the integrator want to skip RyC and we are ready to start a payment.
        // Loyalty usage.
        if let shouldSkipReviewConfirm = paymentPlugin?.shouldSkipUserConfirmation?(), shouldSkipReviewConfirm && paymentData.isComplete() {
            return true
        }
        return false
    }
}
