import UIKit

class PXHeaderComponent: PXComponentizable {
    var props: PXHeaderProps

    init (props: PXHeaderProps) {
        self.props = props
    }

    func render() -> UIView {
        return PXHeaderRenderer().render(self)
    }
}

class PXHeaderProps {
    var labelText: NSAttributedString?
    var title: NSAttributedString
    var backgroundColor: UIColor
    var productImage: UIImage?
    var statusImage: UIImage?
    var imageURL: String?
    var closeAction : (() -> Void)?

    init (labelText: NSAttributedString?, title: NSAttributedString, backgroundColor: UIColor, productImage: UIImage?, statusImage: UIImage?, imageURL: String? = nil, closeAction: (() -> Void)?) {
        self.labelText = labelText
        self.title = title
        self.backgroundColor = backgroundColor
        self.productImage = productImage
        self.statusImage = statusImage
        self.imageURL = imageURL
        self.closeAction = closeAction
    }
}
