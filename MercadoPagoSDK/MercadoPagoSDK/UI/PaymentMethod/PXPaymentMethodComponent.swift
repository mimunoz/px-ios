import UIKit

class PXPaymentMethodComponent: NSObject, PXComponentizable {
    var props: PXPaymentMethodProps

    init(props: PXPaymentMethodProps) {
       self.props = props
    }

    func render() -> UIView {
        return PXPaymentMethodComponentRenderer().render(component: self)
    }
}

// MARK: - Helper functions
extension PXPaymentMethodComponent {
    func getPaymentMethodIconComponent() -> PXPaymentMethodIconComponent {
        let paymentMethodIconProps = PXPaymentMethodIconProps(paymentMethodIcon: self.props.paymentMethodIcon)
        let paymentMethodIconComponent = PXPaymentMethodIconComponent(props: paymentMethodIconProps)
        return paymentMethodIconComponent
    }
}
