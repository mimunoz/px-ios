import UIKit

class PXReceiptComponent: PXComponentizable {
    var props: PXReceiptProps

    init(props: PXReceiptProps) {
        self.props = props
    }
    func render() -> UIView {
        return PXReceiptRenderer().render(self)
    }
}

class PXReceiptProps {
    var dateLabelString: String?
    var receiptDescriptionString: String?
    init(dateLabelString: String? = nil, receiptDescriptionString: String? = nil) {
        self.dateLabelString = dateLabelString
        self.receiptDescriptionString = receiptDescriptionString
    }
}
