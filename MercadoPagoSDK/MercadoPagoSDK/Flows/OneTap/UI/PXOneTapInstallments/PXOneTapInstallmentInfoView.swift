import UIKit

final class PXOneTapInstallmentInfoView: PXComponentView {
    static let DEFAULT_ROW_HEIGHT: CGFloat = 50
    static let HIGH_ROW_HEIGHT: CGFloat = 78
    private let titleLabel = UILabel()
    private let colapsedTag: Int = 2
    private var arrowImage: UIImageView = UIImageView()
    private var pagerView = FSPagerView(frame: .zero)
    private var tapEnabled = true
    private var shouldShowBadgeView = false
    private var chevronBackgroundView: UIView?
    var pulseView: PXPulseView?

    weak var delegate: PXOneTapInstallmentInfoViewProtocol?
    private var model: [PXOneTapInstallmentInfoViewModel]?
}

// MARK: Privates
extension PXOneTapInstallmentInfoView {
    private func setupTitleLabel() {
        titleLabel.alpha = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "onetap_select_installment_title".localized
        titleLabel.textAlignment = .left
        titleLabel.font = Utils.getFont(size: PXLayout.XS_FONT)
        titleLabel.textColor = ThemeManager.shared.greyColor()
        addSubview(titleLabel)
        PXLayout.matchHeight(ofView: titleLabel).isActive = true
        PXLayout.centerVertically(view: titleLabel).isActive = true
        PXLayout.pinLeft(view: titleLabel, withMargin: PXLayout.L_MARGIN).isActive = true
        PXLayout.pinRight(view: titleLabel, withMargin: PXLayout.L_MARGIN).isActive = true
    }

    private func setupSlider(width: CGFloat) {
        addSubview(pagerView)
        pagerView.isUserInteractionEnabled = false
        PXLayout.pinTop(view: pagerView).isActive = true
        PXLayout.pinBottom(view: pagerView).isActive = true
        PXLayout.pinLeft(view: pagerView).isActive = true
        PXLayout.pinRight(view: pagerView).isActive = true
        PXLayout.matchWidth(ofView: pagerView).isActive = true
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pagerView.isInfinite = false
        pagerView.automaticSlidingInterval = 0
        pagerView.bounces = true
        pagerView.interitemSpacing = PXCardSliderSizeManager.interItemSpace
        pagerView.decelerationDistance = 1
        pagerView.itemSize = CGSize(width: width, height: PXOneTapInstallmentInfoView.DEFAULT_ROW_HEIGHT)
        pagerView.backgroundColor = UIColor.Andes.graySolid040
    }
}

// MARK: DataSource
extension PXOneTapInstallmentInfoView: FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        guard let model = model else { return 0 }
        return model.count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)

        guard let model = model else { return FSPagerViewCell() }

        let itemModel = model[index]
        cell.removeAllSubviews()

        var benefitsLabel: UILabel?
        var benefitsText = ""
        if itemModel.shouldShowInstallmentsHeader, let benefitText = itemModel.benefits?.installmentsHeader?.getAttributedString(fontSize: PXLayout.XXXS_FONT) {
            benefitsText = benefitText.string
            let label = buildLabel(benefitText, UIFont.ml_regularSystemFont(ofSize: PXLayout.XXXS_FONT), .right)
            benefitsLabel = label
            cell.addSubview(label)
            PXLayout.pinRight(view: label, withMargin: PXLayout.M_MARGIN).isActive = true
            PXLayout.centerVertically(view: label).isActive = true
        }

        let label = buildLabel(itemModel.text, nil, .left)
        label.textColor = UIColor.Andes.gray900
        let accessibilityMessage = getAccessibilityMessage(itemModel.text.string, benefitsText)
        cell.setAccessibilityMessage(accessibilityMessage)
        if index == 0 {
            accessibilityLabel = accessibilityMessage
            setAccessibilityValue()
        }
        cell.addSubview(label)
        PXLayout.pinLeft(view: label, withMargin: PXLayout.XXXS_MARGIN).isActive = true
        PXLayout.centerVertically(view: label).isActive = true
        PXLayout.matchHeight(ofView: label).isActive = true

        if let benefitsLabel = benefitsLabel {
            PXLayout.put(view: label, leftOf: benefitsLabel, withMargin: PXLayout.XXXS_MARGIN).isActive = true
        } else {
            PXLayout.pinRight(view: label, withMargin: PXLayout.M_MARGIN).isActive = true
        }

        if itemModel.status.isDisabled() {
            let helperIcon = ResourceManager.shared.getImage("helper_ico_blue")
            let helperImageView = UIImageView(image: helperIcon)
            helperImageView.contentMode = .scaleAspectFit
            cell.addSubview(helperImageView)
            PXLayout.centerVertically(view: helperImageView).isActive = true
            PXLayout.setWidth(owner: helperImageView, width: 24).isActive = true
            PXLayout.setHeight(owner: helperImageView, height: 24).isActive = true
            PXLayout.pinRight(view: helperImageView, withMargin: PXLayout.ZERO_MARGIN).isActive = true
            PXLayout.put(view: helperImageView, rightOf: label, withMargin: PXLayout.XXXS_MARGIN, relation: .greaterThanOrEqual).isActive = true
        }

        return cell
    }
}

// MARK: Delegate
extension PXOneTapInstallmentInfoView: FSPagerViewDelegate {
    func getCurrentIndex() -> Int? {
        if let mModel = model, mModel.count > 0 {
            let scrollOffset = pagerView.scrollOffset
            let floorOffset = floor(scrollOffset)
            
            guard !(floorOffset.isNaN || floorOffset.isInfinite) else {
                return nil
            }
            
            return Int(floorOffset)
        } else {
            return nil
        }
    }

    func didEndDecelerating() {
        enableTap()
    }

    func didEndScrollAnimation() {
        enableTap()
        accessibilityLabel = pagerView.cellForItem(at: pagerView.currentIndex)?.getAccessibilityMessage()
        setAccessibilityValue()
    }

    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        disableTap()
        if let currentIndex = getCurrentIndex() {
            let newAlpha = 1 - (pagerView.scrollOffset - CGFloat(integerLiteral: currentIndex))
            if newAlpha < 0.5 {
                pagerView.alpha = 1 - newAlpha
            } else {
                pagerView.alpha = newAlpha
            }
        }
    }
}

// MARK: Accessibility
private extension PXOneTapInstallmentInfoView {
    func getAccessibilityMessage(_ message: String, _ benefitsText: String) -> String {
        isAccessibilityElement = true
        let text = message.replacingOccurrences(of: "x", with: " \("de".localized)").replacingOccurrences(of: "[$:.]", with: "", options: .regularExpression)
        if let range: Range<String.Index> = text.range(of: "CFT") {
            let index: Int = text.distance(from: text.startIndex, to: range.lowerBound)
            return text.insert("pesos".localized + ":", ind: index) + "\(benefitsText)"
        }
        return message.contains("$") ? text + "pesos".localized + "\(benefitsText)" : text + "\(benefitsText)"
    }

    func setAccessibilityValue() {
        if let model = model {
            let item = model[pagerView.currentIndex]
            accessibilityValue = item.shouldShowArrow ? "botón".localized : ""
        }
    }
}

// MARK: Publics
extension PXOneTapInstallmentInfoView {
    func update(model: [PXOneTapInstallmentInfoViewModel]?) {
        self.model = model
        pagerView.reloadData()
    }

    func isExpanded() -> Bool {
        return arrowImage.tag != colapsedTag
    }

    func getActiveRowIndex() -> Int {
        return pagerView.currentIndex
    }

    func disableTap() {
        tapEnabled = false
    }

    func enableTap() {
        tapEnabled = true
    }

    func render(_ width: CGFloat) {
        removeAllSubviews()
        setupSlider(width: width)
        setupFadeImages()
        setupTitleLabel()
        PXLayout.setHeight(owner: self, height: PXOneTapInstallmentInfoView.DEFAULT_ROW_HEIGHT).isActive = true
    }

    private func setupFadeImages() {
        let leftImage = ResourceManager.shared.getImage("one-tap-installments-info-left")
        let leftImageView = UIImageView(image: leftImage)
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftImageView)
        PXLayout.pinTop(view: leftImageView).isActive = true
        PXLayout.pinBottom(view: leftImageView).isActive = true
        PXLayout.pinLeft(view: leftImageView).isActive = true
        PXLayout.setWidth(owner: leftImageView, width: 16).isActive = true

        let rightImage = ResourceManager.shared.getImage("one-tap-installments-info-right")
        let rightImageView = UIImageView(image: rightImage)
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        rightImageView.contentMode = .scaleAspectFill
        addSubview(rightImageView)
        PXLayout.pinTop(view: rightImageView).isActive = true
        PXLayout.pinBottom(view: rightImageView).isActive = true
        PXLayout.pinRight(view: rightImageView).isActive = true
        PXLayout.setWidth(owner: rightImageView, width: 30).isActive = true
    }

    private func animateArrow(alpha: CGFloat, duration: Double) {
        var pxAnimator = PXAnimator(duration: duration, dampingRatio: 1)
        pxAnimator.addAnimation(animation: { [weak self] in
            self?.arrowImage.alpha = alpha
        })

        pxAnimator.animate()
    }

    func setSliderOffset(offset: CGPoint) {
        pagerView.scrollToOffset(offset, animated: false)
    }
}

// MARK: Privates
private extension PXOneTapInstallmentInfoView {
    func buildLabel(_ attributedText: NSAttributedString, _ font: UIFont? = nil, _ textAlignment: NSTextAlignment, _ numberOfLines: Int = 1) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = attributedText
        if let font = font {
            label.font = font
        }
        label.textAlignment = textAlignment
        label.numberOfLines = numberOfLines
        return label
    }
}
