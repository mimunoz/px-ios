import UIKit

enum OneTapHeaderAnimationDirection: Int {
    case horizontal
    case vertical
}

class PXOneTapHeaderView: UIStackView, PXOneTapHeaderMerchantViewDelegate {
    private var model: PXOneTapHeaderViewModel {
        willSet(newModel) {
            updateLayout(newModel: newModel, oldModel: model)
        }
    }

    internal weak var delegate: PXOneTapHeaderProtocol?
    private var isShowingHorizontally: Bool = false
    private var verticalLayoutConstraints: [NSLayoutConstraint] = []
    private var horizontalLayoutConstraints: [NSLayoutConstraint] = []
    private var merchantView: PXOneTapHeaderMerchantView?
    private var summaryView: PXOneTapSummaryView?
    private var splitPaymentView: PXOneTapSplitPaymentView?
    private var splitPaymentViewHeightConstraint: NSLayoutConstraint?
    private let splitPaymentViewHeight: CGFloat = 55
    private var emptyTotalRowBottomMarginConstraint: NSLayoutConstraint?

    init(viewModel: PXOneTapHeaderViewModel, delegate: PXOneTapHeaderProtocol?) {
        self.model = viewModel
        self.delegate = delegate
        super.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        self.render()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateModel(_ model: PXOneTapHeaderViewModel) {
        self.model = model
    }

    func updateSplitPaymentView(splitConfiguration: PXSplitConfiguration?) {
        if let newSplitConfiguration = splitConfiguration {
            self.splitPaymentView?.update(splitConfiguration: newSplitConfiguration)
        }
    }
}

// MARK: Privates.
private extension PXOneTapHeaderView {

    func toggleSplitPaymentView(shouldHide: Bool, duration: Double = 0.5) {
        layoutIfNeeded()
        var pxAnimator = PXAnimator(duration: duration, dampingRatio: 1)
        pxAnimator.addAnimation(animation: { [weak self] in
            guard let self = self else { return }
            self.splitPaymentView?.isHidden = shouldHide
        })

        pxAnimator.animate()
    }

    func shouldShowHorizontally(model: PXOneTapHeaderViewModel) -> Bool {
    
        // Define device size
        let deviceSize = PXDeviceSize.getDeviceSize(deviceHeight: UIScreen.main.bounds.height)
        
        // If it doesn't have PXOneTapContext use horizontal as fallback
        guard let pxOneTapContext = model.pxOneTapContext else { return true }
            
        switch deviceSize {
        case .small:
            // On small devices always use horizontal header
            if pxOneTapContext.hasInstallments && ((pxOneTapContext.hasSplit && pxOneTapContext.hasCharges) || (pxOneTapContext.hasSplit && pxOneTapContext.hasDiscounts)) {
                // If it has installments, or split payment, or charges and discounts, use horizontal header
                return true
            } else {
                // If it just has charges or discounts use vertical header
                return false
            }
        case .regular:
            // On regular devices
            if pxOneTapContext.hasInstallments || pxOneTapContext.hasSplit || (pxOneTapContext.hasCharges && pxOneTapContext.hasDiscounts) {
                // If it has installments, or split payment, or charges and discounts, use horizontal header
                return true
            } else {
                // If it just has charges or discounts use vertical header
                return false
            }
        case .large:
            // On large devices
            if pxOneTapContext.hasInstallments && pxOneTapContext.hasSplit && pxOneTapContext.hasCharges && pxOneTapContext.hasDiscounts {
                // If it has installments and split payment, and charges and discounts, use horizontal header
                return true
            } else {
                // If it just has installments, or split but no charges or discounts use vertical header
                return false
            }
        case .extraLarge:
            // On extra-large devices always use vertical header
            return pxOneTapContext.hasInstallments && pxOneTapContext.hasSplit && pxOneTapContext.hasCharges && pxOneTapContext.hasDiscounts
        default:
            return true
        }
    }

    func removeAnimations() {
        layer.removeAllAnimations()
        for view in self.arrangedSubviews {
            view.layer.removeAllAnimations()
        }
    }

    func updateLayout(newModel: PXOneTapHeaderViewModel, oldModel: PXOneTapHeaderViewModel) {
        removeAnimations()

        let animationDuration = 0.35
        let shouldAnimateSplitPaymentView = (newModel.splitConfiguration != nil) != (oldModel.splitConfiguration != nil)
        let shouldHideSplitPaymentView = newModel.splitConfiguration == nil
        let shouldShowHorizontally = self.shouldShowHorizontally(model: newModel)

        layoutIfNeeded()

        if shouldShowHorizontally, !isShowingHorizontally {
            //animate to horizontal
            animateHeaderLayout(direction: .horizontal, duration: animationDuration)
        } else if !shouldShowHorizontally, isShowingHorizontally {
            //animate to vertical
            animateHeaderLayout(direction: .vertical, duration: animationDuration)
        }

        layoutIfNeeded()

        summaryView?.updateSplitMoney(newModel.splitConfiguration != nil)
        summaryView?.update(newModel.data)

        if shouldAnimateSplitPaymentView {
            layoutIfNeeded()
            superview?.layoutIfNeeded()
            toggleSplitPaymentView(shouldHide: shouldHideSplitPaymentView, duration: animationDuration)
        }
    }

    func animateHeaderLayout(direction: OneTapHeaderAnimationDirection, duration: Double = 0) {
        isShowingHorizontally = (direction == .horizontal) ? true : false
        merchantView?.animateHeaderLayout(direction: direction, duration: duration)
        if (direction == .vertical) {
            let margin = model.splitConfiguration != nil ? PXLayout.ZERO_MARGIN : PXLayout.M_MARGIN
            merchantView?.updateContentViewLayout(margin: margin)
        }

        var pxAnimator = PXAnimator(duration: duration, dampingRatio: 1)
        pxAnimator.addAnimation(animation: { [weak self] in
            guard let self = self else { return }

            for constraint in self.horizontalLayoutConstraints.reversed() {
                constraint.isActive = (direction == .horizontal)
            }

            for constraint in self.verticalLayoutConstraints.reversed() {
                constraint.isActive = (direction == .vertical)
            }
            self.layoutIfNeeded()
        })

        pxAnimator.animate()
    }
    
    func render() {
        removeAllSubviews()
        
        backgroundColor = UIColor.Andes.white

        self.axis = .vertical
        self.alignment = .fill
        self.distribution = .fill
        
        let showHorizontally = shouldShowHorizontally(model: model)
        
        // Add MerchantView
        let merchantView = PXOneTapHeaderMerchantView(image: model.icon, title: model.title, subTitle: model.subTitle, showHorizontally: showHorizontally)

        let headerTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap))
        merchantView.addGestureRecognizer(headerTapGesture)

        self.merchantView = merchantView
        self.merchantView?.delegate = self
        self.addArrangedSubview(merchantView)

        PXLayout.matchWidth(ofView: merchantView).isActive = true
        PXLayout.centerHorizontally(view: merchantView).isActive = true
        
        // Add Summary
        let summaryView = PXOneTapSummaryView(data: model.data, delegate: self, splitMoney: model.splitConfiguration != nil)
        
        self.summaryView = summaryView
        
        summaryView.removeMargins()
        
        addArrangedSubview(summaryView)
        
        PXLayout.matchWidth(ofView: summaryView).isActive = true
        PXLayout.centerHorizontally(view: summaryView).isActive = true
        
        // Add SplitPaymentView
        let splitPaymentView = PXOneTapSplitPaymentView(splitConfiguration: model.splitConfiguration) { (isOn, isUserSelection) in
            self.delegate?.splitPaymentSwitchChangedValue(isOn: isOn, isUserSelection: isUserSelection)
        }

        self.splitPaymentView = splitPaymentView
        splitPaymentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            splitPaymentView.heightAnchor.constraint(equalToConstant: PXLayout.XXXL_MARGIN)
        ])

        addArrangedSubview(splitPaymentView)
        
        PXLayout.matchWidth(ofView: splitPaymentView).isActive = true
        self.splitPaymentView?.isHidden = model.splitConfiguration == nil

    }
    
    internal func tappedBackButton() {
        delegate?.didTapBackButton()
    }
}

extension PXOneTapHeaderView: PXOneTapSummaryProtocol {
    func didTapCharges() {
        delegate?.didTapCharges()
    }

    func didTapDiscount() {
        delegate?.didTapDiscount()
    }

    @objc func handleHeaderTap() {
        delegate?.didTapMerchantHeader()
    }
}

// MARK: Publics
extension PXOneTapHeaderView {
    func getMerchantView() -> PXOneTapHeaderMerchantView? {
        return merchantView
    }

    func updateConstraintsIfNecessary() {
        summaryView?.updateRowsConstraintsIfNecessary()
    }
}
