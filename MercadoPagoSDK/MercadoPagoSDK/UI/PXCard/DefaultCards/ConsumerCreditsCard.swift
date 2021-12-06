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
        label.textAlignment = .center
        label.font = label.font.withSize(PXLayout.XXXS_FONT)
        label.numberOfLines = 2
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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

    init(_ creditsViewModel: PXCreditsViewModel, isDisabled: Bool) {
        ownOverlayImage = ResourceManager.shared.getImage(isDisabled ? "Overlay" : "creditsOverlayMask")
        ownGradient = ConsumerCreditsCard.getCustomGradient(creditsViewModel)

        cardLogoImage = creditsViewModel.needsTermsAndConditions ? nil : ResourceManager.shared.getImage("consumerCreditsOneTap")
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
        let creditsImageHeight: CGFloat = size.height * 0.35
        let creditsImageWidth: CGFloat = size.height * 0.60
        let margins: CGFloat = 16
        let termsAndConditionsTextHeight: CGFloat = 50
        var verticalMargin: CGFloat = 0

        if !isDisabled {
            if creditsViewModel.needsTermsAndConditions {
                let consumerCreditsImageRaw = ResourceManager.shared.getImage("consumerCreditsOneTap")
                consumerCreditsImage.image = isDisabled ? consumerCreditsImageRaw?.imageGreyScale() : consumerCreditsImageRaw
                containerView.addSubview(consumerCreditsImage)

                let termsAndConditionsText = PXTermsAndConditionsTextView(terms: creditsViewModel.displayInfo.bottomText, selectedInstallments: selectedInstallments, textColor: .white, linkColor: .white)
                termsAndConditionsText.delegate = self
                containerView.addSubview(termsAndConditionsText)

                if cardType != .small {
                    verticalMargin = -creditsImageHeight / 2

                    titleLabel.text = creditsViewModel.displayInfo.topText.text
                    containerView.addSubview(titleLabel)
                    NSLayoutConstraint.activate([
                        PXLayout.pinLeft(view: titleLabel, to: containerView, withMargin: margins),
                        PXLayout.pinRight(view: titleLabel, to: containerView, withMargin: margins),
                        PXLayout.put(view: titleLabel, onBottomOf: consumerCreditsImage)
                    ])
                } else {
                    verticalMargin = -creditsImageHeight / 2 - 12
                }

                NSLayoutConstraint.activate([
                    PXLayout.pinBottom(view: termsAndConditionsText, to: containerView, withMargin: margins - PXLayout.XXXS_MARGIN),
                    PXLayout.pinLeft(view: termsAndConditionsText, to: containerView, withMargin: margins),
                    PXLayout.pinRight(view: termsAndConditionsText, to: containerView, withMargin: margins),
                    PXLayout.setHeight(owner: termsAndConditionsText, height: termsAndConditionsTextHeight),

                    PXLayout.setWidth(owner: consumerCreditsImage, width: creditsImageWidth),
                    PXLayout.setHeight(owner: consumerCreditsImage, height: creditsImageHeight),
                    PXLayout.centerHorizontally(view: consumerCreditsImage),
                    PXLayout.centerVertically(view: consumerCreditsImage, to: containerView, withMargin: verticalMargin)
                ])
            }
        }
    }
}

// MARK: UITextViewDelegate
extension ConsumerCreditsCard: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            if let range = Range(characterRange, in: textView.text),
                let text = textView.text?[range] {
                let title = String(text).capitalized
                delegate?.shouldOpenTermsCondition(title, url: URL)
            }
        return false
    }
}
