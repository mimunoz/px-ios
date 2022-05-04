import UIKit
import MLCardDrawer

class PXCardSliderPagerCell: FSPagerViewCell {
    static let identifier = "PXCardSliderPagerCell"
    static func getCell() -> UINib {
        return UINib(nibName: PXCardSliderPagerCell.identifier, bundle: ResourceManager.shared.getBundle())
    }

    private lazy var bottomMessageViewHeight: CGFloat = 24
    private lazy var cornerRadius: CGFloat = 11
    private var cardHeader: MLCardDrawerController?
    private weak var messageViewBottomConstraint: NSLayoutConstraint?
    private weak var messageLabelCenterConstraint: NSLayoutConstraint?
    private var consumerCreditCard: ConsumerCreditsCard?

    weak var delegate: PXTermsAndConditionViewDelegate?
    weak var cardSliderPagerCellDelegate: PXCardSliderPagerCellDelegate?
    @IBOutlet var containerView: UIView!

    private var bottomMessageFixed: Bool = false

    override func prepareForReuse() {
        cardHeader?.view.removeFromSuperview()
        containerView.removeAllSubviews()
        super.prepareForReuse()
    }
}

protocol PXCardSliderPagerCellDelegate: NSObjectProtocol {
    func addNewCard()
    func addNewOfflineMethod()
    func switchDidChange(_ selectedOption: String)
}

// MARK: Publics.
extension PXCardSliderPagerCell {
    private struct BottomMessageHeights {
        static let small: CGFloat = 17
        static let large: CGFloat = 20
    }

    private func setupContainerView(_ cardSize: CGSize) {
        containerView.layer.frame = CGRect(origin: CGPoint.zero, size: cardSize)
        containerView.removeAllSubviews()
        containerView.backgroundColor = .clear
        containerView.layer.cornerRadius = cornerRadius
    }

    private func setupCardHeader(cardDrawerController: MLCardDrawerController?, cardSize: CGSize) {
        cardHeader = cardDrawerController
        cardHeader?.view.frame = CGRect(origin: CGPoint.zero, size: cardSize)
        cardHeader?.animated(false)
        cardHeader?.show()
    }

    private func setupSwitchInfoView(model: PXCardSliderViewModel) {
        if let comboSwitch = model.comboSwitch {
            comboSwitch.setSwitchDidChangeCallback { [weak self] selectedOption in
                model.trackCard(state: selectedOption)
                model.selectedApplicationId = selectedOption
                self?.cardSliderPagerCellDelegate?.switchDidChange(selectedOption)
            }
            cardHeader?.setCustomView(comboSwitch)
        }
    }

    func render(model: PXCardSliderViewModel, cardSize: CGSize, accessibilityData: AccessibilityCardData, clearCardData: Bool = false, cardType: MLCardDrawerTypeV3 = .large, delegate: PXCardSliderPagerCellDelegate?) {
        self.prepareForReuse()

        guard let selectedApplication = model.selectedApplication, let cardUI = model.cardUI else { return }

        cardSliderPagerCellDelegate = delegate
        let cardData = clearCardData ? PXCardDataFactory() : selectedApplication.cardData ?? PXCardDataFactory()
        let isDisabled = selectedApplication.status.isDisabled()
        let bottomMessage = selectedApplication.bottomMessage

        setupContainerView(cardSize)
        setupCardHeader(cardDrawerController: MLCardDrawerController(cardUI: cardUI, cardType, cardData, isDisabled), cardSize: cardSize)

        if let headerView = cardHeader?.view {
            containerView.addSubview(headerView)
            if let accountMoneyCard = cardUI as? AccountMoneyCard {
                accountMoneyCard.render(containerView: containerView, isDisabled: isDisabled, size: cardSize)
            } else if let hybridAMCard = cardUI as? HybridAMCard {
                hybridAMCard.render(containerView: containerView, isDisabled: isDisabled, size: cardSize)
            }
            PXLayout.centerHorizontally(view: headerView).isActive = true
            PXLayout.centerVertically(view: headerView).isActive = true
        }

        self.bottomMessageViewHeight = cardType == .small ? BottomMessageHeights.small : BottomMessageHeights.large

        addBottomMessageView(message: bottomMessage)
        accessibilityLabel = getAccessibilityMessage(accessibilityData)

        setupSwitchInfoView(model: model)
        addShadow(to: cardHeader?.view)
    }

    func renderEmptyCard(newCardData: PXAddNewMethodData?, newOfflineData: PXAddNewMethodData?, cardSize: CGSize, delegate: PXCardSliderPagerCellDelegate, cardType: MLCardDrawerTypeV3 = .large) {
        self.cardSliderPagerCellDelegate = delegate

        setupContainerView(cardSize)

        isAccessibilityElement = false
        if let newCardData = newCardData {
            let icon = ResourceManager.shared.getImage("add_new_card")
            let newCardModel = NewPaymentMethodCardModel(title: newCardData.title,
                                                        subtitle: newCardData.subtitle,
                                                        defaultIcon: icon,
                                                        iconUrl: newCardData.iconUrl,
                                                         border: newCardData.border,
                                                         shadow: newCardData.shadow,
                                                        backgroundColor: newCardData.backgroundColor)
            let newCardView = getNewPaymentMethodCardView(data: newCardModel,
                                                          cardType: cardType)
            newCardView.translatesAutoresizingMaskIntoConstraints = false
            newCardView.layer.cornerRadius = cornerRadius
            containerView.addSubview(newCardView)

            let newCardTap = UITapGestureRecognizer(target: self, action: #selector(addNewCardTapped))
            newCardView.addGestureRecognizer(newCardTap)

            NSLayoutConstraint.activate([
                newCardView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                newCardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                newCardView.topAnchor.constraint(equalTo: containerView.topAnchor),
                newCardView.heightAnchor.constraint(equalToConstant: cardSize.height)
            ])
        }

        if let newOfflineData = newOfflineData {
            let icon = ResourceManager.shared.getImage("add_new_offline")
            let newOfflineModel = NewPaymentMethodCardModel(title: newOfflineData.title,
                                                           subtitle: newOfflineData.subtitle,
                                                           defaultIcon: icon,
                                                            iconUrl: newOfflineData.iconUrl,
                                                            border: newCardData?.border,
                                                            shadow: newOfflineData.shadow,
                                                            backgroundColor: newOfflineData.backgroundColor)
            let newOfflineView = getNewPaymentMethodCardView(data: newOfflineModel,
                                                             cardType: cardType)
            newOfflineView.translatesAutoresizingMaskIntoConstraints = false
            newOfflineView.layer.cornerRadius = cornerRadius

            let newOfflineMethodTap = UITapGestureRecognizer(target: self, action: #selector(addNewOfflineMethodTapped))
            newOfflineView.addGestureRecognizer(newOfflineMethodTap)

            containerView.addSubview(newOfflineView)

            NSLayoutConstraint.activate([
                newOfflineView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                newOfflineView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                newOfflineView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                newOfflineView.heightAnchor.constraint(equalToConstant: cardSize.height)
            ])
        }
    }

    @objc
    func addNewCardTapped() {
        cardSliderPagerCellDelegate?.addNewCard()
    }

    @objc
    func addNewOfflineMethodTapped() {
        PXFeedbackGenerator.selectionFeedback()
        cardSliderPagerCellDelegate?.addNewOfflineMethod()
    }

    private func getNewPaymentMethodCardView(data: NewPaymentMethodCardModel, cardType: MLCardDrawerTypeV3 = .large) -> UIView {
        var view: UIView?

        switch cardType {
        case .mini, .xSmall, .small:
            view = NewPaymentMethodSmallCardView(data: data)
        case .medium, .large:
            view = NewPaymentMethodLargeCardView(data: data)
        }

        return view ?? NewPaymentMethodLargeCardView(data: data)
    }

    func renderConsumerCreditsCard(model: PXCardSliderViewModel, cardSize: CGSize, accessibilityData: AccessibilityCardData, cardType: MLCardDrawerTypeV3?) {
        guard let selectedApplication = model.selectedApplication else { return }
        guard let creditsViewModel = model.creditsViewModel else { return }
        let cardData = PXCardDataFactory()
        let isDisabled = selectedApplication.status.isDisabled()
        let bottomMessage = selectedApplication.bottomMessage
        let creditsInstallmentSelected = selectedApplication.selectedPayerCost?.installments
        consumerCreditCard = ConsumerCreditsCard(
            creditsViewModel,
            isDisabled: isDisabled,
            highlightText: model.displayInfo?.tag
        )
        guard let consumerCreditCard = consumerCreditCard else { return }

        setupContainerView(cardSize)
        setupCardHeader(cardDrawerController: MLCardDrawerController(consumerCreditCard, cardData, isDisabled), cardSize: cardSize)

        if let headerView = cardHeader?.view {
            containerView.addSubview(headerView)
            consumerCreditCard.render(containerView: containerView, creditsViewModel: creditsViewModel, isDisabled: isDisabled, size: cardSize, selectedInstallments: creditsInstallmentSelected, cardType: cardType)
            consumerCreditCard.delegate = self
            PXLayout.centerHorizontally(view: headerView).isActive = true
            PXLayout.centerVertically(view: headerView).isActive = true
        }
        addBottomMessageView(message: bottomMessage)
        addShadow(to: cardHeader?.view)
        accessibilityLabel = getAccessibilityMessage(accessibilityData)
    }

    public func addBottomMessageView(message: PXCardBottomMessage?) {
        guard let message = message else { return }

        let messageView = UIView()
        messageView.translatesAutoresizingMaskIntoConstraints = false
        messageView.backgroundColor = message.text.getBackgroundColor()

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = message.text.getAttributedString(backgroundColor: .clear)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = Utils.getSemiBoldFont(size: PXLayout.XXXS_FONT)

        messageView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: messageView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: messageView.trailingAnchor)
        ])

        self.bottomMessageFixed = message.fixed

        let constraintsConstant = message.fixed ? 0 : bottomMessageViewHeight

        messageLabelCenterConstraint = label.centerYAnchor.constraint(equalTo: messageView.centerYAnchor, constant: constraintsConstant)
        messageLabelCenterConstraint?.isActive = true

        containerView.clipsToBounds = true

        containerView.layoutIfNeeded()

        containerView.addSubview(messageView)

        NSLayoutConstraint.activate([
            messageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            messageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            messageView.heightAnchor.constraint(equalToConstant: bottomMessageViewHeight)
        ])

        messageViewBottomConstraint = messageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: constraintsConstant)
        messageViewBottomConstraint?.isActive = true
    }

    func showBottomMessageView(_ shouldShow: Bool) {
        guard !bottomMessageFixed else { return }
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let heightValue = self?.bottomMessageViewHeight else { return }
            self?.messageViewBottomConstraint?.constant = shouldShow ? 0 : heightValue
            self?.messageLabelCenterConstraint?.constant = shouldShow ? 0 : heightValue
            self?.layoutIfNeeded()
        })
    }

    func addShadow(to view: UIView?) {
        view?.layer.shadowColor = UIColor.black.cgColor
        view?.layer.shadowRadius = 3
        view?.layer.shadowOpacity = 0.25
        view?.layer.shadowOffset = CGSize(width: 0.3, height: 0.3)
    }
}

// MARK: Publics
private extension PXCardSliderPagerCell {
    func getAccessibilityMessage(_ accessibilityData: AccessibilityCardData) -> String {
        isAccessibilityElement = true
        var sliderPosition = ""
        if accessibilityData.numberOfPages > 1 && accessibilityData.index == 0 {
            sliderPosition = ": " + "1" + "de".localized + "\(accessibilityData.numberOfPages)"
        }
        switch accessibilityData.paymentTypeId {
        case PXPaymentTypes.ACCOUNT_MONEY.rawValue:
            return "\(accessibilityData.description)" + "\(sliderPosition)"
        case PXPaymentTypes.CREDIT_CARD.rawValue:
            return "\(accessibilityData.paymentMethodId)" + "\(accessibilityData.issuerName)" + "\(accessibilityData.description)" + "de".localized + "\(accessibilityData.cardName)" + "\(sliderPosition)"
        case PXPaymentTypes.DEBIT_CARD.rawValue:
            return "\(accessibilityData.paymentMethodId.replacingOccurrences(of: "deb", with: ""))" + "Débito".localized + "\(accessibilityData.issuerName)" + "\(accessibilityData.description)" + "de".localized + "\(accessibilityData.cardName)" + "\(sliderPosition)"
        case PXPaymentTypes.DIGITAL_CURRENCY.rawValue:
            return "\(accessibilityData.description)" + "\(sliderPosition)"
        default:
            return "\(sliderPosition)"
        }
    }
}

extension PXCardSliderPagerCell: PXTermsAndConditionViewDelegate {
    func shouldOpenTermsCondition(_ title: String, url: URL) {
        delegate?.shouldOpenTermsCondition(title, url: url)
    }
}
