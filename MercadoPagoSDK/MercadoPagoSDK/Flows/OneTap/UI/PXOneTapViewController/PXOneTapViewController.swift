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
    var viewModel: PXOneTapViewModel
    var pxOneTapContext: PXOneTapContext
    private var discountTermsConditionView: PXTermsAndConditionView?

    let slider = PXCardSlider()

    // MARK: Callbacks
    var callbackNewBankAccount: ((String) -> Void)
    var callbackPaymentData: ((PXPaymentData) -> Void)
    var callbackConfirm: ((PXPaymentData, Bool) -> Void)
    var callbackUpdatePaymentOption: ((PaymentMethodOption) -> Void)
    var callbackRefreshInit: ((String) -> Void)
    var callbackExit: (() -> Void)
    var finishButtonAnimation: (() -> Void)

    var loadingButtonComponent: PXAnimatedButton?
    var installmentInfoRow: PXOneTapInstallmentInfoView?
    var installmentsSelectorView: UIView?
    var footerView: UIView?
    var headerView: PXOneTapHeaderView?
    var bodyView: UIStackView?
    var cardSliderContentView: UIStackView?
    var selectedCard: PXCardSliderViewModel?
    var installmentsContainerView: UIStackView?

    var currentModal: MLModal?
    var shouldTrackModal: Bool = false
    var currentModalDismissTrackingProperties: [String: Any]?
    let timeOutPayButton: TimeInterval
    var shouldHideOneTapNavBar: Bool = false

    var shouldPromptForOfflineMethods = true
    private var navigationBarTapGesture: UITapGestureRecognizer?
    var installmentRow = PXOneTapInstallmentInfoView()
    var andesBottomSheet: AndesBottomSheetViewController?
//    let loadingVC = PXLoadingViewController()
    var amountOfButtonPress: Int = 0

    var cardType: MLCardDrawerTypeV3

    var strategyTracking: StrategyTrackings = ImpletationStrategy()
    var isPaymentToggle = IsPaymentToggle.noPaying

    // MARK: Lifecycle/Publics
    init(viewModel: PXOneTapViewModel,
         pxOneTapContext: PXOneTapContext,
         timeOutPayButton: TimeInterval = 15,
         callbackNewBankAccount: @escaping ((String) -> Void),
         callbackPaymentData : @escaping ((PXPaymentData) -> Void),
         callbackConfirm: @escaping ((PXPaymentData, Bool) -> Void),
         callbackUpdatePaymentOption: @escaping ((PaymentMethodOption) -> Void),
         callbackRefreshInit: @escaping ((String) -> Void),
         callbackExit: @escaping (() -> Void),
         finishButtonAnimation: @escaping (() -> Void)) {
        self.viewModel = viewModel
        self.pxOneTapContext = pxOneTapContext
        self.callbackNewBankAccount = callbackNewBankAccount
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

        strategyTracking.getPropertieFlow(flow: "PXOneTapViewController")
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

            hideLoadingViewIfNeeded()
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
    func setupNavigationBar() {
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
        view.layer.masksToBounds = true

        let contentView = getContentView()

        setupHeaderView(to: contentView)

        setupBodyView(to: contentView)

        setupInstallmentsContainer()

        setupInstallmentRow()

        setupSpacerView()

        setupCardSliderView()

        setupInstallmentInfoRow()

        setupFooterView()

        view.layoutIfNeeded()

        DispatchQueue.main.async {
            if let selectedCard = self.selectedCard {
                self.newCardDidSelected(targetModel: selectedCard, forced: true)
            }
        }
    }

    private func getContentView() -> UIStackView {
        let contentView = UIStackView()

        contentView.axis = .vertical
        contentView.alignment = .center
        contentView.distribution = .fill
        contentView.addBackground(color: UIColor.Andes.white)
        view.addSubview(contentView)

        let contentViewHeight = PXLayout.getAvailabelScreenHeightWithStatusBarOnly(in: self)

        PXLayout.matchWidth(ofView: contentView)
        PXLayout.setHeight(owner: contentView, height: contentViewHeight)
        PXLayout.pinBottom(view: contentView)

        return contentView
    }

    private func setupHeaderView(to contentView: UIStackView) {
        let headerView = getHeaderView(selectedCard: selectedCard, pxOneTapContext: self.pxOneTapContext)
        self.headerView = headerView

        contentView.addArrangedSubview(headerView)
        PXLayout.centerHorizontally(view: headerView).isActive = true
        PXLayout.matchWidth(ofView: headerView).isActive = true
    }

    private func setupBodyView(to contentView: UIStackView) {
        let bodyView = getBodyView()
        self.bodyView = bodyView

        contentView.addArrangedSubview(bodyView)
        view.layoutIfNeeded()
        PXLayout.matchWidth(ofView: bodyView, toView: view).isActive = true
        PXLayout.centerHorizontally(view: bodyView).isActive = true
    }

    private func setupInstallmentsContainer() {
        let installmentsContainerView = UIStackView()
        installmentsContainerView.axis = .vertical
        installmentsContainerView.isHidden = true
        self.installmentsContainerView = installmentsContainerView

        PXLayout.matchWidth(ofView: installmentsContainerView)
        bodyView?.addArrangedSubview(installmentsContainerView)
    }

    private func setupInstallmentRow() {
        installmentRow = getInstallmentInfoView()
        installmentRow.isHidden = true
        bodyView?.addArrangedSubview(installmentRow)
    }

    private func setupSpacerView() {
        if let bodyView = bodyView, cardType == .small {
            let spacerView = UIView()
            spacerView.translatesAutoresizingMaskIntoConstraints = false
            spacerView.backgroundColor = .white
            bodyView.addArrangedSubview(spacerView)
            NSLayoutConstraint.activate([
                spacerView.heightAnchor.constraint(equalToConstant: 10),
                spacerView.leadingAnchor.constraint(equalTo: bodyView.leadingAnchor),
                spacerView.trailingAnchor.constraint(equalTo: bodyView.trailingAnchor)
            ])
        }
    }

    private func setupInstallmentInfoRow() {
        guard let cardSliderContentView = cardSliderContentView else { return }
        let installmentRowWidth: CGFloat = slider.getItemSize(cardSliderContentView).width
        installmentRow.render(installmentRowWidth)
    }

    private func setupCardSliderView() {
        guard let bodyView = bodyView else { return }
        let cardSliderContentView = UIStackView()

        cardSliderContentView.axis = .vertical

        self.cardSliderContentView = cardSliderContentView

        bodyView.addArrangedSubview(cardSliderContentView)

        slider.cardType = cardType

        cardSliderContentView.translatesAutoresizingMaskIntoConstraints = false
        PXLayout.matchWidth(ofView: cardSliderContentView)

        view.layoutIfNeeded()

        NSLayoutConstraint.activate([
            cardSliderContentView.heightAnchor.constraint(equalTo: cardSliderContentView.widthAnchor, multiplier: PXCardSliderSizeManager.aspectRatio(forType: cardType)),
            cardSliderContentView.leadingAnchor.constraint(equalTo: bodyView.leadingAnchor)
        ])
    }

    private func setupFooterView() {
        guard let footerView = getFooterView() else { return }
        self.footerView = footerView
        bodyView?.addArrangedSubview(footerView)
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

    private func getBodyView() -> UIStackView {
        let bodyView = UIStackView()// UIView()
        bodyView.axis = .vertical

        if #available(iOS 14.0, *) {
            bodyView.backgroundColor = .white
        } else {
            // Fallback for coloring stackview background on iOS < 14
            let backgroundView = UIView()
            backgroundView.backgroundColor = .white

            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            bodyView.insertSubview(backgroundView, at: 0)
            PXLayout.pinAllEdges(view: backgroundView)
        }

        return bodyView
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

    func handleBehaviour(_ behaviour: PXBehaviour, isSplit: Bool) {
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
        if shouldTrackModal, let trackingPath = trackingPath, var properties = properties {
            shouldTrackModal = false

            // Remove unnecessary tracks for path: /px_checkout/dialog/dismiss
            if trackingPath == TrackingPaths.Events.OneTap.getDialogDismissPath() {
                properties.removeValue(forKey: "type")
                properties.removeValue(forKey: "deep_link")
            }

            trackEvent(event: OneTapTrackingEvents.didDismissDialog(properties))
        }
    }

    func getActionForModal(_ action: PXRemoteAction? = nil, isSplit: Bool = false, trackingPath: String? = nil, properties: [String: Any]? = nil) -> PXAction? {
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
        amountOfButtonPress += 1
        strategyTracking.getPropertieFlow(flow: "handlePayButton, buttonPressed \(amountOfButtonPress), isPaymenttoggle \(isPaymentToggle)")
        if let selectedCard = getSuspendedCardSliderViewModel(), let selectedApplication = selectedCard.selectedApplication {
            if let tapPayBehaviour = selectedApplication.behaviours?[PXBehaviour.Behaviours.tapPay.rawValue] {
                handleBehaviour(tapPayBehaviour, isSplit: false)
            }
        } else {
            if !(isPaymentToggle.isPayment() ?? false) {
                confirmPayment()
            }
        }
    }

    func getSuspendedCardSliderViewModel() -> PXCardSliderViewModel? {
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

        let resultTracking = strategyTracking.getPropertiesTrackings(versionLib: "", counter: amountOfButtonPress, paymentMethod: viewModel.amountHelper.getPaymentData().paymentMethod, offlinePaymentMethod: nil, businessResult: nil)
        trackEvent(event: PXPaymentsInfoGeneralEvents.infoGeneral_Follow_Confirm_Payments(resultTracking))

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

// MARK: Notifications
extension PXOneTapViewController {
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

// MARK: Loading View
extension PXOneTapViewController {
    func showLoadingView() {
        let loadingVC = PXLoadingViewController()
        loadingVC.willMove(toParent: self)
        self.addChild(loadingVC)
        self.view.addSubview(loadingVC.view)
        loadingVC.didMove(toParent: self)
        loadingVC.view.bounds = self.view.bounds
    }

    func hideLoadingViewIfNeeded() {
        let animationLoader = self.children.last
        if let loaderViewController = animationLoader,
           loaderViewController.isKind(of: PXLoadingViewController.self) {
            animationLoader?.view.removeFromSuperview()
            animationLoader?.removeFromParent()
            animationLoader?.didMove(toParent: nil)
        }
    }
}
