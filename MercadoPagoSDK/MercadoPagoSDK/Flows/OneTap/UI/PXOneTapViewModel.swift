import Foundation
import MLCardDrawer

final class PXOneTapViewModel: PXReviewViewModel {
    var publicKey: String = ""
    var privateKey: String?
    var siteId: String = ""
    var excludedPaymentTypeIds: [String] = []
    // Privates
    private var cardSliderViewModel = [PXCardSliderViewModel]()
    private let installmentsRowMessageFontSize = PXLayout.XS_FONT
    // Publics
    var expressData: [PXOneTapDto]?
    var paymentMethods: [PXPaymentMethod] = [PXPaymentMethod]()
    var items: [PXItem] = [PXItem]()
    var payerCompliance: PXPayerCompliance?
    var modals: [String: PXModal]?
    var payerPaymentMethods: [PXCustomOptionSearchItem]
    var experimentsViewModel: PXExperimentsViewModel
    var applications: [PXOneTapApplication] = []

    var splitPaymentEnabled: Bool = false
    var splitPaymentSelectionByUser: Bool?
    var additionalInfoSummary: PXAdditionalInfoSummary?
    var disabledOption: PXDisabledOption?

    var cardType: MLCardDrawerTypeV3?

    // Current flow.
    weak var currentFlow: OneTapFlow?

    public init(amountHelper: PXAmountHelper, paymentOptionSelected: PaymentMethodOption?, advancedConfig: PXAdvancedConfiguration, userLogged: Bool, disabledOption: PXDisabledOption? = nil, currentFlow: OneTapFlow?, payerPaymentMethods: [PXCustomOptionSearchItem], experiments: [PXExperiment]?) {
        self.disabledOption = disabledOption
        self.currentFlow = currentFlow
        self.payerPaymentMethods = payerPaymentMethods
        self.experimentsViewModel = PXExperimentsViewModel(experiments)
        super.init(amountHelper: amountHelper, paymentOptionSelected: paymentOptionSelected, advancedConfig: advancedConfig, userLogged: userLogged)
    }

    override func shouldValidateWithBiometric(withCardId: String? = nil) -> Bool {
        guard let oneTapFlow = currentFlow else { return false }
        return !oneTapFlow.needSecurityCodeValidation()
    }
}

// MARK: ViewModels Publics.
extension PXOneTapViewModel {
    func createCardSliderViewModel(cardType: MLCardDrawerTypeV3) {
        self.cardType = cardType

        var sliderModel: [PXCardSliderViewModel] = []
        guard let oneTapNode = expressData else { return }

        // Rearrange disabled options
        let reArrangedNodes = rearrangeDisabledOption(oneTapNode, disabledOption: disabledOption)
        for targetNode in reArrangedNodes {
            // Charge rule message when amount is zero
            var chargeRuleMessage = getCardBottomMessage(paymentTypeId: targetNode.paymentTypeId, benefits: targetNode.benefits, status: targetNode.status, selectedPayerCost: nil, displayInfo: targetNode.displayInfo)
            let benefits = targetNode.benefits

            let statusConfig = getStatusConfig(currentStatus: targetNode.status, cardId: targetNode.oneTapCard?.cardId, paymentMethodId: targetNode.paymentMethodId)

            // Add New Card and Offline Payment Methods
            if targetNode.newCard != nil || targetNode.offlineMethods != nil {
                var newCardData: PXAddNewMethodData?
                if let newCard = targetNode.newCard {
                    newCardData = PXAddNewMethodData(title: newCard.label,
                                                     subtitle: newCard.descriptionText,
                                                     iconUrl: newCard.genericCardDisplayInfo?.iconUrl,
                                                     border: newCard.genericCardDisplayInfo?.border,
                                                     backgroundColor: newCard.genericCardDisplayInfo?.backgroundColor,
                                                     shadow: newCard.genericCardDisplayInfo?.shadow ?? false,
                                                     deeplink: newCard.deeplink,
                                                     bottomMessage: newCard.displayInfo?.bottomDescription)
                }
                var newOfflineData: PXAddNewMethodData?
                if let offlineMethods = targetNode.offlineMethods {
                    newOfflineData = PXAddNewMethodData(title: offlineMethods.label,
                                                        subtitle: offlineMethods.descriptionText,
                                                        iconUrl: offlineMethods.genericCardDisplayInfo?.iconUrl,
                                                        border: offlineMethods.genericCardDisplayInfo?.border,
                                                        backgroundColor: offlineMethods.genericCardDisplayInfo?.backgroundColor,
                                                        shadow: offlineMethods.genericCardDisplayInfo?.shadow ?? false,
                                                        deeplink: offlineMethods.deeplink,
                                                        bottomMessage: offlineMethods.displayInfo?.bottomDescription)
                }
                let emptyCard = EmptyCard(newCardData: newCardData, newOfflineData: newOfflineData)

                let cardSliderApplication = PXCardSliderApplicationData(paymentMethodId: "",
                                                                        paymentTypeId: "",
                                                                        cardData: nil,
                                                                        cardUI: emptyCard,
                                                                        payerCost: [PXPayerCost](),
                                                                        selectedPayerCost: nil,
                                                                        shouldShowArrow: false,
                                                                        amountConfiguration: nil,
                                                                        status: statusConfig,
                                                                        bottomMessage: chargeRuleMessage,
                                                                        benefits: benefits,
                                                                        payerPaymentMethod: nil,
                                                                        behaviours: targetNode.behaviours,
                                                                        displayInfo: targetNode.displayInfo,
                                                                        displayMessage: nil)

                var cardSliderApplications: [PXApplicationId: PXCardSliderApplicationData] = [:]

                cardSliderApplications[""] = cardSliderApplication

                let viewModelCard = PXCardSliderViewModel(cardSliderApplications, "", "", displayInfo: targetNode.displayInfo, comboSwitch: nil)

                sliderModel.append(viewModelCard)
            }
            //  Account money
            if let accountMoney = targetNode.accountMoney, let paymentMethodId = targetNode.paymentMethodId {
                let payerPaymentMethod = getPayerPaymentMethod(targetNode.paymentTypeId, targetNode.oneTapCard?.cardId)

                if let applications = targetNode.applications, applications.count > 0, let oneTapCard = targetNode.oneTapCard,
                   let cardData = getCardData(oneTapCard: oneTapCard) {
                    let viewModelCard = getCardSliderViewModelFor(targetNode: targetNode, oneTapCard: oneTapCard, cardData: cardData, applications: applications)
                    sliderModel.append(viewModelCard)
                } else {
                    let displayTitle = accountMoney.cardTitle ?? ""
                    let cardData = PXCardDataFactory().create(cardName: displayTitle, cardNumber: "", cardCode: "", cardExpiration: "")
                    let amountConfiguration = amountHelper.paymentConfigurationService.getAmountConfigurationForPaymentMethod(paymentOptionID: accountMoney.getId(), paymentMethodId: paymentMethodId, paymentTypeId: targetNode.paymentTypeId)

                    let isDefaultCardType = accountMoney.cardType == .defaultType
                    let isDisabled = targetNode.status.isDisabled()
                    let cardLogoImageUrl = accountMoney.paymentMethodImageURL
                    let color = accountMoney.color
                    let gradientColors = accountMoney.gradientColors

                    let cardUI: CardUI = isDefaultCardType ?
                                        AccountMoneyCard(isDisabled: isDisabled, cardLogoImageUrl: cardLogoImageUrl, color: color, gradientColors: gradientColors) :
                                        HybridAMCard(isDisabled: isDisabled, cardLogoImageUrl: cardLogoImageUrl, paymentMethodImageUrl: nil, color: color, gradientColors: gradientColors)

                    let attributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: UIFont.ml_regularSystemFont(ofSize: installmentsRowMessageFontSize), NSAttributedString.Key.foregroundColor: ThemeManager.shared.greyColor()]
                    let displayMessage = NSAttributedString(string: accountMoney.sliderTitle ?? "", attributes: attributes)

                    let cardSliderApplication = PXCardSliderApplicationData(paymentMethodId: paymentMethodId, paymentTypeId: targetNode.paymentTypeId, cardData: cardData, cardUI: cardUI, payerCost: [PXPayerCost](), selectedPayerCost: nil, shouldShowArrow: false, amountConfiguration: amountConfiguration, status: statusConfig, bottomMessage: chargeRuleMessage, benefits: benefits, payerPaymentMethod: payerPaymentMethod, behaviours: targetNode.behaviours, displayInfo: targetNode.displayInfo, displayMessage: displayMessage)

                    var cardSliderApplications: [PXApplicationId: PXCardSliderApplicationData] = [:]

                    cardSliderApplications[targetNode.paymentTypeId ?? PXPaymentTypes.ACCOUNT_MONEY.rawValue] = cardSliderApplication

                    let viewModelCard = PXCardSliderViewModel(cardSliderApplications, targetNode.paymentTypeId ?? PXPaymentTypes.ACCOUNT_MONEY.rawValue, "", accountMoney.getId(), displayInfo: targetNode.displayInfo, comboSwitch: nil)

                    viewModelCard.setAccountMoney(accountMoneyBalance: accountMoney.availableBalance)

                    sliderModel.append(viewModelCard)
                }
            } else if let oneTapCard = targetNode.oneTapCard,
                      let cardData = getCardData(oneTapCard: oneTapCard) {
                if let applications = targetNode.applications, applications.count > 0 {
                    let viewModelCard = getCardSliderViewModelFor(targetNode: targetNode, oneTapCard: oneTapCard, cardData: cardData, applications: applications)
                    sliderModel.append(viewModelCard)
                } else if let paymentMethodId = targetNode.paymentMethodId {
                    var applications: [PXOneTapApplication] = []

                    applications.append(PXOneTapApplication(paymentMethod: PXApplicationPaymentMethod(id: paymentMethodId, type: targetNode.paymentTypeId), validationPrograms: [], status: targetNode.status))

                    let viewModelCard = getCardSliderViewModelFor(targetNode: targetNode, oneTapCard: oneTapCard, cardData: cardData, applications: applications)
                    sliderModel.append(viewModelCard)
                }
            } else if let consumerCredits = targetNode.oneTapCreditsInfo,
                      let paymentMethodId = targetNode.paymentMethodId,
                      let amountConfiguration = amountHelper.paymentConfigurationService.getAmountConfigurationForPaymentMethod(paymentOptionID: paymentMethodId, paymentMethodId: paymentMethodId, paymentTypeId: targetNode.paymentTypeId) {
                let cardData = PXCardDataFactory().create(cardName: "", cardNumber: "", cardCode: "", cardExpiration: "")
                let creditsViewModel = PXCreditsViewModel(consumerCredits)

                let cardSliderApplication = PXCardSliderApplicationData(paymentMethodId: paymentMethodId, paymentTypeId: targetNode.paymentTypeId, cardData: cardData, cardUI: ConsumerCreditsCard(creditsViewModel, isDisabled: targetNode.status.isDisabled()), payerCost: amountConfiguration.payerCosts ?? [], selectedPayerCost: amountConfiguration.selectedPayerCost, shouldShowArrow: true, amountConfiguration: amountConfiguration, status: statusConfig, bottomMessage: chargeRuleMessage, benefits: benefits, payerPaymentMethod: getPayerPaymentMethod(targetNode.paymentTypeId, nil), behaviours: targetNode.behaviours, displayInfo: targetNode.displayInfo, displayMessage: nil)

                var cardSliderApplications: [PXApplicationId: PXCardSliderApplicationData] = [:]

                cardSliderApplications[targetNode.paymentTypeId ?? PXPaymentTypes.CONSUMER_CREDITS.rawValue] = cardSliderApplication

                let viewModelCard = PXCardSliderViewModel(cardSliderApplications, targetNode.paymentTypeId, "", PXPaymentTypes.CONSUMER_CREDITS.rawValue, creditsViewModel: creditsViewModel, displayInfo: targetNode.displayInfo, comboSwitch: nil)

                sliderModel.append(viewModelCard)
            } else if targetNode.offlineTapCard != nil, let paymentMethodId = targetNode.paymentMethodId {
                let templateCard = getOfflineCardUI(oneTap: targetNode)
                let cardData = PXCardDataFactory().create(cardName: "", cardNumber: "", cardCode: "", cardExpiration: "")
                var cardSliderApplications: [PXApplicationId: PXCardSliderApplicationData] = [:]
                let applicationName = targetNode.paymentTypeId ?? PXPaymentTypes.BANK_TRANSFER.rawValue
                let bottomMessage = paymentMethodId == PXPaymentMethodId.DEBIN.rawValue ? chargeRuleMessage : nil

                let attributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: UIFont.ml_regularSystemFont(ofSize: installmentsRowMessageFontSize), NSAttributedString.Key.foregroundColor: ThemeManager.shared.greyColor()]
                let displayMessage = NSAttributedString(string: targetNode.bankTransfer?.displayInfo?.sliderTitle ?? "", attributes: attributes)

                cardSliderApplications[applicationName] = PXCardSliderApplicationData(paymentMethodId: paymentMethodId, paymentTypeId: targetNode.paymentTypeId, cardData: cardData, cardUI: templateCard, payerCost: [], selectedPayerCost: nil, shouldShowArrow: false, amountConfiguration: nil, status: statusConfig, bottomMessage: bottomMessage, benefits: targetNode.benefits, payerPaymentMethod: nil, behaviours: targetNode.behaviours, displayInfo: targetNode.displayInfo, displayMessage: displayMessage)

                let viewModelCard = PXCardSliderViewModel(cardSliderApplications,
                                                          applicationName,
                                                          "",
                                                          "",
                                                          creditsViewModel: nil,
                                                          displayInfo: nil,
                                                          comboSwitch: nil)

                sliderModel.append(viewModelCard)
            } else if targetNode.bankTransfer != nil, let paymentMethodId = targetNode.paymentMethodId {
                let templateCard = getDebinCardUI(oneTap: targetNode)
                let cardData = PXCardDataFactory().create(cardName: "", cardNumber: "", cardCode: "", cardExpiration: "")
                var cardSliderApplications: [PXApplicationId: PXCardSliderApplicationData] = [:]
                let applicationName = targetNode.paymentTypeId ?? PXPaymentTypes.BANK_TRANSFER.rawValue
                let bottomMessage = chargeRuleMessage

                let attributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: UIFont.ml_regularSystemFont(ofSize: installmentsRowMessageFontSize), NSAttributedString.Key.foregroundColor: ThemeManager.shared.greyColor()]
                let displayMessage = NSAttributedString(string: targetNode.bankTransfer?.displayInfo?.sliderTitle ?? "", attributes: attributes)

                cardSliderApplications[applicationName] = PXCardSliderApplicationData(paymentMethodId: paymentMethodId, paymentTypeId: targetNode.paymentTypeId, cardData: cardData, cardUI: templateCard, payerCost: [], selectedPayerCost: nil, shouldShowArrow: false, amountConfiguration: nil, status: statusConfig, bottomMessage: bottomMessage, benefits: targetNode.benefits, payerPaymentMethod: getPayerPaymentMethod(targetNode.paymentTypeId, targetNode.bankTransfer?.id), behaviours: targetNode.behaviours, displayInfo: targetNode.displayInfo, displayMessage: displayMessage)

                let viewModelCard = PXCardSliderViewModel(cardSliderApplications,
                                                          applicationName,
                                                          "",
                                                          "",
                                                          creditsViewModel: nil,
                                                          displayInfo: nil,
                                                          comboSwitch: nil)

                sliderModel.append(viewModelCard)
            }
        }
        cardSliderViewModel = sliderModel
    }

    func getInstallmentInfoViewModel() -> [PXOneTapInstallmentInfoViewModel] {
        var model: [PXOneTapInstallmentInfoViewModel] = [PXOneTapInstallmentInfoViewModel]()
        let sliderViewModel = getCardSliderViewModel()
        for sliderNode in sliderViewModel {
            guard let selectedApplication = sliderNode.selectedApplication else { return model }

            let payerCost = selectedApplication.payerCost
            let selectedPayerCost = selectedApplication.selectedPayerCost
            let installment = PXInstallment(issuer: nil, payerCosts: payerCost, paymentMethodId: nil, paymentTypeId: nil)

            let emptyMessage = "".toAttributedString()
            let disabledMessage: NSAttributedString = selectedApplication.status.mainMessage?.getAttributedString(fontSize: installmentsRowMessageFontSize, textColor: ThemeManager.shared.getAccentColor()) ?? emptyMessage

            let shouldShowInstallmentsHeader = sliderNode.shouldShowInstallmentsHeader()

            if selectedApplication.status.isDisabled() {
                let disabledInfoModel = PXOneTapInstallmentInfoViewModel(
                    text: disabledMessage,
                    installmentData: nil,
                    selectedPayerCost: nil,
                    shouldShowArrow: false,
                    status: selectedApplication.status,
                    benefits: selectedApplication.benefits,
                    shouldShowInstallmentsHeader: shouldShowInstallmentsHeader,
                    behaviours: selectedApplication.behaviours
                )

                model.append(disabledInfoModel)
            } else if !selectedApplication.status.isUsable() {
                let disabledInfoModel = PXOneTapInstallmentInfoViewModel(
                    text: emptyMessage,
                    installmentData: nil,
                    selectedPayerCost: nil,
                    shouldShowArrow: false,
                    status: selectedApplication.status,
                    benefits: selectedApplication.benefits,
                    shouldShowInstallmentsHeader: shouldShowInstallmentsHeader,
                    behaviours: selectedApplication.behaviours)

                model.append(disabledInfoModel)
            } else if selectedApplication.paymentTypeId == PXPaymentTypes.DEBIT_CARD.rawValue {
                // If it's debit and has split, update split message
                if let amountToPay = selectedApplication.selectedPayerCost?.totalAmount {
                    // Hide value if splitEnabled equals null or false
                    let splitConfiguration = selectedApplication.amountConfiguration?.splitConfiguration
                    let splitEnabled = splitConfiguration?.splitEnabled ?? false
                    let amountMessage = getSplitMessageForDebit(amountToPay: amountToPay)
                    let displayMessage = splitEnabled ? amountMessage : emptyMessage
                    let installmentInfoModel = PXOneTapInstallmentInfoViewModel(
                        text: displayMessage,
                        installmentData: installment,
                        selectedPayerCost: selectedPayerCost,
                        shouldShowArrow: selectedApplication.shouldShowArrow,
                        status: selectedApplication.status,
                        benefits: selectedApplication.benefits,
                        shouldShowInstallmentsHeader: shouldShowInstallmentsHeader,
                        behaviours: selectedApplication.behaviours)

                    model.append(installmentInfoModel)
                }
            } else {
                if let displayMessage = selectedApplication.displayMessage {
                    let installmentInfoModel = PXOneTapInstallmentInfoViewModel(
                        text: displayMessage,
                        installmentData: installment,
                        selectedPayerCost: selectedPayerCost,
                        shouldShowArrow: selectedApplication.shouldShowArrow,
                        status: selectedApplication.status,
                        benefits: selectedApplication.benefits,
                        shouldShowInstallmentsHeader: shouldShowInstallmentsHeader,
                        behaviours: selectedApplication.behaviours)

                    model.append(installmentInfoModel)
                } else {
                    let isDigitalCurrency: Bool = sliderNode.creditsViewModel != nil
                    let installmentInfoModel = PXOneTapInstallmentInfoViewModel(text: getInstallmentInfoAttrText(selectedPayerCost, isDigitalCurrency, interestFreeConfig: selectedApplication.benefits?.interestFree),
                        installmentData: installment,
                        selectedPayerCost: selectedPayerCost,
                        shouldShowArrow: selectedApplication.shouldShowArrow,
                        status: selectedApplication.status,
                        benefits: selectedApplication.benefits,
                        shouldShowInstallmentsHeader: shouldShowInstallmentsHeader,
                        behaviours: selectedApplication.behaviours)

                    model.append(installmentInfoModel)
                }
            }
        }
        return model
    }

    func getHeaderViewModel(selectedCard: PXCardSliderViewModel?, pxOneTapContext: PXOneTapContext?) -> PXOneTapHeaderViewModel {
        let splitConfiguration = selectedCard?.selectedApplication?.amountConfiguration?.splitConfiguration
        let composer = PXSummaryComposer(amountHelper: amountHelper,
                                           additionalInfoSummary: additionalInfoSummary,
                                           selectedCard: selectedCard,
                                           shouldDisplayChargesHelp: shouldDisplayChargesHelp())
        updatePaymentData(composer: composer)
        let summaryData = composer.summaryItems
        // Populate header display data. From SP pref AdditionalInfo or instore retrocompatibility.
        let (headerTitle, headerSubtitle, headerImage) = getSummaryHeader(item: items.first, additionalInfoSummaryData: additionalInfoSummary)

        let headerVM = PXOneTapHeaderViewModel(icon: headerImage, title: headerTitle, subTitle: headerSubtitle, data: summaryData, splitConfiguration: splitConfiguration, pxOneTapContext: pxOneTapContext)
        return headerVM
    }

    func updatePaymentData(composer: PXSummaryComposer) {
        if let discountData = composer.getDiscountData() {
            let discountConfiguration = discountData.discountConfiguration
            let campaign = discountData.campaign
            let discount = discountConfiguration.getDiscountConfiguration().discount
            let consumedDiscount = !discountConfiguration.getDiscountConfiguration().isAvailable
            amountHelper.getPaymentData().setDiscount(discount, withCampaign: campaign, consumedDiscount: consumedDiscount)
        } else {
            amountHelper.getPaymentData().clearDiscount()
        }
    }

    func getSummaryHeader(item: PXItem?, additionalInfoSummaryData: PXAdditionalInfoSummary?) -> (title: String, subtitle: String?, image: UIImage) {
        var headerImage: UIImage = UIImage()
        var headerTitle: String = ""
        var headerSubtitle: String?
        if let defaultImage = ResourceManager.shared.getImage("MPSDK_review_iconoCarrito_white") {
            headerImage = defaultImage
        }

        if let additionalSummaryData = additionalInfoSummaryData, let additionalSummaryTitle = additionalSummaryData.title, !additionalSummaryTitle.isEmpty {
            // SP and new scenario based on Additional Info Summary
            headerTitle = additionalSummaryTitle
            headerSubtitle = additionalSummaryData.subtitle
            if let headerUrl = additionalSummaryData.imageUrl {
                headerImage = PXUIImage(url: headerUrl)
            }
        } else {
            // Instore scenario. Retrocompatibility
            // To deprecate. After instore migrate current preferences.

            // Title desc from item
            if let headerTitleStr = item?._description, headerTitleStr.isNotEmpty {
                headerTitle = headerTitleStr
            } else if let headerTitleStr = item?.title, headerTitleStr.isNotEmpty {
                headerTitle = headerTitleStr
            }
            headerSubtitle = nil
            // Image from item
            if let headerUrl = item?.getPictureURL(), headerUrl.isNotEmpty {
                headerImage = PXUIImage(url: headerUrl)
            }
        }
        return (title: headerTitle, subtitle: headerSubtitle, image: headerImage)
    }

    func getCardSliderViewModel() -> [PXCardSliderViewModel] {
        return cardSliderViewModel
    }

    func getCardSliderViewModel(cardId: String?) -> PXCardSliderViewModel? {
        return cardSliderViewModel.first(where: { $0.cardId == cardId })
    }

    func updateCardSliderModel(at index: Int, bottomMessage: PXCardBottomMessage?) {
        if cardSliderViewModel.indices.contains(index) {
            cardSliderViewModel[index].selectedApplication?.bottomMessage = bottomMessage
        }
    }

    func updateAllCardSliderModels(splitPaymentEnabled: Bool) {
        for index in cardSliderViewModel.indices {
            _ = updateCardSliderSplitPaymentPreference(splitPaymentEnabled: splitPaymentEnabled, forIndex: index)
        }
    }

    func updateCardSliderSplitPaymentPreference(splitPaymentEnabled: Bool, forIndex: Int) -> Bool {
        if cardSliderViewModel.indices.contains(forIndex) {
            if splitPaymentEnabled, let selectedApplication = cardSliderViewModel[forIndex].selectedApplication {
                selectedApplication.payerCost = selectedApplication.amountConfiguration?.splitConfiguration?.primaryPaymentMethod?.payerCosts ?? []
                selectedApplication.selectedPayerCost = selectedApplication.amountConfiguration?.splitConfiguration?.primaryPaymentMethod?.selectedPayerCost
                selectedApplication.amountConfiguration?.splitConfiguration?.splitEnabled = splitPaymentEnabled

                // Show arrow to switch installments
                if selectedApplication.payerCost.count > 1 {
                    selectedApplication.shouldShowArrow = true
                } else {
                    selectedApplication.shouldShowArrow = false
                }
                return true
            } else if let selectedApplication = cardSliderViewModel[forIndex].selectedApplication {
                selectedApplication.payerCost = selectedApplication.amountConfiguration?.payerCosts ?? []
                selectedApplication.selectedPayerCost = selectedApplication.amountConfiguration?.selectedPayerCost
                selectedApplication.amountConfiguration?.splitConfiguration?.splitEnabled = splitPaymentEnabled

                // Show arrow to switch installments
                if selectedApplication.payerCost.count > 1 {
                    selectedApplication.shouldShowArrow = true
                } else {
                    selectedApplication.shouldShowArrow = false
                }
                return true
            }
            return false
        }
        return false
    }

    func updateCardSliderViewModel(newPayerCost: PXPayerCost?, forIndex: Int) -> Bool {
        if cardSliderViewModel.indices.contains(forIndex), let selectedApplication = cardSliderViewModel[forIndex].selectedApplication {
            selectedApplication.selectedPayerCost = newPayerCost
            selectedApplication.userDidSelectPayerCost = true
            return true
        }
        return false
    }

    func updateCardSliderViewModel(pxCardSliderViewModel: [PXCardSliderViewModel]) {
        self.cardSliderViewModel = pxCardSliderViewModel
    }

    func getPaymentMethod(paymentMethodId: String) -> PXPaymentMethod? {
        return Utils.findPaymentMethod(paymentMethods, paymentMethodId: paymentMethodId)
    }

    func shouldDisplayChargesHelp() -> Bool {
        return getChargeRuleViewController() != nil
    }

    func getCardBottomMessage(paymentTypeId: String?, benefits: PXBenefits?, status: PXStatus?, selectedPayerCost: PXPayerCost?, displayInfo: PXOneTapDisplayInfo?) -> PXCardBottomMessage? {
        let defaultTextColor = UIColor.white
        let defaultBackgroundColor = ThemeManager.shared.noTaxAndDiscountLabelTintColor()

        if let displayInfoMessage = displayInfo?.bottomDescription {
            return PXCardBottomMessage(text: displayInfoMessage, fixed: true)
        }

        if let chargeRuleMessage = getChargeRuleBottomMessage(paymentTypeId), (status?.isUsable() ?? true) {
            let text = PXText(message: chargeRuleMessage, backgroundColor: nil, textColor: nil, weight: nil, alignment: nil)
            text.defaultTextColor = defaultTextColor
            text.defaultBackgroundColor = defaultBackgroundColor
            return PXCardBottomMessage(text: text, fixed: false)
        }

        guard let selectedInstallments = selectedPayerCost?.installments else {
            return nil
        }

        guard let reimbursementAppliedInstallments = benefits?.reimbursement?.appliedInstallments else {
            return nil
        }

        if reimbursementAppliedInstallments.contains(selectedInstallments), (status?.isUsable() ?? true) {
            let text = PXText(message: benefits?.reimbursement?.card?.message, backgroundColor: nil, textColor: nil, weight: nil, alignment: nil)
            text.defaultTextColor = defaultTextColor
            text.defaultBackgroundColor = defaultBackgroundColor
            return PXCardBottomMessage(text: text, fixed: false)
        }

        return nil
    }

    func getChargeRuleBottomMessage(_ paymentTypeId: String?) -> String? {
        let chargeRule = getChargeRule(paymentTypeId: paymentTypeId)
        return chargeRule?.message
    }

    func getChargeRuleViewController() -> UIViewController? {
        let paymentTypeId = amountHelper.getPaymentData().paymentMethod?.paymentTypeId

        let chargeRule = getChargeRule(paymentTypeId: paymentTypeId)
        let vc = chargeRule?.detailModal
        return vc
    }

    func getChargeRule(paymentTypeId: String?) -> PXPaymentTypeChargeRule? {
        guard let rules = amountHelper.chargeRules, let paymentTypeId = paymentTypeId else {
            return nil
        }
        let filteredRules = rules.filter({
            $0.paymentTypeId == paymentTypeId
        })
        return filteredRules.first
    }

    func shouldUseOldCardForm() -> Bool {
        if let newCardVersion = expressData?.filter({ $0.newCard != nil }).first?.newCard?.version {
            return newCardVersion == "v1"
        }
        return false
    }

    func shouldAutoDisplayOfflinePaymentMethods() -> Bool {
        guard let enabledOneTapCards = (expressData?.filter { $0.status.enabled }) else { return false }
        let enabledPureOfflineCards = enabledOneTapCards.filter { ($0.offlineMethods != nil) && ($0.newCard == nil) }
        return enabledOneTapCards.count == enabledPureOfflineCards.count
    }
}

// MARK: Privates.
extension PXOneTapViewModel {
    private func getInstallmentInfoAttrText(_ payerCost: PXPayerCost?, _ isDigitalCurrency: Bool = false, interestFreeConfig: PXInstallmentsConfiguration?) -> NSMutableAttributedString {
        let text: NSMutableAttributedString = NSMutableAttributedString(string: "")

        if let payerCostData = payerCost {
            // First attr
            let currency = SiteManager.shared.getCurrency()
            let firstAttributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: Utils.getSemiBoldFont(size: installmentsRowMessageFontSize), NSAttributedString.Key.foregroundColor: ThemeManager.shared.boldLabelTintColor()]
            let amountDisplayStr = Utils.getAmountFormated(amount: payerCostData.installmentAmount, forCurrency: currency).trimmingCharacters(in: .whitespaces)
            let firstText = "\(payerCostData.installments)x \(amountDisplayStr)"
            let firstAttributedString = NSAttributedString(string: firstText, attributes: firstAttributes)
            text.append(firstAttributedString)

            // Second attr
            if let interestFreeConfig = interestFreeConfig, interestFreeConfig.appliedInstallments.contains(payerCostData.installments), let rowMessage = interestFreeConfig.installmentRow?.getAttributedString(fontSize: installmentsRowMessageFontSize) {
                text.append(String.SPACE.toAttributedString())
                text.append(rowMessage)
            }

            // Third attr
            if let interestRate = payerCostData.interestRate,
                let thirdAttributedString = interestRate.getAttributedString(fontSize: installmentsRowMessageFontSize) {
                text.appendWithSpace(thirdAttributedString)
            }
        }
        return text
    }

    private func rearrangeDisabledOption(_ oneTapNodes: [PXOneTapDto], disabledOption: PXDisabledOption?) -> [PXOneTapDto] {
        guard let disabledOption = disabledOption else { return oneTapNodes }
        var rearrangedNodes = [PXOneTapDto]()
        var disabledNode: PXOneTapDto?
        for node in oneTapNodes {
            if disabledOption.isCardIdDisabled(cardId: node.oneTapCard?.cardId) || disabledOption.isPMDisabled(paymentMethodId: node.paymentMethodId) {
                disabledNode = node
            } else {
                rearrangedNodes.append(node)
            }
        }

        if let disabledNode = disabledNode {
            rearrangedNodes.append(disabledNode)
        }
        return rearrangedNodes
    }

    private func getCardData(oneTapCard: PXOneTapCardDto) -> CardData? {
        guard let cardName = oneTapCard.cardUI?.name,
              let cardNumber = oneTapCard.cardUI?.lastFourDigits,
              let cardExpiration = oneTapCard.cardUI?.expiration else {
            return nil
        }
        let cardData = PXCardDataFactory().create(cardName: cardName.uppercased(), cardNumber: cardNumber, cardCode: "", cardExpiration: cardExpiration, cardPattern: oneTapCard.cardUI?.cardPattern)
        return cardData
    }

    private func getOfflineCardUI(oneTap: PXOneTapDto) -> CardUI {
        let template = TemplatePIX()

        template.cardBackgroundColor = oneTap.offlineTapCard?.displayInfo?.color?.hexToUIColor() ?? .white
        template.titleName = oneTap.offlineTapCard?.displayInfo?.title?.message ?? ""
        template.titleWeight = oneTap.offlineTapCard?.displayInfo?.title?.weight ?? ""
        template.titleTextColor = oneTap.offlineTapCard?.displayInfo?.title?.textColor ?? ""
        template.subtitleName = oneTap.offlineTapCard?.displayInfo?.subtitle?.message ?? ""
        template.subtitleWeight = oneTap.offlineTapCard?.displayInfo?.title?.weight ?? ""
        template.subtitleTextColor = oneTap.offlineTapCard?.displayInfo?.subtitle?.textColor ?? ""
        template.labelName = oneTap.displayInfo?.tag?.message?.uppercased() ?? ""
        template.labelWeight = oneTap.displayInfo?.tag?.weight ?? ""
        template.labelTextColor = oneTap.displayInfo?.tag?.textColor ?? ""
        template.labelBackgroundColor = oneTap.displayInfo?.tag?.backgroundColor ?? ""
        template.logoImageURL = oneTap.offlineTapCard?.displayInfo?.paymentMethodImageUrl ?? ""
        template.gradientColors = oneTap.offlineTapCard?.displayInfo?.gradientColor ?? [""]

        return template
    }

    private func getDebinCardUI(oneTap: PXOneTapDto) -> CardUI {
        let template = TemplateDebin()

        template.cardBackgroundColor = oneTap.bankTransfer?.displayInfo?.color?.hexToUIColor() ?? .white
        template.titleName = oneTap.bankTransfer?.displayInfo?.title?.message ?? ""
        template.titleWeight = oneTap.bankTransfer?.displayInfo?.title?.weight ?? ""
        template.titleTextColor = oneTap.bankTransfer?.displayInfo?.title?.textColor ?? ""
        template.subtitleName = oneTap.bankTransfer?.displayInfo?.subtitle?.message ?? ""
        template.subtitleWeight = oneTap.bankTransfer?.displayInfo?.subtitle?.weight ?? ""
        template.subtitleTextColor = oneTap.bankTransfer?.displayInfo?.subtitle?.textColor ?? ""
        template.descriptionName = oneTap.bankTransfer?.displayInfo?.description?.message ?? ""
        template.descriptionWeight = oneTap.bankTransfer?.displayInfo?.description?.weight ?? ""
        template.descriptionTextColor = oneTap.bankTransfer?.displayInfo?.description?.textColor ?? ""
        template.labelName = oneTap.displayInfo?.tag?.message?.uppercased() ?? ""
        template.labelWeight = oneTap.displayInfo?.tag?.weight ?? ""
        template.labelTextColor = oneTap.displayInfo?.tag?.textColor ?? ""
        template.labelBackgroundColor = oneTap.displayInfo?.tag?.backgroundColor ?? ""
        template.logoImageURL = oneTap.bankTransfer?.displayInfo?.paymentMethodImageURL ?? ""
        template.gradientColors = oneTap.bankTransfer?.displayInfo?.gradientColor ?? [""]

        return template
    }

    private func getCardUI(oneTapCard: PXOneTapCardDto) -> CardUI {
        let templateCard = TemplateCard()
        guard let cardUI = oneTapCard.cardUI else {
            return templateCard
        }
        if let cardPattern = cardUI.cardPattern {
            templateCard.cardPattern = cardPattern
        }
        templateCard.securityCodeLocation = cardUI.securityCode?.cardLocation == "front" ? .front : .back
        if let codeLength = cardUI.securityCode?.length {
            templateCard.securityCodePattern = codeLength
        }
        if let cardBackgroundColor = cardUI.color {
            templateCard.cardBackgroundColor = cardBackgroundColor.hexToUIColor()
        }
        if let cardFontColor = cardUI.fontColor {
            templateCard.cardFontColor = cardFontColor.hexToUIColor()
        }
        if let cardLogoImageUrl = cardUI.paymentMethodImageUrl {
            templateCard.cardLogoImageUrl = cardLogoImageUrl
        }
        if let bankImageUrl = cardUI.issuerImageUrl {
            templateCard.bankImageUrl = bankImageUrl
        }
        return templateCard
    }

    private func getPayerPaymentMethod(_ paymentTypeId: String?, _ cardID: String?) -> PXCustomOptionSearchItem? {
        guard let paymentTypeId = paymentTypeId else { return nil }
        for payerPaymentMethod in payerPaymentMethods {
            switch paymentTypeId {
            case PXPaymentTypes.ACCOUNT_MONEY.rawValue,
                 PXPaymentTypes.DIGITAL_CURRENCY.rawValue:
                if paymentTypeId == payerPaymentMethod.paymentTypeId {
                    return payerPaymentMethod
                }
            case PXPaymentTypes.CREDIT_CARD.rawValue,
                 PXPaymentTypes.DEBIT_CARD.rawValue:
                if cardID == payerPaymentMethod.id && paymentTypeId == payerPaymentMethod.paymentTypeId {
                    return payerPaymentMethod
                }
            case PXPaymentTypes.BANK_TRANSFER.rawValue:
               if cardID == payerPaymentMethod.id && paymentTypeId == payerPaymentMethod.paymentTypeId {
                   return payerPaymentMethod
               }
            default:
                printDebug("PayerPaymentMethod not found")
            }
        }
        return nil
    }

    func getSplitMessageForDebit(amountToPay: Double) -> NSAttributedString {
        var amount: String = ""
        let attributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: UIFont.ml_regularSystemFont(ofSize: installmentsRowMessageFontSize), NSAttributedString.Key.foregroundColor: ThemeManager.shared.boldLabelTintColor()]

        amount = Utils.getAmountFormated(amount: amountToPay, forCurrency: SiteManager.shared.getCurrency())
        return NSAttributedString(string: amount, attributes: attributes)
    }

    func getStatusConfig(currentStatus: PXStatus, cardId: String?, paymentMethodId: String?) -> PXStatus {
        guard let disabledOption = disabledOption else { return currentStatus }

        if disabledOption.isCardIdDisabled(cardId: cardId) || disabledOption.isPMDisabled(paymentMethodId: paymentMethodId) {
            return disabledOption.getStatus() ?? currentStatus
        } else {
            return currentStatus
        }
    }

    func getExternalViewControllerForSubtitle() -> UIViewController? {
        return advancedConfiguration.dynamicViewControllersConfiguration.filter({
            $0.position(store: PXCheckoutStore.sharedInstance) == .DID_TAP_ONETAP_HEADER
        }).first?.viewController(store: PXCheckoutStore.sharedInstance)
    }

    func getOfflineMethods() -> PXOneTapNewPaymentMethodDto? {
        return expressData?
            .compactMap { $0.offlineMethods }
            .first
    }

    func getCardSliderViewModelFor(targetNode: PXOneTapDto, oneTapCard: PXOneTapCardDto, cardData: CardData, applications: [PXOneTapApplication]) -> PXCardSliderViewModel {
        self.applications.append(contentsOf: applications)

        let targetIssuerId = oneTapCard.cardUI?.issuerId ?? ""

        var cardSliderApplications: [PXApplicationId: PXCardSliderApplicationData] = [:]

        for application in applications {
            guard let paymentMethodId = application.paymentMethod.id else { continue }

            guard let paymentMethodType = application.paymentMethod.type else { continue }

            let paymentOptionConfiguration = amountHelper.paymentConfigurationService.getPaymentOptionConfiguration(paymentOptionID: oneTapCard.cardId, paymentMethodId: paymentMethodId, paymentTypeId: paymentMethodType)
            let amountConfiguration = paymentOptionConfiguration?.amountConfiguration
            let splitEnabled = amountConfiguration?.splitConfiguration?.splitEnabled ?? false
            let defaultPayerCost = [PXPayerCost]()
            let payerCosts = splitEnabled ? amountConfiguration?.splitConfiguration?.primaryPaymentMethod?.payerCosts : amountConfiguration?.payerCosts
            let selectedPayerCost = splitEnabled ? amountConfiguration?.splitConfiguration?.primaryPaymentMethod?.selectedPayerCost : amountConfiguration?.selectedPayerCost

            var showArrow: Bool = true
            var displayMessage: NSAttributedString?

            if paymentMethodType == PXPaymentTypes.DEBIT_CARD.rawValue {
                showArrow = false
                if let totalAmount = selectedPayerCost?.totalAmount {
                    // If it's debit and has split, update split message
                    displayMessage = getSplitMessageForDebit(amountToPay: totalAmount)
                }
            } else if payerCosts?.count == 1 {
                showArrow = false
            } else if payerCosts == nil {
                showArrow = false
            }

            let statusConfig = getStatusConfig(currentStatus: application.status, cardId: targetNode.oneTapCard?.cardId, paymentMethodId: targetNode.paymentMethodId)

            let chargeRuleMessage = getCardBottomMessage(paymentTypeId: paymentMethodType, benefits: targetNode.benefits, status: application.status, selectedPayerCost: selectedPayerCost, displayInfo: targetNode.displayInfo)

            let payerPaymentMethod = getPayerPaymentMethod(paymentMethodType, oneTapCard.cardId)

            var cardUI = getCardUI(oneTapCard: oneTapCard)

            if oneTapCard.cardUI?.displayType == .hybrid {
                let cardLogoImageUrl = targetNode.oneTapCard?.cardUI?.issuerImageUrl
                let paymentMethodImageUrl = targetNode.oneTapCard?.cardUI?.paymentMethodImageUrl
                let color = targetNode.oneTapCard?.cardUI?.color
                let gradientColors: [String] = []

                if application.paymentMethod.id == PXPaymentTypes.ACCOUNT_MONEY.rawValue {
                    // If it's hybrid and account_money application
                    cardUI = HybridAMCard(isDisabled: application.status.isDisabled(), cardLogoImageUrl: cardLogoImageUrl, paymentMethodImageUrl: nil, color: color, gradientColors: gradientColors)
                } else {
                    // If it's hybrid but credit_card application
                    cardUI = HybridAMCard(isDisabled: application.status.isDisabled(), cardLogoImageUrl: paymentMethodImageUrl, paymentMethodImageUrl: cardLogoImageUrl, color: color, gradientColors: gradientColors)
                }
            }

            let behaviours = application.behaviours ?? targetNode.behaviours

            let cardSliderApplication = PXCardSliderApplicationData(paymentMethodId: paymentMethodId, paymentTypeId: paymentMethodType, cardData: cardData, cardUI: cardUI, payerCost: payerCosts ?? defaultPayerCost, selectedPayerCost: selectedPayerCost, shouldShowArrow: showArrow, amountConfiguration: amountConfiguration, status: statusConfig, bottomMessage: chargeRuleMessage, benefits: PXPaymentTypes.CREDIT_CARD.rawValue == paymentMethodType ? targetNode.benefits : nil, payerPaymentMethod: payerPaymentMethod, behaviours: behaviours, displayInfo: targetNode.displayInfo, displayMessage: displayMessage)

            cardSliderApplications[paymentMethodType] = cardSliderApplication
        }

        var selectedApplicationId = applications.first?.paymentMethod.type
        var comboSwitch: ComboSwitchView?

        if let switchInfo = targetNode.displayInfo?.switchInfo {
            comboSwitch = cardType == .small ? ComboSwitchSmallView() : ComboSwitchLargeView()
            selectedApplicationId = switchInfo.defaultState
            comboSwitch?.setSwitchModel(switchInfo)
        }

        let viewModelCard = PXCardSliderViewModel(cardSliderApplications, selectedApplicationId, targetIssuerId, oneTapCard.cardId, displayInfo: targetNode.displayInfo, comboSwitch: comboSwitch)

        return viewModelCard
    }
}

struct PXCardBottomMessage {
    let text: PXText
    let fixed: Bool
}
