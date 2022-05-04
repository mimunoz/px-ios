import UIKit

final class NewPaymentMethodLargeCardView: UIView {
    // MARK: - Private properties
    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        return stack
    }()

    private let textsContainerStackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 2
        stack.axis = .vertical
        stack.distribution = .fill
        return stack
    }()

    private let detailContainerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 10
        return stack
    }()

    private lazy var circleIcon: UIImageView = {
        let imageView = UIImageView()
        if let image = data.iconUrl {
            imageView.image = ViewUtils.loadImageFromUrl(image)
        } else {
            imageView.image = data.defaultIcon
        }
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = data.title?.getAttributedString(fontSize: PXLayout.XS_FONT)
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = data.subtitle?.getAttributedString(fontSize: PXLayout.XXS_FONT)
        label.textAlignment = .center
        return label
    }()

    private let data: NewPaymentMethodCardModel

    private struct Sizes {
        static let circleIconWidth: CGFloat = 50
        static let circleIconHeight: CGFloat = 50
        static let containerViewPadding: CGFloat = 16
    }

    // MARK: - Initialization
    init(data: NewPaymentMethodCardModel) {
        self.data = data
        super.init(frame: .zero)
        setupViewConfiguration()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        if data.border != nil {
            addBorderLine()
        }

        if data.shadow {
            addShadow()
        }
    }

    // MARK: - Private methods
    private func setupUI() {
        subtitleLabel.isHidden = data.subtitle == nil
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 2
    }

    private func addBorderLine() {
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = 1
        if let color = data.border?.color {
            dashBorder.strokeColor = UIColor.fromHex(color).cgColor
        }

        let borderType = PXOneTapNewCardBorderType(rawValue: data.border?.type ?? "")

        dashBorder.lineDashPattern = borderType == .solid ? nil: [6, 6]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        dashBorder.path = UIBezierPath(roundedRect: bounds,
                                       cornerRadius: layer.cornerRadius).cgPath
        layer.addSublayer(dashBorder)
    }

    private func addShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.25
        self.layer.shadowOffset = CGSize(width: 0.3, height: 0.3)
    }
}

extension NewPaymentMethodLargeCardView: ViewConfiguration {
    func buildHierarchy() {
        addSubviews(views: [containerStack])
        containerStack.addArrangedSubview(detailContainerStackView)
        detailContainerStackView.addArrangedSubviews(views: [circleIcon, textsContainerStackView])
        textsContainerStackView.addArrangedSubviews(views: [titleLabel, subtitleLabel])
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            containerStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Sizes.containerViewPadding),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Sizes.containerViewPadding),

            circleIcon.heightAnchor.constraint(equalToConstant: Sizes.circleIconHeight),
            circleIcon.widthAnchor.constraint(equalToConstant: Sizes.circleIconWidth)
        ])
    }

    func viewConfigure() {
        if let color = data.backgroundColor {
            backgroundColor = UIColor.fromHex(color)
        } else {
            backgroundColor = .white
        }
        isAccessibilityElement = true
        accessibilityLabel = data.title?.message
        setupUI()
    }
}
