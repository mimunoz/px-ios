import MLCardForm
import AndesUI
import MLUI

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

            currentPaymentData.paymentMethod?.bankTransferDisplayInfo = selectedApplication.payerPaymentMethod?.displayInfo

            currentPaymentData.paymentOptionId = targetModel.cardId ?? targetModel.selectedApplication?.paymentMethodId

            if selectedApplication.paymentTypeId == PXPaymentTypes.BANK_TRANSFER.rawValue {
                let transactionInfo = PXTransactionInfo()

                let bankInfo = PXBankInfo()

                bankInfo.accountId = selectedApplication.payerPaymentMethod?.id

                transactionInfo.bankInfo = bankInfo

                if let financialInstitution = newPaymentMethod.financialInstitutions?[0] {
                    transactionInfo.financialInstitutionId = financialInstitution.id
                }

                currentPaymentData.transactionInfo = transactionInfo
            } else {
                currentPaymentData.transactionInfo = nil
            }

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

        let primaryAction = getActionForModal(PXRemoteAction(label: status.label?.message ?? "Pagar con otro medio".localized, target: ""))

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
                    if let data = selectedCard?.cardUI as? EmptyCard,
                        let deeplink = data.newCardData?.deeplink,
                        let url = URL(string: deeplink) {
                        showLoadingView()
                        PXConfiguratorManager.mlCommonsProtocol.open(url: url, from: self) { [weak self] result in
                            if let accountId = result?["external_account_id"] as? String,
                                let hashedAccountId = accountId.data(using: .utf8)?.sha1 {
                                self?.callbackNewBankAccount(hashedAccountId)
                            } else {
                                self?.hideLoadingViewIfNeeded()
                            }
                        }
                    } else {
                        addNewCard(initType: newCard.cardFormInitType)
                    }
                }
            } else {
                // This is a fallback. There should be always a newCard in expressData
                // Add new card using standard card form
                addNewCard()
            }
        }
    }

    private func buildBottomSheet(newCard: PXOneTapNewPaymentMethodDto) -> AndesBottomSheetViewController {
        if let andesBottomSheet = andesBottomSheet {
            return andesBottomSheet
        }
        let viewController = PXOneTapSheetViewController(newCard: newCard)
        viewController.delegate = self
        let sheet = AndesBottomSheetViewController(rootViewController: viewController)
        sheet.titleBar.text = newCard.label?.message
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
        guard let installmentsContainerView = self.installmentsContainerView else { return }

        // Hide installmentsContainerView
        installmentsContainerView.isHidden = true

        // Show installmentRow
        installmentRow.isHidden = false

        view.layoutIfNeeded()
    }

    func showInstallments(installmentData: PXInstallment?, selectedPayerCost: PXPayerCost?, interest: PXInstallmentsConfiguration?, reimbursement: PXInstallmentsConfiguration?) {
        installmentRow.isHidden = true

        guard let installmentsContainerView = self.installmentsContainerView else { return }

        // Clear installmentsContainerView
        installmentsContainerView.removeAllSubviews()

        guard let installmentData = installmentData, let installmentInfoRow = installmentInfoRow else {
            return
        }

        if let selectedCardItem = selectedCard {
            let properties = self.viewModel.getInstallmentsScreenProperties(installmentData: installmentData, selectedCard: selectedCardItem)
        }

        PXFeedbackGenerator.selectionFeedback()

        let viewModel = PXOneTapInstallmentsSelectorViewModel(installmentData: installmentData, selectedPayerCost: selectedPayerCost, interest: interest, reimbursement: reimbursement)
        let installmentsSelectorView = PXOneTapInstallmentsSelectorView(viewModel: viewModel)
        installmentsSelectorView.delegate = self
        self.installmentsSelectorView = installmentsSelectorView

        installmentsContainerView.addArrangedSubview(installmentsSelectorView)

        PXLayout.matchWidth(ofView: installmentsSelectorView).isActive = true

        PXLayout.setHeight(owner: installmentsSelectorView, height: 125).isActive = true

        let divider = UIView()
        installmentsContainerView.addArrangedSubview(divider)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .pxMediumLightGray
        PXLayout.setHeight(owner: divider, height: 1).isActive = true
        PXLayout.matchWidth(ofView: divider).isActive = true
        PXLayout.centerHorizontally(view: divider).isActive = true

        installmentsContainerView.isHidden = false

        installmentsSelectorView.layoutIfNeeded()

        installmentsContainerView.layoutIfNeeded()

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

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController is PXSecurityCodeViewController {
            unsubscribeFromNotifications()
        }
    }
}
