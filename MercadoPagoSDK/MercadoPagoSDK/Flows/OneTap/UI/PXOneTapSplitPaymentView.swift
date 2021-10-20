import UIKit

class PXOneTapSplitPaymentView: UIView {
    let callback : ((_ isOn: Bool, _ isUserSelection: Bool) -> Void)
    var splitConfiguration: PXSplitConfiguration?
    var splitPaymentSwitch: UISwitch?
    var splitMessageLabel: UILabel?
    var separatorView: UIView?
    private let switchReduceSize: CGFloat = 0.70

    init(splitConfiguration: PXSplitConfiguration?, callback : @escaping ((_ isOn: Bool, _ isUserSelection: Bool) -> Void)) {
        self.splitConfiguration = splitConfiguration
        self.callback = callback
        super.init(frame: .zero)
        render()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func hide() {
        splitMessageLabel?.alpha = 0
        splitPaymentSwitch?.alpha = 0
        separatorView?.isHidden = true
    }

    func show() {
        splitMessageLabel?.alpha = 1
        splitPaymentSwitch?.alpha = 1
        separatorView?.isHidden = false
    }

    func update(splitConfiguration: PXSplitConfiguration?) {
        self.splitConfiguration = splitConfiguration
        show()

        guard let splitConfiguration = splitConfiguration else {
            hide()
            splitMessageLabel?.attributedText = "".toAttributedString()
            splitPaymentSwitch?.setOn(false, animated: false)
            return
        }

        splitMessageLabel?.attributedText = getSplitMessage(splitConfiguration: splitConfiguration)

        if splitPaymentSwitch?.isOn != splitConfiguration.splitEnabled {
            callback(splitConfiguration.splitEnabled, false)
        }

        splitPaymentSwitch?.setOn(splitConfiguration.splitEnabled, animated: true)
    }

    private func render() {
        removeAllSubviews()
        self.backgroundColor = UIColor.Andes.graySolid040
        let splitSwitch = UISwitch()
        self.splitPaymentSwitch = splitSwitch
        splitSwitch.addTarget(self, action: #selector(PXOneTapSplitPaymentView.switchStateChanged(_:)), for: UIControl.Event.valueChanged)

        splitSwitch.setOn(splitConfiguration?.splitEnabled ?? false, animated: false)
        splitSwitch.translatesAutoresizingMaskIntoConstraints = false
        splitSwitch.transform = CGAffineTransform(scaleX: switchReduceSize, y: switchReduceSize)
        self.addSubview(splitSwitch)
        PXLayout.pinRight(view: splitSwitch, withMargin: PXLayout.M_MARGIN).isActive = true
        PXLayout.centerVertically(view: splitSwitch).isActive = true
        splitSwitch.onTintColor = ThemeManager.shared.getAccentColor()

        let label = UILabel()
        label.lineBreakMode = .byTruncatingTail
        self.splitMessageLabel = label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        self.addSubview(label)
        PXLayout.centerVertically(view: label).isActive = true
        PXLayout.pinLeft(view: label, withMargin: PXLayout.L_MARGIN).isActive = true
        PXLayout.pinRight(view: label, to: splitSwitch, withMargin: PXLayout.XXXL_MARGIN).isActive = true
        PXLayout.pinTop(view: label, withMargin: PXLayout.S_MARGIN).isActive = true
        PXLayout.pinBottom(view: label, withMargin: PXLayout.S_MARGIN).isActive = true

        if let splitConfiguration = splitConfiguration {
            label.attributedText = getSplitMessage(splitConfiguration: splitConfiguration)
        } else {
            label.attributedText = "".toAttributedString()
        }
        
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView = separatorView
        separatorView.backgroundColor = UIColor.Andes.gray450
        self.addSubview(separatorView)
        PXLayout.setHeight(owner: separatorView, height: 1.5).isActive = true
        PXLayout.pinBottom(view: separatorView).isActive = true
        PXLayout.pinLeft(view: separatorView, withMargin: PXLayout.L_MARGIN).isActive = true
        PXLayout.pinRight(view: separatorView, withMargin: PXLayout.L_MARGIN).isActive = true

        if splitConfiguration == nil {
            hide()
        } else {
            show()
        }
    }

    @objc private func switchStateChanged(_ sender: UISwitch) {
        callback(sender.isOn, true)
    }

    private func getSplitMessage(splitConfiguration: PXSplitConfiguration) -> NSMutableAttributedString {
        let amount: String = Utils.getAmountFormated(amount: splitConfiguration.getSplitAmountToPay(), forCurrency: SiteManager.shared.getCurrency())

        let attributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: Utils.getSemiBoldFont(size: PXLayout.XXS_FONT), NSAttributedString.Key.foregroundColor: UIColor.Andes.gray900]

        let messageAttributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: Utils.getFont(size: PXLayout.XXS_FONT), NSAttributedString.Key.foregroundColor: UIColor.Andes.gray550]

        let messageAttributed = NSAttributedString(string: splitConfiguration.secondaryPaymentMethod?.message ?? "", attributes: messageAttributes)

        let amountAttributed = NSMutableAttributedString(string: amount, attributes: attributes)
        amountAttributed.append(" ".toAttributedString())
        amountAttributed.append(messageAttributed)
        setAccessibilityMessage(amount, messageAttributed.string)
        return amountAttributed
    }
}

// MARK: Accessibility
private extension PXOneTapSplitPaymentView {
    func setAccessibilityMessage(_ amount: String, _ message: String) {
        splitMessageLabel?.accessibilityLabel = amount.contains("$") ? amount.replacingOccurrences(of: "$", with: "") + "pesos".localized + message : message
    }
}
