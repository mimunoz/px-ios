import UIKit

@objc
protocol PaymentOptionDrawable {
    func getId() -> String

    func getTitle() -> String

    func isDisabled() -> Bool
}

@objc
protocol PaymentMethodOption {
    func getId() -> String

    func hasChildren() -> Bool

    func getChildren() -> [PaymentMethodOption]?

    func isCard() -> Bool

    func isCustomerPaymentMethod() -> Bool

    func getPaymentType() -> String

    @objc optional func additionalInfoNeeded() -> Bool
}
