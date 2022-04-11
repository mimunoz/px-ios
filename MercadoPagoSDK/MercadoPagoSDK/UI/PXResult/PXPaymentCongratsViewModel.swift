import Foundation

class PXPaymentCongratsViewModel {
    private let paymentCongrats: PXPaymentCongrats

    init(paymentCongrats: PXPaymentCongrats) {
        self.paymentCongrats = paymentCongrats
    }

    func launch(navigationHandler: PXNavigationHandler, showWithAnimation animated: Bool, finishButtonAnimation: (() -> Void)? = nil) {
        let viewController = PXNewResultViewController(viewModel: self, finishButtonAnimation: finishButtonAnimation)
        navigationHandler.pushViewController(viewController: viewController, animated: animated)
    }

    // MARK: Private methods
    private func createPaymentMethodReceiptData(from paymentInfo: PXCongratsPaymentInfo) -> PXNewCustomViewData {
        let firstString = PXNewResultUtil.formatPaymentMethodFirstString(paymentInfo: paymentInfo)

        var subtitles: (secondString: NSAttributedString?,
                        thirdString: NSAttributedString?,
                        fourthString: NSAttributedString?)

        var bottomText: NSAttributedString?
        var iconURL: String?

        if let displayInfo = paymentInfo.displayInfo {
            subtitles = getSubtitles(from: displayInfo.result?.paymentMethod?.detail)

            iconURL = displayInfo.result?.paymentMethod?.iconUrl
        }

        if let extraInfo = paymentInfo.displayInfo?.result?.extraInfo,
           let detail = extraInfo.detail {
            bottomText = getBottomText(detail)
        } else {
            subtitles.secondString = PXNewResultUtil.formatPaymentMethodSecondString(paymentMethodName: paymentInfo.paymentMethodName,
                                                                           paymentMethodLastFourDigits: paymentInfo.paymentMethodLastFourDigits,
                                                                           paymentType: paymentInfo.paymentMethodType)
            subtitles.thirdString = PXNewResultUtil.formatBankTransferSecondaryString(paymentInfo.paymentMethodDescription)
            iconURL = paymentInfo.paymentMethodIconURL
        }

        let defaultIcon = ResourceManager.shared.getImage("PaymentGeneric")

        return PXNewCustomViewData(firstString: firstString,
                                   secondString: subtitles.secondString,
                                   thirdString: subtitles.thirdString,
                                   fourthString: subtitles.fourthString,
                                   bottomString: bottomText,
                                   icon: defaultIcon,
                                   iconURL: iconURL,
                                   action: nil,
                                   color: .white)
    }

    private func getSubtitles(from array: [PXText]?) -> (NSAttributedString?, NSAttributedString?, NSAttributedString?) {
        var secondaryTexts = [NSAttributedString?](repeating: nil, count: 3)
        var index = 0

        array?.forEach({ text in
            secondaryTexts[index] = PXNewResultUtil.formatBankTransferSecondaryString(text.message)
            index += 1
        })

        return (secondString: secondaryTexts[0],
                thirdString: secondaryTexts[1],
                fourthString: secondaryTexts[2])
    }

    private func getBottomText(_ texts: [PXText]? ) -> NSMutableAttributedString? {
        var combinedText = NSMutableAttributedString()

        if let texts = texts {
            for eachText in texts {
                if let text = eachText.getAttributedString(fontSize: PXLayout.XXS_FONT) {
                    combinedText.append(text)
                    if text != texts.last {
                        combinedText.append(NSAttributedString(string: "\n\n"))
                    }
                }
            }
        }
        return combinedText
    }
}

extension PXPaymentCongratsViewModel: PXNewResultViewModelInterface {
    func getCloseButtonTrack() -> PXResultTrackingEvents {
        return .didTapOnCloseButton(initiative: .paymentCongrats, status: paymentCongrats.type.getRawValue())
    }

    func getStatusPayment() -> String {
        return paymentCongrats.type.getRawValue()
    }

    func getAndesMessage() -> InfoOperation? {
        return paymentCongrats.infoOperation
    }

    // HEADER
    func getHeaderColor() -> UIColor {
        guard let color = paymentCongrats.headerColor else {
            return ResourceManager.shared.getResultColorWith(status: paymentCongrats.type.getDescription())
        }
        return color
    }

    func getHeaderTitle() -> String {
        return paymentCongrats.headerTitle
    }

    func getHeaderIcon() -> UIImage? {
        return paymentCongrats.headerImage
    }

    func getHeaderURLIcon() -> String? {
        return paymentCongrats.headerURL
    }

    func getHeaderBadgeImage() -> UIImage? {
        return paymentCongrats.headerBadgeImage
    }

    func getHeaderCloseAction() -> (() -> Void)? {
        return paymentCongrats.headerCloseAction
    }

    // RECEIPT
    func mustShowReceipt() -> Bool {
        return paymentCongrats.shouldShowReceipt
    }

    func getReceiptId() -> String? {
        return paymentCongrats.receiptId
    }

    // POINTS AND DISCOUNTS
    /// POINTS
    func getPoints() -> PXPoints? {
        return paymentCongrats.points
    }

    func getPointsTapAction() -> ((String) -> Void)? {
        let action: (String) -> Void = { deepLink in
            // open deep link
            PXDeepLinkManager.open(deepLink)
            MPXTracker.sharedInstance.trackEvent(event: PXResultTrackingEvents.didTapOnScore)
        }
        return action
    }

    /// DISCOUNTS
    func getDiscounts() -> PXDiscounts? {
        return paymentCongrats.discounts
    }

    func getDiscountsTapAction() -> ((Int, String?, String?) -> Void)? {
        let action: (Int, String?, String?) -> Void = { index, deepLink, trackId in
            // open deep link
            PXDeepLinkManager.open(deepLink)
            PXCongratsTracking.trackTapDiscountItemEvent(index, trackId)
        }
        return action
    }

    func didTapDiscount(index: Int, deepLink: String?, trackId: String?) {
        PXDeepLinkManager.open(deepLink)
        PXCongratsTracking.trackTapDiscountItemEvent(index, trackId)
    }

    /// EXPENSE SPLIT VIEW
    func getExpenseSplit() -> PXExpenseSplit? {
        return paymentCongrats.expenseSplit
    }

    // This implementation is the same accross PXBusinessResultViewModel and PXResultViewModel, so it's ok to do it here
    func getExpenseSplitTapAction() -> (() -> Void)? {
        let action: () -> Void = { [weak self] in
            PXDeepLinkManager.open(self?.paymentCongrats.expenseSplit?.action.target)

            MPXTracker.sharedInstance.trackEvent(event: PXResultTrackingEvents.didTapOnDeeplink(
                PXCongratsTracking.getDeeplinkProperties(type: "money_split", deeplink: self?.paymentCongrats.expenseSplit?.action.target ?? ""))
            )
        }
        return action
    }

    func getCrossSellingItems() -> [PXCrossSellingItem]? {
        return paymentCongrats.crossSelling
    }

    /// CROSS SELLING
    // This implementation is the same accross PXBusinessResultViewModel and PXResultViewModel, so it's ok to do it here
    func getCrossSellingTapAction() -> ((String) -> Void)? {
        let action: (String) -> Void = { deepLink in
            // open deep link
            PXDeepLinkManager.open(deepLink)
            MPXTracker.sharedInstance.trackEvent(event: PXResultTrackingEvents.didTapOnCrossSelling)
        }
        return action
    }

    //// VIEW RECEIPT ACTION
    func getViewReceiptAction() -> PXRemoteAction? {
        return paymentCongrats.receiptAction
    }

    //// TOP TEXT BOX
    func getTopTextBox() -> PXText? {
        return nil
    }

    //// CUSTOM ORDER
    func getCustomOrder() -> Bool? {
        return paymentCongrats.hasCustomSorting
    }

    // INSTRUCTIONS
    func hasInstructions() -> Bool {
        return paymentCongrats.instructions != nil
    }

    func getInstructions() -> PXInstruction? {
        return paymentCongrats.instructions
    }

    // PAYMENT METHOD
    func shouldShowPaymentMethod() -> Bool {
        return paymentCongrats.shouldShowPaymentMethod
    }

    func getPaymentViewData() -> PXNewCustomViewData? {
        guard let paymentInfo = paymentCongrats.paymentInfo else { return nil }
        return createPaymentMethodReceiptData(from: paymentInfo)
    }

    // SPLIT PAYMENT METHOD
    func getSplitPaymentViewData() -> PXNewCustomViewData? {
        guard let paymentInfo = paymentCongrats.splitPaymentInfo else { return nil }
        return createPaymentMethodReceiptData(from: paymentInfo)
    }

    // REJECTED BODY
    func shouldShowErrorBody() -> Bool {
        return paymentCongrats.errorBodyView != nil
    }

    func getErrorBodyView() -> UIView? {
        return paymentCongrats.errorBodyView
    }

    var isSecondaryButtonStyle: Bool {
        isPaymentResultRejectedWithRemedy() && paymentCongrats.remedyViewData != nil
    }

    func getRemedyView(animatedButtonDelegate: PXAnimatedButtonDelegate?, termsAndCondDelegate: PXTermsAndConditionViewDelegate?, remedyViewProtocol: PXRemedyViewDelegate?) -> UIView? {
        if isPaymentResultRejectedWithRemedy(), var remedyViewData = paymentCongrats.remedyViewData {
            remedyViewData.animatedButtonDelegate = animatedButtonDelegate
            remedyViewData.remedyViewProtocol = remedyViewProtocol
            return PXRemedyView(data: remedyViewData, termsAndCondDelegate: termsAndCondDelegate)
        }
        return nil
    }

    func getRemedyButtonAction() -> ((String?) -> Void)? {
        return nil
    }

    func isPaymentResultRejectedWithRemedy() -> Bool {
        return paymentCongrats.remedyViewData != nil
    }

    // FOOTER
    func getFooterMainAction() -> PXAction? {
        return paymentCongrats.mainAction
    }

    func getFooterSecondaryAction() -> PXAction? {
        return paymentCongrats.secondaryAction
    }

    // CUSTOM VIEWS
    func getImportantView() -> UIView? {
        return paymentCongrats.importantView
    }

    func getCreditsExpectationView() -> UIView? {
        return paymentCongrats.creditsExpectationView
    }

    func getTopCustomView() -> UIView? {
        return paymentCongrats.topView
    }

    func getBottomCustomView() -> UIView? {
        return paymentCongrats.bottomView
    }

    // CALLBACKS & TRACKING
    func getTrackingProperties() -> [String: Any] {
        if let internalTrackingValues = paymentCongrats.internalTrackingValues {
            return internalTrackingValues
        } else {
            guard let extConf = paymentCongrats.externalTrackingValues else { return [:] }
            let trackingConfiguration = PXTrackingConfiguration(trackListener: extConf.trackListener,
                                                                flowName: extConf.flowName,
                                                                flowDetails: extConf.flowDetails,
                                                                sessionId: extConf.sessionId)
            trackingConfiguration.updateTracker()

            var properties: [String: Any] = [:]
            properties["style"] = "custom"
            properties["payment_method_id"] = extConf.paymentMethodId
            properties["payment_method_type"] = extConf.paymentMethodType
            properties["payment_id"] = extConf.paymentId
            properties["payment_status"] = paymentCongrats.type.getRawValue()
            properties["total_amount"] = extConf.totalAmount
            properties["payment_status_detail"] = extConf.paymentStatusDetail

            if let campaingId = extConf.campaingId {
                properties[PXCongratsTracking.TrackingKeys.campaignId.rawValue] = campaingId
            }

            if let currency = extConf.currencyId {
                properties["currency_id"] = currency
            }

            properties["has_split_payment"] = paymentCongrats.splitPaymentInfo != nil
            properties[PXCongratsTracking.TrackingKeys.hasBottomView.rawValue] = paymentCongrats.bottomView != nil
            properties[PXCongratsTracking.TrackingKeys.hasTopView.rawValue] = paymentCongrats.topView != nil
            properties[PXCongratsTracking.TrackingKeys.hasImportantView.rawValue] = paymentCongrats.importantView != nil
            properties[PXCongratsTracking.TrackingKeys.hasExpenseSplitView.rawValue] = paymentCongrats.expenseSplit != nil
            properties[PXCongratsTracking.TrackingKeys.scoreLevel.rawValue] = paymentCongrats.points?.progress.levelNumber
            properties[PXCongratsTracking.TrackingKeys.discountsCount.rawValue] = paymentCongrats.discounts?.items.count

            return properties
        }
    }

    func getDebinProperties() -> [String: Any]? {
        return paymentCongrats.bankTransferProperties
    }

    func getTrackingPath() -> PXResultTrackingEvents? {
        if let internalTrackingPath = paymentCongrats.internalTrackingPath as? PXResultTrackingEvents {
            return internalTrackingPath
        } else {
            var screenPath: PXResultTrackingEvents?
            let paymentStatus = paymentCongrats.type.getRawValue()
            var properties = getTrackingProperties()

            if let debinProperties = getDebinProperties() {
                properties.merge(debinProperties) { current, _ in current }
            }

            if paymentStatus == PXPaymentStatus.APPROVED.rawValue {
                screenPath = .congratsPaymentApproved(properties)
            } else if paymentStatus == PXPaymentStatus.IN_PROCESS.rawValue || paymentStatus == PXPaymentStatus.PENDING.rawValue {
                screenPath = .congratsPaymentInProcess(properties)
            } else if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
                screenPath = .congratsPaymentRejected(properties)
            }

            return screenPath
        }
    }

    func getFlowBehaviourResult() -> PXResultKey {
        guard let internalResult = paymentCongrats.internalFlowBehaviourResult else {
            switch paymentCongrats.type {
            case .approved: return .SUCCESS
            case .rejected: return .FAILURE
            case .pending, .inProgress: return .PENDING
            }
        }
        return internalResult
    }

    // BUTTONS
    func getPrimaryButton() -> PXButton? {
        return paymentCongrats.primaryButton
    }

    // URLs, and AutoReturn
    func shouldAutoReturn() -> Bool {
        return paymentCongrats.shouldAutoReturn
    }

    func getBackUrl() -> URL? {
        return nil
    }

    func getAutoReturn() -> PXAutoReturn? {
        return paymentCongrats.autoReturn
    }
}

extension PXPaymentCongratsViewModel {
    func getTrackingRemediesProperties(isFromModal: Bool) -> [String: Any] {
            let from = isFromModal == true ? "modal" : "view"
            guard let extConf = paymentCongrats.externalTrackingValues else { return ["from": from] }
            var properties: [String: Any] = [:]
            properties["index"] = 0
            properties["type"] = paymentCongrats.type.getRawValue()
            properties["payment_status"] = paymentCongrats.type.getRawValue()
            properties["payment_status_detail"] = extConf.paymentStatusDetail
            if let trackingData = paymentCongrats.remedyViewData?.remedy.trackingData {
                properties["extra_info"] = trackingData
            }
            properties["from"] = from
            return properties
        }

    func getViewErrorPaymentResult() -> [String: Any] {
        guard let extConf = paymentCongrats.externalTrackingValues else { return [:] }
        var properties: [String: Any] = [:]
        properties["index"] = 0
        properties["type"] = paymentCongrats.type.getRawValue()
        properties["payment_status"] = paymentCongrats.type.getRawValue()
        properties["payment_status_detail"] = extConf.paymentStatusDetail
        if let trackingData = paymentCongrats.remedyViewData?.remedy.trackingData {
            properties["extra_info"] = trackingData
        }
        return properties
    }

    func getDidShowRemedyErrorModal() -> [String: Any] {
        guard let extConf = paymentCongrats.externalTrackingValues else { return [:] }
        var properties: [String: Any] = [:]
        properties["index"] = 0
        properties["type"] = paymentCongrats.type.getRawValue()
        properties["payment_status"] = paymentCongrats.type.getRawValue()
        properties["payment_status_detail"] = extConf.paymentStatusDetail
        if let trackingData = paymentCongrats.remedyViewData?.remedy.trackingData {
            properties["extra_info"] = trackingData
        }
        return properties
    }
}
