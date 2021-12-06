import Foundation

extension PXOneTapItem {
    func getPaymentOptionId() -> String {
        if let oneTapCard = oneTapCard {
            return oneTapCard.cardId
        }
        return paymentMethodId
    }
}
