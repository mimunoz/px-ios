import Foundation

// MARK: - MoneyIn "ChoExpress"
extension PXPaymentMethodSelectorViewModel {
    func getPreferenceDefaultPaymentOption() -> PaymentMethodOption? {
        guard let cardId = amountHelper.preference.paymentPreference.cardId else {
            return nil
        }

        amountHelper.preference.clearCardId()

        if let options = self.paymentMethodOptions {
            let optionsFound = options.filter { (paymentMethodOption: PaymentMethodOption) -> Bool in
                return paymentMethodOption.getId() == cardId
            }
            if let paymentOption = optionsFound.first {
                return paymentOption
            }
        }

        if self.search != nil {
            guard let customerPaymentMethods = customPaymentOptions else {
                return nil
            }
            return customerPaymentMethods.first(where: { return $0.getCardId() == cardId })
        }

        return nil
    }
}
