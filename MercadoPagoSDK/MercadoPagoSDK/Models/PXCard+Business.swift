import Foundation
/// :nodoc:
extension PXCard: PXCardInformation {
    func getIssuer() -> PXIssuer? {
        return issuer
    }

    func isSecurityCodeRequired() -> Bool {
        if securityCode != nil {
            if securityCode!.length != 0 {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }

    func getFirstSixDigits() -> String {
        return firstSixDigits ?? ""
    }

    func getCardDescription() -> String {
        return "terminada en".localized + " " + lastFourDigits!
    }

    func getPaymentMethod() -> PXPaymentMethod? {
        return self.paymentMethod
    }

    func getCardId() -> String {
        return id ?? ""
    }

    func getPaymentMethodId() -> String {
        return self.paymentMethod?.id ?? ""
    }

    func getPaymentTypeId() -> String {
        return self.paymentMethod?.paymentTypeId ?? ""
    }

    func getCardSecurityCode() -> PXSecurityCode? {
        return self.securityCode
    }

    func getCardBin() -> String? {
        return self.firstSixDigits
    }

    func getCardLastForDigits() -> String {
        return self.lastFourDigits ?? ""
    }

    func setupPaymentMethodSettings(_ settings: [PXSetting]) {
        self.paymentMethod?.settings = settings
    }

    func setupPaymentMethod(_ paymentMethod: PXPaymentMethod) {
        self.paymentMethod = paymentMethod
    }

    func isIssuerRequired() -> Bool {
        return self.issuer == nil
    }

    func canBeClone() -> Bool {
        return false
    }
}
/// :nodoc:
extension PXCard: PaymentOptionDrawable {
    func isDisabled() -> Bool {
        return false
    }

    func getTitle() -> String {
        return getCardDescription()
    }
}
/// :nodoc:
extension PXCard: PaymentMethodOption {
    func getPaymentType() -> String {
        return paymentMethod?.paymentTypeId ?? ""
    }

    func getId() -> String {
        return String(describing: id)
    }

    func getChildren() -> [PaymentMethodOption]? {
        return nil
    }

    func hasChildren() -> Bool {
        return false
    }

    func isCard() -> Bool {
        return true
    }

    func isCustomerPaymentMethod() -> Bool {
        return true
    }
}
