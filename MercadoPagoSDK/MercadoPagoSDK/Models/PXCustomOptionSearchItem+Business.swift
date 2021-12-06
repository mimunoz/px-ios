import Foundation
extension PXCustomOptionSearchItem {
    func getCustomerPaymentMethod() -> CustomerPaymentMethod {
        return CustomerPaymentMethod(id: id, paymentMethodId: paymentMethodId ?? "", paymentMethodTypeId: paymentTypeId ?? "", description: _description ?? "", issuer: issuer, firstSixDigits: firstSixDigits, lastFourDigits: lastFourDigits)
    }
}
