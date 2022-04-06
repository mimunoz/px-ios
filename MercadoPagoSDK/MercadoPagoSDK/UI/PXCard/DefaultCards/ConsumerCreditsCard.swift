import MLCardDrawer

final class ConsumerCreditsCard: NSObject, CustomCardDrawerUI {
    private lazy var consumerCreditsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Utils.getSemiBoldFont(size: PXLayout.XS_FONT)
        label.numberOfLines = 2
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var highlightLabel: HighlightLabel = {
        let highlightLabel = HighlightLabel()
        highlightLabel.translatesAutoresizingMaskIntoConstraints = false
        return highlightLabel
    }()

    weak var delegate: PXTermsAndConditionViewDelegate?

    // CustomCardDrawerUI
    let placeholderName = ""
    let placeholderExpiration = ""
    let bankImage: UIImage? = nil
    var cardPattern = [0]
    let cardFontColor: UIColor = .white
    let cardLogoImage: UIImage?
    let cardBackgroundColor: UIColor = #colorLiteral(red: 0.0431372549, green: 0.7065708517, blue: 0.7140994326, alpha: 1)
    let securityCodeLocation: MLCardSecurityCodeLocation = .back
    let defaultUI = false
    let securityCodePattern = 3
    let fontType: String = "light"
    let ownOverlayImage: UIImage?
    var ownGradient: CAGradientLayer = CAGradientLayer()
    private let highlightText: PXText?

    init(_ creditsViewModel: PXCreditsViewModel, isDisabled: Bool, highlightText: PXText? = nil) {
        ownOverlayImage = ResourceManager.shared.getImage(isDisabled ? "Overlay" : "creditsOverlayMask")
        ownGradient = ConsumerCreditsCard.getCustomGradient(creditsViewModel)

        cardLogoImage = creditsViewModel.needsTermsAndConditions ? nil : ResourceManager.shared.getImage("consumerCreditsOneTap")

        self.highlightText = highlightText
    }

    static func getCustomGradient(_ creditsViewModel: PXCreditsViewModel) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = creditsViewModel.getCardColors()
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.6, y: 0.5)
        return gradient
    }
}

// MARK: Render
extension ConsumerCreditsCard {
    func render(containerView: UIView, creditsViewModel: PXCreditsViewModel, isDisabled: Bool, size: CGSize, selectedInstallments: Int?, cardType: MLCardDrawerTypeV3? = .large) {
        var creditsImageHeight: CGFloat = size.height * 0.20
        var creditsImageWidth: CGFloat = size.height * 0.60
        let sideMargins: CGFloat = 16
        var verticalMargin: CGFloat = 0
        let verticalMarginMin: CGFloat = 12
        let creditsImageSmallHeight: CGFloat = 20
        let creditsImageSmallWidth: CGFloat = 71
        let scrollBarCompensation: CGFloat = 4

        if !isDisabled {
            ownGradient.frame = containerView.frame
            if creditsViewModel.needsTermsAndConditions {
                let consumerCreditsImageRaw = ResourceManager.shared.getImage("consumerCreditsCardOneTap")
                consumerCreditsImage.image = isDisabled ? consumerCreditsImageRaw?.imageGreyScale() : consumerCreditsImageRaw
                containerView.addSubview(consumerCreditsImage)

                let termsAndConditionsText = createTermsAndConditionsText(terms: creditsViewModel.displayInfo.bottomText, selectedInstallments: selectedInstallments, textColor: .white, linkColor: .white)
                containerView.addSubview(termsAndConditionsText)

                if cardType != .small {
                    verticalMargin = sideMargins
                    titleLabel.text = creditsViewModel.displayInfo.topText.text
                    containerView.addSubview(titleLabel)
                    NSLayoutConstraint.activate([
                        PXLayout.pinLeft(view: titleLabel, to: consumerCreditsImage),
                        PXLayout.pinRight(view: titleLabel, to: containerView, withMargin: sideMargins),
                        PXLayout.put(view: titleLabel, onBottomOf: consumerCreditsImage, withMargin: sideMargins, relation: .greaterThanOrEqual),
                        PXLayout.centerVertically(view: titleLabel, to: containerView)
                    ])
                } else {
                    creditsImageHeight = creditsImageSmallHeight
                    creditsImageWidth = creditsImageSmallWidth
                    verticalMargin = verticalMarginMin
                }

                NSLayoutConstraint.activate([
                    PXLayout.pinBottom(view: termsAndConditionsText, to: containerView, withMargin: verticalMargin - scrollBarCompensation),
                    PXLayout.pinLeft(view: termsAndConditionsText, to: consumerCreditsImage),
                    PXLayout.pinRight(view: termsAndConditionsText, to: containerView, withMargin: sideMargins),

                    PXLayout.setWidth(owner: consumerCreditsImage, width: creditsImageWidth),
                    PXLayout.setHeight(owner: consumerCreditsImage, height: creditsImageHeight),
                    PXLayout.pinLeft(view: consumerCreditsImage, to: containerView, withMargin: sideMargins),
                    PXLayout.pinTop(view: consumerCreditsImage, to: containerView, withMargin: verticalMargin)
                ])

                if let highlightText = highlightText {
                    setupHighlightLabel(in: containerView, text: highlightText)
                }
            }
        }
    }

    fileprivate func createTermsAndConditionsText(terms: PXTermsDto, selectedInstallments: Int?, textColor: UIColor, linkColor: UIColor) -> UITextView {
        let termsAndConditionsText = PXTermsAndConditionsTextView(terms: terms, selectedInstallments: selectedInstallments, textColor: textColor, linkColor: linkColor)

        termsAndConditionsText.font = Utils.getFont(size: PXLayout.XXXS_FONT)
        termsAndConditionsText.textAlignment = .left
        termsAndConditionsText.textContainer.lineFragmentPadding = 0
        termsAndConditionsText.isScrollEnabled = false
        termsAndConditionsText.sizeToFit()
        termsAndConditionsText.delegate = self

        return termsAndConditionsText
    }
}

// MARK: UITextViewDelegate
extension ConsumerCreditsCard: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let title = String("px_cc_terms_and_conditions".localized).capitalized
        delegate?.shouldOpenTermsCondition(title, url: URL)

        return false
    }
}

// MARK: private
private extension ConsumerCreditsCard {
    func setupHighlightLabel(in container: UIView, text: PXText) {
        container.addSubview(highlightLabel)

        NSLayoutConstraint.activate([
            highlightLabel.topAnchor.constraint(equalTo: container.topAnchor),
            highlightLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            highlightLabel.heightAnchor.constraint(equalToConstant: HighlightLabel.Layout.componentHeight)
        ])
        highlightLabel.setText(text)
    }
}
