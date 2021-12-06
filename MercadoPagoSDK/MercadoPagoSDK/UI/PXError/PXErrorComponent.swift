import UIKit

class PXErrorComponent: PXComponentizable {
    var props: PXErrorProps

    init(props: PXErrorProps) {
        self.props = props
    }
    func render() -> UIView {
        return PXErrorRenderer().render(component: self)
    }
}

class PXErrorProps {
    var title: NSAttributedString?
    var message: NSAttributedString?
    var secondaryTitle: NSAttributedString?
    var action: PXAction?

    init(title: NSAttributedString? = nil, message: NSAttributedString? = nil, secondaryTitle: NSAttributedString? = nil, action: PXAction? = nil) {
        self.title = title
        self.message = message
        self.action = action
        self.secondaryTitle = secondaryTitle
    }
}
