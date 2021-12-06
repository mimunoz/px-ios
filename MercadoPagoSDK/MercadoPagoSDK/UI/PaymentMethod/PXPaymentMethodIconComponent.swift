import UIKit

class PXPaymentMethodIconComponent: PXComponentizable {
    var props: PXPaymentMethodIconProps

    init(props: PXPaymentMethodIconProps) {
        self.props = props
    }
    func render() -> UIView {
        return PXPaymentMethodIconRenderer().render(component: self)
    }
}

class PXPaymentMethodIconProps {
    var paymentMethodIcon: UIImage?

    init(paymentMethodIcon: UIImage?) {
        self.paymentMethodIcon = paymentMethodIcon
    }
}
