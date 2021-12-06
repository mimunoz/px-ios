import UIKit

final class SplitableCardView: UIView {
    // MARK: - Private properties
    private let hStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 8
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        return stack
    }()

    private let vStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 0
        stack.axis = .vertical
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var circleIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = data.icon
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = data.title?.getAttributedString(fontSize: PXLayout.XS_FONT)
        label.textAlignment = data.compactMode ? .left : .center
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = data.subtitle?.getAttributedString(fontSize: PXLayout.XXS_FONT)
        label.textAlignment = data.compactMode ? .left : .center
        return label
    }()

    private lazy var chevronIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ResourceManager.shared.getImage("oneTapArrow_color")
        imageView.contentMode = .center
        return imageView
    }()

    private let data: SplitableCardModel

    // MARK: - Initialization
    init(data: SplitableCardModel) {
        self.data = data
        super.init(frame: .zero)
        setupViewConfiguration()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods
    private func setupUI() {
        subtitleLabel.isHidden = data.subtitle == nil || data.cardHeight < 37
        titleLabel.numberOfLines = data.cardHeight > 73 ? 0 : 1
    }
}

extension SplitableCardView: ViewConfiguration {
    func buildHierarchy() {
        if data.compactMode {
            addSubviews(views: [hStack])
            hStack.addArrangedSubviews(views: [circleIcon, vStack, chevronIcon])
            vStack.addArrangedSubviews(views: [titleLabel, subtitleLabel])
        } else {
            addSubviews(views: [hStack])
            hStack.addArrangedSubviews(views: [vStack])
            vStack.addArrangedSubviews(views: [circleIcon, titleLabel, subtitleLabel])
        }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: topAnchor, constant: data.compactMode ? 8 : 16),
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            chevronIcon.heightAnchor.constraint(equalToConstant: 24),
            chevronIcon.widthAnchor.constraint(equalToConstant: 24),

            circleIcon.heightAnchor.constraint(equalToConstant: data.compactMode ? data.cardHeight / 1.25 : 80),
            circleIcon.widthAnchor.constraint(equalToConstant: data.compactMode ? data.cardHeight / 1.25 : 80)
        ])
    }

    func viewConfigure() {
        backgroundColor = .white
        isAccessibilityElement = true
        accessibilityLabel = data.title?.message
        setupUI()
    }
}
