import UIKit

class PXUIImageView: UIImageView {
    private var currentImage: UIImage?
    private var fadeInEnabled = false
    override var image: UIImage? {
        set {
            loadImage(image: newValue)
        }
        get {
            return currentImage
        }
    }
    private var shouldAddInsets: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentMode = .scaleAspectFit
    }

    override init(image: UIImage?) {
        super.init(image: image)
        self.contentMode = .scaleAspectFit
    }

    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        self.contentMode = .scaleAspectFit
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(image: UIImage?,
                     size: CGFloat = 48.0,
                     showAsCircle: Bool = true,
                     showBorder: Bool = true,
                     borderWidth: CGFloat = 1,
                     borderColor: CGColor = UIColor.black.withAlphaComponent(0.1).cgColor,
                     contentMode: UIView.ContentMode = .scaleAspectFit,
                     shouldAddInsets: Bool = false) {
        self.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        if showAsCircle {
            layer.masksToBounds = false
            layer.cornerRadius = size / 2
        }
        if showBorder {
            layer.borderWidth = 1
            layer.borderColor = borderColor
        }
        enableFadeIn()
        clipsToBounds = true
        self.contentMode = contentMode
        self.shouldAddInsets = shouldAddInsets
        self.image = image
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        PXLayout.setHeight(owner: self, height: size).isActive = true
        PXLayout.setWidth(owner: self, width: size).isActive = true
    }

    private func loadImage(image: UIImage?) {
        if let pxImage = image as? PXUIImage {
            let placeholder = buildPlaceholderView(image: pxImage)
            let fallback = buildFallbackView(image: pxImage)
            Utils().loadImageFromURLWithCache(withUrl: pxImage.url, targetView: self, placeholderView: placeholder, fallbackView: fallback, fadeInEnabled: fadeInEnabled, shouldAddInsets: shouldAddInsets) { [weak self] image in
                self?.currentImage = image
            }
        } else {
            currentImage = resizedImage(image: image)
        }
    }

    private func resizedImage(image: UIImage?) -> UIImage? {
        if shouldAddInsets {
            return image?.addInset(percentage: 58)
        }
        return image
    }

    private func buildPlaceholderView(image: PXUIImage) -> UIView? {
        if let placeholderString = image.placeholder {
            return buildLabel(with: placeholderString)
        } else {
            return buildEmptyView()
        }
    }

    private func buildFallbackView(image: PXUIImage) -> UIView? {
        if let fallbackString = image.fallback {
            return buildLabel(with: fallbackString)
        } else {
            return buildEmptyView()
        }
    }

    private func buildEmptyView() -> UIView {
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.alpha = 0.2
        return view
    }

    private func buildLabel(with text: String?) -> UILabel? {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Utils.getFont(size: PXLayout.XS_FONT)
        label.textColor = ThemeManager.shared.labelTintColor()
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        label.text = text
        return label
    }

    func enableFadeIn() {
        fadeInEnabled = true
    }

    func disableFadeIn() {
        fadeInEnabled = false
    }
}
