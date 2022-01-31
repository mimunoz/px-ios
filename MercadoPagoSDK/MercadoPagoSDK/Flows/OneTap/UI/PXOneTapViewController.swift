import UIKit
import MLCardForm
import MLUI
import AndesUI
import MLCardDrawer

final class PXOneTapViewController: MercadoPagoUIViewController {
    // MARK: Constants

    private struct OneTapUI {
        static let headerViewAlpha: CGFloat = 1
    }

    // MARK: Definitions
    lazy var itemViews = [UIView]()
    fileprivate var viewModel: PXOneTapViewModel
    private var pxOneTapContext: PXOneTapContext
    private var discountTermsConditionView: PXTermsAndConditionView?

    let slider = PXCardSlider()

    // MARK: Callbacks
    var callbackPaymentData: ((PXPaymentData) -> Void)
    var callbackConfirm: ((PXPaymentData, Bool) -> Void)
    var callbackUpdatePaymentOption: ((PaymentMethodOption) -> Void)
    var callbackRefreshInit: ((String) -> Void)
    var callbackExit: (() -> Void)
    var finishButtonAnimation: (() -> Void)

    var loadingButtonComponent: PXAnimatedButton?
    var installmentInfoRow: PXOneTapInstallmentInfoView?
    var installmentsSelectorView: UIView?// PXOneTapInstallmentsSelectorView?
    var footerView: UIView?
    var headerView: PXOneTapHeaderView?
    var whiteView: UIStackView?
    var cardSliderContentView: UIStackView?
    var selectedCard: PXCardSliderViewModel?
    var installmentsWrapperView: UIStackView?

    var currentModal: MLModal?
    var shouldTrackModal: Bool = false
    var currentModalDismissTrackingProperties: [String: Any]?
    let timeOutPayButton: TimeInterval
    var shouldHideOneTapNavBar: Bool = false

    var shouldPromptForOfflineMethods = true
    private var navigationBarTapGesture: UITapGestureRecognizer?
    var installmentRow = PXOneTapInstallmentInfoView()
    private var andesBottomSheet: AndesBottomSheetViewController?

    var cardType: MLCardDrawerTypeV3

    // MARK: Lifecycle/Publics
    init(viewModel: PXOneTapViewModel, pxOneTapContext: PXOneTapContext, timeOutPayButton: TimeInterval = 15, callbackPaymentData : @escaping ((PXPaymentData) -> Void), callbackConfirm: @escaping ((PXPaymentData, Bool) -> Void), callbackUpdatePaymentOption: @escaping ((PaymentMethodOption) -> Void), callbackRefreshInit: @escaping ((String) -> Void), callbackExit: @escaping (() -> Void), finishButtonAnimation: @escaping (() -> Void)) {
        self.viewModel = viewModel
        self.pxOneTapContext = pxOneTapContext
        self.callbackPaymentData = callbackPaymentData
        self.callbackConfirm = callbackConfirm
        self.callbackRefreshInit = callbackRefreshInit
        self.callbackExit = callbackExit
        self.callbackUpdatePaymentOption = callbackUpdatePaymentOption
        self.finishButtonAnimation = finishButtonAnimation
        self.timeOutPayButton = timeOutPayButton

        // Define device size
        let deviceSize = PXDeviceSize.getDeviceSize(deviceHeight: UIScreen.main.bounds.height)

        // Define card type to use
        self.cardType = PXCardSliderSizeManager.getCardTypeForContext(deviceSize: deviceSize, hasCharges: pxOneTapContext.hasCharges, hasDiscounts: pxOneTapContext.hasDiscounts, hasInstallments: pxOneTapContext.hasInstallments, hasSplit: pxOneTapContext.hasSplit)
        super.init(nibName: nil, bundle: nil)
//        super.init(adjustInsets: false)
        super.shouldHideNavigationBar = true
        super.shouldShowBackArrow = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.shouldHideNavigationBar = true
        super.shouldShowBackArrow = false
        setupNavigationBar()
        hideNavBar()
        setupUI()
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        isUIEnabled(true)
        addPulseViewNotifications()
        setLoadingButtonState()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removePulseViewNotifications()
        removeNavigationTapGesture()
        navigationController?.setNavigationBarHidden(shouldHideOneTapNavBar, animated: animated)
        cardSliderContentView?.layer.masksToBounds = true
        shouldHideOneTapNavBar = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadingButtonComponent?.resetButton()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
        slider.showBottomMessageIfNeeded(index: 0, targetIndex: 0)
        setupAutoDisplayOfflinePaymentMethods()
        UIAccessibility.post(notification: .layoutChanged, argument: headerView?.getMerchantView()?.getMerchantTitleLabel())
        trackScreen(event: MercadoPagoUITrackingEvents.reviewOneTap(viewModel.getOneTapScreenProperties(oneTapApplication: viewModel.applications)))
    }

    deinit {
        unsubscribeFromNotifications()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView?.updateConstraintsIfNecessary()
        if let cardSliderContentView = cardSliderContentView {
            if cardSliderContentView.subviews.count == 0 && cardSliderContentView.bounds.width > 0 {
                addCardSlider(inContainerView: cardSliderContentView)
            }
        }
    }

    @objc func willEnterForeground() {
        installmentRow.pulseView?.setupAnimations()
    }

    func update(viewModel: PXOneTapViewModel, cardId: String) {
        self.viewModel = viewModel

        viewModel.createCardSliderViewModel(cardType: cardType)
        let cardSliderViewModel = viewModel.getCardSliderViewModel()
        slider.update(cardSliderViewModel)
        installmentInfoRow?.update(model: viewModel.getInstallmentInfoViewModel())

        DispatchQueue.main.async {
            // Trick to wait for the slider to finish the update
            if let index = cardSliderViewModel.firstIndex(where: { $0.cardId == cardId }) {
                self.selectCardInSliderAtIndex(index)
            } else {
                // Select first item
                self.selectFirstCardInSlider()
            }
        }

        if let viewControllers = navigationController?.viewControllers {
            viewControllers.filter { $0 is MLCardFormViewController || $0 is MLCardFormWebPayViewController }.forEach {
                ($0 as? MLCardFormViewController)?.dismissLoadingAndPop()
                ($0 as? MLCardFormWebPayViewController)?.dismissLoadingAndPop()
            }
        }
    }

    func setupAutoDisplayOfflinePaymentMethods() {
        if viewModel.shouldAutoDisplayOfflinePaymentMethods() && shouldPromptForOfflineMethods {
            shouldPromptForOfflineMethods = false
            shouldAddNewOfflineMethod()
        }
    }
}

// MARK: UI Methods.
extension PXOneTapViewController {
    private func setupNavigationBar() {
        navBarTextColor = UIColor.Andes.gray900
        loadMPStyles()
        addNavigationTapGesture()
    }

    private func setupUI() {
        headerView?.alpha = OneTapUI.headerViewAlpha
        view.backgroundColor = ThemeManager.shared.navigationBar().backgroundColor
        if view.subviews.isEmpty {
            viewModel.createCardSliderViewModel(cardType: cardType)
            if let preSelectedCard = viewModel.getCardSliderViewModel().first {
                selectedCard = preSelectedCard
                viewModel.splitPaymentEnabled = preSelectedCard.selectedApplication?.amountConfiguration?.splitConfiguration?.splitEnabled ?? false
                viewModel.amountHelper.getPaymentData().payerCost = preSelectedCard.selectedApplication?.selectedPayerCost
            }
            renderViews()
        } else {
            installmentRow.pulseView?.setupAnimations()
        }
    }

    private func renderViews() {
        // Set contentView height and position
        let contentViewHeight = PXLayout.getAvailabelScreenHeightWithStatusBarOnly(in: self)
        view.layer.masksToBounds = true

        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.alignment = .center
        contentView.distribution = .fill
        contentView.addBackground(color: UIColor.Andes.white)
        view.addSubview(contentView)

        PXLayout.matchWidth(ofView: contentView)
        PXLayout.setHeight(owner: contentView, height: contentViewHeight)
        PXLayout.pinBottom(view: contentView)

        // Add header view.
        let headerView = getHeaderView(selectedCard: selectedCard, pxOneTapContext: self.pxOneTapContext)

        self.headerView = headerView
        contentView.addArrangedSubview(headerView)

        PXLayout.centerHorizontally(view: headerView).isActive = true
        PXLayout.matchWidth(ofView: headerView).isActive = true

        // Add whiteView to contentView
        let whiteView = getWhiteView()
        self.whiteView = whiteView
        contentView.addArrangedSubview(whiteView)

        view.layoutIfNeeded()

        PXLayout.matchWidth(ofView: whiteView, toView: view).isActive = true
        PXLayout.centerHorizontally(view: whiteView).isActive = true

        // Add installmentsWrapperView to whiteView
        let installmentsWrapperView = UIStackView()
        installmentsWrapperView.axis = .vertical

        installmentsWrapperView.isHidden = true

        self.installmentsWrapperView = installmentsWrapperView

        PXLayout.matchWidth(ofView: installmentsWrapperView)

        whiteView.addArrangedSubview(installmentsWrapperView)

        // Add installment info row
        installmentRow = getInstallmentInfoView()
        installmentRow.isHidden = true
        whiteView.addArrangedSubview(installmentRow)

        if cardType == .small {
            let spacerView = UIView()
            spacerView.translatesAutoresizingMaskIntoConstraints = false
            spacerView.backgroundColor = .white
            whiteView.addArrangedSubview(spacerView)
            NSLayoutConstraint.activate([
                spacerView.heightAnchor.constraint(equalToConstant: 10),
                spacerView.leadingAnchor.constraint(equalTo: whiteView.leadingAnchor),
                spacerView.trailingAnchor.constraint(equalTo: whiteView.trailingAnchor)
            ])
        }

        // Add cardSliderContentView to whiteView
        let cardSliderContentView = UIStackView()

        cardSliderContentView.axis = .vertical

        self.cardSliderContentView = cardSliderContentView

        whiteView.addArrangedSubview(cardSliderContentView)

        slider.cardType = cardType

        // CardSlider with aspect ratio multiplier
        cardSliderContentView.translatesAutoresizingMaskIntoConstraints = false
        PXLayout.matchWidth(ofView: cardSliderContentView)

        view.layoutIfNeeded()

        NSLayoutConstraint.activate([
            cardSliderContentView.heightAnchor.constraint(equalTo: cardSliderContentView.widthAnchor, multiplier: PXCardSliderSizeManager.aspectRatio(forType: cardType)),
            cardSliderContentView.leadingAnchor.constraint(equalTo: whiteView.leadingAnchor)
        ])

        // Render installmentInfoRow based on cardSlider known width
        let installmentRowWidth: CGFloat = slider.getItemSize(cardSliderContentView).width
        installmentRow.render(installmentRowWidth)

        // Add footer payment button.
        guard let footerView = getFooterView() else { return }
        self.footerView = footerView

        whiteView.addArrangedSubview(footerView)

        view.layoutIfNeeded()

        DispatchQueue.main.async {
            if let selectedCard = self.selectedCard {
                self.newCardDidSelected(targetModel: selectedCard, forced: true)
            }
        }
    }

    private func getBottomPayButtonMargin() -> CGFloat {
        let safeAreaBottomHeight = PXLayout.getSafeAreaBottomInset()
        if safeAreaBottomHeight > 0 {
            return PXLayout.XXS_MARGIN + safeAreaBottomHeight
        }

        if UIDevice.isSmallDevice() {
            return PXLayout.XS_MARGIN
        }

        return PXLayout.M_MARGIN
    }

    private func removeNavigationTapGesture() {
        if let targetGesture = navigationBarTapGesture {
            navigationController?.navigationBar.removeGestureRecognizer(targetGesture)
        }
    }

    private func addNavigationTapGesture() {
        removeNavigationTapGesture()
        navigationBarTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnNavigationbar))
        if let navTapGesture = navigationBarTapGesture {
            navigationController?.navigationBar.addGestureRecognizer(navTapGesture)
        }
    }
}

// MARK: Components Builders.
extension PXOneTapViewController {
    private func getHeaderView(selectedCard: PXCardSliderViewModel?, pxOneTapContext: PXOneTapContext?) -> PXOneTapHeaderView {
        let headerView = PXOneTapHeaderView(viewModel: viewModel.getHeaderViewModel(selectedCard: selectedCard, pxOneTapContext: pxOneTapContext), delegate: self)
        return headerView
    }

    private func getFooterView() -> UIView? {
        let loadingButtonComponent = PXAnimatedButton(normalText: "Pagar".localized, loadingText: "Procesando tu pago".localized, retryText: "Reintentar".localized)
        loadingButtonComponent.animationDelegate = self
        loadingButtonComponent.layer.cornerRadius = 4
        loadingButtonComponent.add(for: .touchUpInside, { [weak self] in
            self?.handlePayButton()
        })
        loadingButtonComponent.setTitle("Pagar".localized, for: .normal)
        loadingButtonComponent.backgroundColor = ThemeManager.shared.getAccentColor()
        loadingButtonComponent.accessibilityIdentifier = "pay_button"

        PXLayout.setHeight(owner: loadingButtonComponent, height: PXLayout.XXL_MARGIN).isActive = true

        self.loadingButtonComponent = loadingButtonComponent

        let loadingWrapper = UIStackView()
        loadingWrapper.axis = .vertical
        loadingWrapper.addArrangedSubview(loadingButtonComponent)

        let bottomMargin = getBottomPayButtonMargin()
        loadingWrapper.layoutMargins = UIEdgeInsets(top: 0, left: PXLayout.M_MARGIN, bottom: bottomMargin, right: PXLayout.M_MARGIN)
        loadingWrapper.isLayoutMarginsRelativeArrangement = true

        return loadingWrapper
    }

    private func getWhiteView() -> UIStackView {
        let whiteView = UIStackView()// UIView()
        whiteView.axis = .vertical

        if #available(iOS 14.0, *) {
            whiteView.backgroundColor = .white
        } else {
            // Fallback for coloring stackview background on iOS < 14
            let backgroundView = UIView()
            backgroundView.backgroundColor = .white

            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            whiteView.insertSubview(backgroundView, at: 0)
            PXLayout.pinAllEdges(view: backgroundView)
        }

        return whiteView
    }

    private func getInstallmentInfoView() -> PXOneTapInstallmentInfoView {
        installmentInfoRow = PXOneTapInstallmentInfoView()
        installmentInfoRow?.update(model: viewModel.getInstallmentInfoViewModel())
        installmentInfoRow?.delegate = self
        if let targetView = installmentInfoRow {
            return targetView
        } else {
            return PXOneTapInstallmentInfoView()
        }
    }

    private func addCardSlider(inContainerView: UIStackView) {
        slider.render(containerView: inContainerView, cardSliderProtocol: self)
        slider.termsAndCondDelegate = self
        slider.update(viewModel.getCardSliderViewModel())
    }

    private func setLoadingButtonState() {
        if let selectedCard = selectedCard, let selectedApplication = selectedCard.selectedApplication, (selectedApplication.status.isDisabled() || selectedCard.cardId == nil) {
            loadingButtonComponent?.setDisabled(animated: false)
        }
    }
}

// MARK: User Actions.
extension PXOneTapViewController {
    @objc func didTapOnNavigationbar() {
        didTapMerchantHeader()
    }

    func shouldAddNewOfflineMethod() {
        if let offlineMethods = viewModel.getOfflineMethods() {
            let offlineViewModel = PXOfflineMethodsViewModel(offlinePaymentTypes: offlineMethods.paymentTypes, paymentMethods: viewModel.paymentMethods, amountHelper: viewModel.amountHelper, paymentOptionSelected: viewModel.paymentOptionSelected, advancedConfig: viewModel.advancedConfiguration, userLogged: viewModel.userLogged, disabledOption: viewModel.disabledOption, payerCompliance: viewModel.payerCompliance, displayInfo: offlineMethods.displayInfo)

            let vc = PXOfflineMethodsViewController(viewModel: offlineViewModel, callbackConfirm: callbackConfirm, callbackUpdatePaymentOption: callbackUpdatePaymentOption, finishButtonAnimation: finishButtonAnimation) { [weak self] in
                    self?.navigationController?.popViewController(animated: false)
            }

            let sheet = PXOfflineMethodsSheetViewController(viewController: vc,
                                                            offlineViewModel: offlineViewModel,
                                                            whiteViewHeight: PXCardSliderSizeManager.getWhiteViewHeight(viewController: self))

            self.present(sheet, animated: true, completion: nil)
        }
    }

    private func handleBehaviour(_ behaviour: PXBehaviour, isSplit: Bool) {
        if let target = behaviour.target {
            let properties = viewModel.getTargetBehaviourProperties(behaviour)
            trackEvent(event: OneTapTrackingEvents.didGetTargetBehaviour(properties))
            openKyCDeeplinkWithoutCallback(target)
        } else if let modal = behaviour.modal, let modalConfig = viewModel.modals?[modal] {
            let properties = viewModel.getDialogOpenProperties(behaviour, modalConfig)
            trackEvent(event: OneTapTrackingEvents.didOpenDialog(properties))

            let mainActionProperties = viewModel.getDialogActionProperties(behaviour, modalConfig, "main_action", modalConfig.mainButton)
            let secondaryActionProperties = viewModel.getDialogActionProperties(behaviour, modalConfig, "secondary_action", modalConfig.secondaryButton)
            let primaryAction = getActionForModal(modalConfig.mainButton, isSplit: isSplit, trackingPath: TrackingPaths.Events.OneTap.getDialogActionPath(), properties: mainActionProperties)
            let secondaryAction = getActionForModal(modalConfig.secondaryButton, isSplit: isSplit, trackingPath: TrackingPaths.Events.OneTap.getDialogActionPath(), properties: secondaryActionProperties)
            let vc = PXOneTapDisabledViewController(title: modalConfig.title, description: modalConfig.description, primaryButton: primaryAction, secondaryButton: secondaryAction, iconUrl: modalConfig.imageUrl)
            shouldTrackModal = true
            currentModalDismissTrackingProperties = viewModel.getDialogDismissProperties(behaviour, modalConfig)
            currentModal = PXComponentFactory.Modal.show(viewController: vc, title: nil, dismissBlock: { [weak self] in
                guard let self = self else { return }
                self.trackDialogEvent(trackingPath: TrackingPaths.Events.OneTap.getDialogDismissPath(), properties: self.currentModalDismissTrackingProperties)
            })
        }
    }

    func trackDialogEvent(trackingPath: String?, properties: [String: Any]?) {
        if shouldTrackModal, let trackingPath = trackingPath, let properties = properties {
            shouldTrackModal = false
            trackEvent(event: OneTapTrackingEvents.didDismissDialog(properties))
        }
    }

    private func getActionForModal(_ action: PXRemoteAction? = nil, isSplit: Bool = false, trackingPath: String? = nil, properties: [String: Any]? = nil) -> PXAction? {
        let nonSplitDefaultAction: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.currentModal?.dismiss()
            self.selectFirstCardInSlider()
            self.trackDialogEvent(trackingPath: trackingPath, properties: properties)
        }
        let splitDefaultAction: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.currentModal?.dismiss()
        }

        guard let action = action else {
            return nil
        }

        guard let target = action.target else {
            let defaultAction = isSplit ? splitDefaultAction : nonSplitDefaultAction
            return PXAction(label: action.label, action: defaultAction)
        }

        return PXAction(label: action.label, action: { [weak self] in
            guard let self = self else { return }
            self.currentModal?.dismiss()
            self.openKyCDeeplinkWithoutCallback(target)
            self.trackDialogEvent(trackingPath: trackingPath, properties: properties)
        })
    }

    private func handlePayButton() {
        if let selectedCard = getSuspendedCardSliderViewModel(), let selectedApplication = selectedCard.selectedApplication {
            if let tapPayBehaviour = selectedApplication.behaviours?[PXBehaviour.Behaviours.tapPay.rawValue] {
                handleBehaviour(tapPayBehaviour, isSplit: false)
            }
        } else {
            confirmPayment()
        }
    }

    private func getSuspendedCardSliderViewModel() -> PXCardSliderViewModel? {
        if let selectedCard = selectedCard, let selectedApplication = selectedCard.selectedApplication, selectedApplication.status.detail == "suspended" {
            return selectedCard
        }
        return nil
    }

    private func confirmPayment() {
        isUIEnabled(false)
        if viewModel.shouldValidateWithBiometric() {
            viewModel.validateWithBiometric(onSuccess: { [weak self] in
                DispatchQueue.main.async {
                    self?.doPayment()
                }
            }, onError: { [weak self] _ in
                // User abort validation or validation fail.
                self?.isUIEnabled(true)
                self?.trackEvent(event: GeneralErrorTrackingEvents.error([:]))
            })
        } else {
            doPayment()
        }
    }

    private func doPayment() {
        subscribeLoadingButtonToNotifications()
        loadingButtonComponent?.startLoading(timeOut: timeOutPayButton)
        if let selectedCardItem = selectedCard, let selectedApplication = selectedCardItem.selectedApplication {
            viewModel.amountHelper.getPaymentData().payerCost = selectedApplication.selectedPayerCost
            let properties = viewModel.getConfirmEventProperties(selectedCard: selectedCardItem, selectedIndex: slider.getSelectedIndex())
            trackEvent(event: OneTapTrackingEvents.didConfirmPayment(properties))
        }
        let splitPayment = viewModel.splitPaymentEnabled
        hideBackButton()
        hideNavBar()
        callbackConfirm(viewModel.amountHelper.getPaymentData(), splitPayment)
    }

    func isUIEnabled(_ enabled: Bool) {
        view.isUserInteractionEnabled = enabled
        loadingButtonComponent?.isUserInteractionEnabled = enabled
    }

    func resetButton(error: MPSDKError) {
        progressButtonAnimationTimeOut()
        trackEvent(event: GeneralErrorTrackingEvents.error(viewModel.getErrorProperties(error: error)))
    }

    private func cancelPayment() {
        self.callbackExit()
    }

    private func openKyCDeeplinkWithoutCallback(_ target: String) {
        let index = target.firstIndex(of: "&")
        if let index = index {
            let deepLink = String(target[..<index])
            PXDeepLinkManager.open(deepLink)
        }
    }
}

// MARK: Summary delegate.
extension PXOneTapViewController: PXOneTapHeaderProtocol {
    func didTapBackButton() {
        executeBack()
    }

    func splitPaymentSwitchChangedValue(isOn: Bool, isUserSelection: Bool) {
        if isUserSelection, let selectedCard = getSuspendedCardSliderViewModel(), let selectedApplication = selectedCard.selectedApplication, let splitConfiguration = selectedApplication.amountConfiguration?.splitConfiguration, let switchSplitBehaviour = selectedApplication.behaviours?[PXBehaviour.Behaviours.switchSplit.rawValue] {
            handleBehaviour(switchSplitBehaviour, isSplit: true)
            splitConfiguration.splitEnabled = false
            headerView?.updateSplitPaymentView(splitConfiguration: splitConfiguration)
            return
        }

        viewModel.splitPaymentEnabled = isOn
        if isUserSelection {
            self.viewModel.splitPaymentSelectionByUser = isOn
            // Update all models payer cost and selected payer cost
            viewModel.updateAllCardSliderModels(splitPaymentEnabled: isOn)
        }

        // Update current card view
        if let selectedCard = self.selectedCard {
            self.newCardDidSelected(targetModel: selectedCard, forced: true)
        }
    }

    func didTapMerchantHeader() {
        if let externalVC = viewModel.getExternalViewControllerForSubtitle() {
            PXComponentFactory.Modal.show(viewController: externalVC, title: externalVC.title)
        }
    }

    func didTapCharges() {
        if let vc = viewModel.getChargeRuleViewController() {
            let defaultTitle = "Cargos".localized
            let title = vc.title ?? defaultTitle
            PXComponentFactory.Modal.show(viewController: vc, title: title) { [weak self] in
                if UIDevice.isSmallDevice() {
                    self?.setupNavigationBar()
                }
            }
        }
    }

    func didTapDiscount() {
        var discountDescription: PXDiscountDescription?

        guard let selectedApplication = selectedCard?.selectedApplication else { return }

        if let discountConfiguration = viewModel.amountHelper.paymentConfigurationService.getDiscountConfigurationForPaymentMethodOrDefault(paymentOptionID: selectedCard?.cardId, paymentMethodId: selectedApplication.paymentMethodId, paymentTypeId: selectedApplication.paymentTypeId),
            let description = discountConfiguration.getDiscountConfiguration().discountDescription {
            discountDescription = description
        }

        if let discountDescription = discountDescription {
            let discountViewController = PXDiscountDetailViewController(amountHelper: viewModel.amountHelper, discountDescription: PXDiscountDescriptionViewModel(discountDescription))
            if viewModel.amountHelper.discount != nil {
                PXComponentFactory.Modal.show(viewController: discountViewController, title: nil) {
                self.setupNavigationBar()
                }
            }
        }
    }
}

// MARK: CardSlider delegate.
extension PXOneTapViewController: PXCardSliderProtocol {
    func newCardDidSelected(targetModel: PXCardSliderViewModel, forced: Bool) {
        guard let selectedApplication = targetModel.selectedApplication else { return }

        selectedCard = targetModel

        if !forced {
            trackEvent(event: OneTapTrackingEvents.didSwipe)
        }

        // Update installment info row
        installmentInfoRow?.update(model: viewModel.getInstallmentInfoViewModel())

        let model = viewModel.getInstallmentInfoViewModel()
        let currentIndex = slider.getSelectedIndex()
        let selectedModel = model[currentIndex]

        // Installments
        if let installmentData = selectedModel.installmentData, installmentData.payerCosts.count > 1 {
            showInstallments(installmentData: selectedModel.installmentData, selectedPayerCost: selectedModel.selectedPayerCost, interest: selectedModel.benefits?.interestFree, reimbursement: selectedModel.benefits?.reimbursement)
        } else {
            hideInstallments()
        }

        guard let headerView = headerView else { return }

        // Add card. - card o credits payment method selected
        let validData = selectedApplication.cardData != nil || targetModel.isCredits
        let shouldDisplay = validData && !selectedApplication.status.isDisabled()
        if shouldDisplay {
            displayCard(targetModel: targetModel)
            loadingButtonComponent?.setEnabled()
        } else {
            displayCard(targetModel: targetModel)
            loadingButtonComponent?.setDisabled()
            headerView.updateModel(viewModel.getHeaderViewModel(selectedCard: nil, pxOneTapContext: pxOneTapContext))
        }
    }

    func displayCard(targetModel: PXCardSliderViewModel) {
        guard let selectedApplication = targetModel.selectedApplication else { return }

        // New payment method selected.
        let newPaymentMethodId: String = selectedApplication.payerPaymentMethod?.paymentMethodId ?? selectedApplication.paymentMethodId
        let newPayerCost: PXPayerCost? = selectedApplication.selectedPayerCost

        let currentPaymentData: PXPaymentData = viewModel.amountHelper.getPaymentData()

        if let newPaymentMethod = viewModel.getPaymentMethod(paymentMethodId: newPaymentMethodId) {
            currentPaymentData.payerCost = newPayerCost
            currentPaymentData.paymentMethod = newPaymentMethod
            currentPaymentData.issuer = selectedApplication.payerPaymentMethod?.issuer ?? PXIssuer(id: targetModel.issuerId, name: nil)

            currentPaymentData.amount = selectedApplication.payerPaymentMethod?.selectedPaymentOption?.amount
            currentPaymentData.taxFreeAmount = selectedApplication.payerPaymentMethod?.selectedPaymentOption?.taxFreeAmount
            currentPaymentData.noDiscountAmount = selectedApplication.payerPaymentMethod?.selectedPaymentOption?.noDiscountAmount

            if let taxFreeAmount = selectedApplication.payerPaymentMethod?.selectedPaymentOption?.taxFreeAmount {
                currentPaymentData.transactionAmount = NSDecimalNumber(string: String(taxFreeAmount))
            } else {
                currentPaymentData.transactionAmount = NSDecimalNumber(string: String(viewModel.amountHelper.preferenceAmountWithCharges))
            }

            currentPaymentData.paymentOptionId = targetModel.cardId ?? targetModel.selectedApplication?.paymentMethodId

            callbackUpdatePaymentOption(targetModel)
            loadingButtonComponent?.setEnabled()
        } else {
            currentPaymentData.payerCost = nil
            currentPaymentData.paymentMethod = nil
            currentPaymentData.issuer = nil
            currentPaymentData.paymentOptionId = nil
            loadingButtonComponent?.setDisabled()
        }
        headerView?.updateModel(viewModel.getHeaderViewModel(selectedCard: selectedCard, pxOneTapContext: pxOneTapContext))

        headerView?.updateSplitPaymentView(splitConfiguration: selectedApplication.amountConfiguration?.splitConfiguration)

        let paymentTypeId = selectedApplication.payerPaymentMethod?.paymentTypeId ?? selectedApplication.paymentTypeId

        // If it's debit and has split, update split message
        if let totalAmount = selectedApplication.selectedPayerCost?.totalAmount, paymentTypeId == PXPaymentTypes.DEBIT_CARD.rawValue {
            selectedApplication.displayMessage = viewModel.getSplitMessageForDebit(amountToPay: totalAmount)
        }
    }

    func selectFirstCardInSlider() {
        selectCardInSliderAtIndex(0)
    }

    func selectCardInSliderAtIndex(_ index: Int) {
        let cardSliderViewModel = viewModel.getCardSliderViewModel()
        if (0 ... cardSliderViewModel.count - 1).contains(index) {
            do {
                try slider.goToItemAt(index: index, animated: false)
            } catch {
                // We shouldn't reach this line. Track friction
                let properties = viewModel.getSelectCardEventProperties(index: index, count: cardSliderViewModel.count)
//                trackEvent(path: TrackingPaths.Events.getErrorPath(), properties: properties)
                selectFirstCardInSlider()
                return
            }
            let card = cardSliderViewModel[index]
            newCardDidSelected(targetModel: card, forced: false)
        }
    }

    func cardDidTap(status: PXStatus) {
        if status.isDisabled() {
            showDisabledCardModal(status: status)
        } else if let selectedCard = selectedCard, let selectedApplication = selectedCard.selectedApplication, let tapCardBehaviour = selectedApplication.behaviours?[PXBehaviour.Behaviours.tapCard.rawValue] {
            handleBehaviour(tapCardBehaviour, isSplit: false)
        }
    }

    func showDisabledCardModal(status: PXStatus) {
        guard let message = status.secondaryMessage else { return }

        let primaryAction = getActionForModal()
        let vc = PXOneTapDisabledViewController(title: nil, description: message, primaryButton: primaryAction, secondaryButton: nil, iconUrl: nil)

        self.currentModal = PXComponentFactory.Modal.show(viewController: vc, title: nil)

//        trackScreen(path: TrackingPaths.Screens.OneTap.getOneTapDisabledModalPath(), treatAsViewController: false)
    }

    func addNewCardDidTap() {
        if viewModel.shouldUseOldCardForm() {
            callbackPaymentData(viewModel.getClearPaymentData())
        } else {
            self.view.backgroundColor = ThemeManager.shared.navigationBar().backgroundColor
            if let newCard = viewModel.expressData?.compactMap({ $0.newCard }).first {
                if newCard.sheetOptions != nil {
                    // Present sheet to pick standard card form or webpay
                    let sheet = buildBottomSheet(newCard: newCard)
                    present(sheet, animated: true, completion: nil)
                } else {
                    // Add new card using card form based on init type
                    // There might be cases when there's a different option besides standard type
                    // Eg: Money In for Chile should use only debit, therefor init type shuld be webpay_tbk
                    addNewCard(initType: newCard.cardFormInitType)
                }
            } else {
                // This is a fallback. There should be always a newCard in expressData
                // Add new card using standard card form
                addNewCard()
            }
        }
    }

    private func buildBottomSheet(newCard: PXOneTapNewCardDto) -> AndesBottomSheetViewController {
        if let andesBottomSheet = andesBottomSheet {
            return andesBottomSheet
        }
        let viewController = PXOneTapSheetViewController(newCard: newCard)
        viewController.delegate = self
        let sheet = AndesBottomSheetViewController(rootViewController: viewController)
        sheet.titleBar.text = newCard.label.message
        sheet.titleBar.textAlignment = .center
        andesBottomSheet = sheet
        return sheet
    }

    private func addNewCard(initType: String? = "standard") {
        let siteId = viewModel.siteId
        let flowId = MPXTracker.sharedInstance.getFlowName() ?? "unknown"
        let builder: MLCardFormBuilder

        if let privateKey = viewModel.privateKey {
            builder = MLCardFormBuilder(privateKey: privateKey, siteId: siteId, flowId: flowId, acceptThirdPartyCard: viewModel.advancedConfiguration.acceptThirdPartyCard, activateCard: false, lifeCycleDelegate: self)
        } else {
            builder = MLCardFormBuilder(publicKey: viewModel.publicKey, siteId: siteId, flowId: flowId, acceptThirdPartyCard: viewModel.advancedConfiguration.acceptThirdPartyCard, activateCard: false, lifeCycleDelegate: self)
        }

        builder.setLanguage(Localizator.sharedInstance.getLanguage())
        builder.setExcludedPaymentTypes(viewModel.excludedPaymentTypeIds)
        builder.setNavigationBarCustomColor(backgroundColor: ThemeManager.shared.navigationBar().backgroundColor, textColor: ThemeManager.shared.navigationBar().tintColor)
        var cardFormVC: UIViewController
        switch initType {
        case "webpay_tbk":
            cardFormVC = MLCardForm(builder: builder).setupWebPayController()
        default:
            builder.setAnimated(true)
            cardFormVC = MLCardForm(builder: builder).setupController()
        }

        super.shouldHideNavigationBar = false
        super.shouldShowBackArrow = true

        navigationController?.setNavigationBarHidden(false, animated: false)

        navigationController?.pushViewController(cardFormVC, animated: true)
    }

    func addNewOfflineDidTap() {
        shouldHideOneTapNavBar = true
        shouldAddNewOfflineMethod()
    }

    func didScroll(offset: CGPoint) {
        installmentInfoRow?.setSliderOffset(offset: offset)
    }

    func didEndDecelerating() {
        installmentInfoRow?.didEndDecelerating()
    }

    func didEndScrollAnimation() {
        installmentInfoRow?.didEndScrollAnimation()
    }
}

extension PXOneTapViewController: PXOneTapSheetViewControllerProtocol {
    func didTapOneTapSheetOption(sheetOption: PXOneTapSheetOptionsDto) {
        andesBottomSheet?.dismiss(animated: true, completion: { [weak self] in
            self?.addNewCard(initType: sheetOption.cardFormInitType)
        })
    }
}

// MARK: Installment Row Info delegate.
extension PXOneTapViewController: PXOneTapInstallmentInfoViewProtocol, PXOneTapInstallmentsSelectorProtocol {
    func cardTapped(status: PXStatus) {
      cardDidTap(status: status)
    }

    func payerCostSelected(_ payerCost: PXPayerCost) {
        let selectedIndex = slider.getSelectedIndex()
        // Update cardSliderViewModel
        if let infoRow = installmentInfoRow, viewModel.updateCardSliderViewModel(newPayerCost: payerCost, forIndex: infoRow.getActiveRowIndex()) {
            // Update selected payer cost.
            let currentPaymentData: PXPaymentData = viewModel.amountHelper.getPaymentData()
            currentPaymentData.payerCost = payerCost
            // Update installmentInfoRow viewModel
            installmentInfoRow?.update(model: viewModel.getInstallmentInfoViewModel())
            PXFeedbackGenerator.heavyImpactFeedback()

            // Update card bottom message
            let bottomMessage = viewModel.getCardBottomMessage(paymentTypeId: selectedCard?.selectedApplication?.paymentTypeId, benefits: selectedCard?.selectedApplication?.benefits, status: selectedCard?.selectedApplication?.status, selectedPayerCost: payerCost, displayInfo: selectedCard?.displayInfo)
            viewModel.updateCardSliderModel(at: selectedIndex, bottomMessage: bottomMessage)
            slider.update(viewModel.getCardSliderViewModel())
        }

        let installmentsModel = viewModel.getInstallmentInfoViewModel()
        let selectedModel = installmentsModel[selectedIndex]
        guard let installmentsSelectorView = installmentsSelectorView as? PXOneTapInstallmentsSelectorView else { return }

        if let installmentData = selectedModel.installmentData {
            let viewModel = PXOneTapInstallmentsSelectorViewModel(installmentData: installmentData, selectedPayerCost: selectedModel.selectedPayerCost, interest: selectedModel.benefits?.interestFree, reimbursement: selectedModel.benefits?.reimbursement)
            installmentsSelectorView.update(viewModel: viewModel)
        }
    }

    func hideInstallments() {
        guard let installmentsWrapperView = self.installmentsWrapperView else { return }

        // Hide installmentsWrapperView
        installmentsWrapperView.isHidden = true

        // Show installmentRow
        installmentRow.isHidden = false

        view.layoutIfNeeded()
    }

    func showInstallments(installmentData: PXInstallment?, selectedPayerCost: PXPayerCost?, interest: PXInstallmentsConfiguration?, reimbursement: PXInstallmentsConfiguration?) {
        installmentRow.isHidden = true

        guard let installmentsWrapperView = self.installmentsWrapperView else { return }

        // Clear installmentsWrapperView
        installmentsWrapperView.removeAllSubviews()

        guard let installmentData = installmentData, let installmentInfoRow = installmentInfoRow else {
            return
        }

        if let selectedCardItem = selectedCard {
            let properties = self.viewModel.getInstallmentsScreenProperties(installmentData: installmentData, selectedCard: selectedCardItem)
//            trackScreen(path: TrackingPaths.Screens.OneTap.getOneTapInstallmentsPath(), properties: properties, treatAsViewController: false)
        }

        PXFeedbackGenerator.selectionFeedback()

        let viewModel = PXOneTapInstallmentsSelectorViewModel(installmentData: installmentData, selectedPayerCost: selectedPayerCost, interest: interest, reimbursement: reimbursement)
        let installmentsSelectorView = PXOneTapInstallmentsSelectorView(viewModel: viewModel)
        installmentsSelectorView.delegate = self
        self.installmentsSelectorView = installmentsSelectorView

        installmentsWrapperView.addArrangedSubview(installmentsSelectorView)

        PXLayout.matchWidth(ofView: installmentsSelectorView).isActive = true

        PXLayout.setHeight(owner: installmentsSelectorView, height: 125).isActive = true

        let divider = UIView()
        installmentsWrapperView.addArrangedSubview(divider)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .pxMediumLightGray
        PXLayout.setHeight(owner: divider, height: 1).isActive = true
        PXLayout.matchWidth(ofView: divider).isActive = true
        PXLayout.centerHorizontally(view: divider).isActive = true

        installmentsWrapperView.isHidden = false

        installmentsSelectorView.layoutIfNeeded()

        installmentsWrapperView.layoutIfNeeded()

        self.view.layoutIfNeeded()
        installmentsSelectorView.tableView.reloadData()
    }
}

// MARK: Payment Button animation delegate
@available(iOS 9.0, *)
extension PXOneTapViewController: PXAnimatedButtonDelegate {
    func shakeDidFinish() {
        displayBackButton()
        isUIEnabled(true)
        unsubscribeFromNotifications()
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingButtonComponent?.backgroundColor = ThemeManager.shared.getAccentColor()
        })
    }

    func expandAnimationInProgress() {
    }

    func didFinishAnimation() {
        self.finishButtonAnimation()
    }

    func progressButtonAnimationTimeOut() {
        loadingButtonComponent?.showErrorToast(title: "review_and_confirm_toast_error".localized, actionTitle: nil, type: MLSnackbarType.error(), duration: .short, action: nil)
    }
}

// MARK: Notifications
private extension PXOneTapViewController {
    func subscribeLoadingButtonToNotifications() {
        guard let loadingButton = loadingButtonComponent else {
            return
        }
        PXNotificationManager.SuscribeTo.animateButton(loadingButton, selector: #selector(loadingButton.animateFinish))
    }

    func unsubscribeFromNotifications() {
        PXNotificationManager.UnsuscribeTo.animateButton(loadingButtonComponent)
    }

    func addPulseViewNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    func removePulseViewNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Terms and Conditions
extension PXOneTapViewController: PXTermsAndConditionViewDelegate { }

// MARK: MLCardFormLifeCycleDelegate
extension PXOneTapViewController: MLCardFormLifeCycleDelegate {
    func didAddCard(cardID: String) {
        callbackRefreshInit(cardID)
    }

    func didFailAddCard() {
    }
}

// MARK: UINavigationControllerDelegate
extension PXOneTapViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if [fromVC, toVC].filter({ $0 is MLCardFormViewController || $0 is PXSecurityCodeViewController }).count > 0 {
            return PXOneTapViewControllerTransition()
        }
        return nil
    }
}
