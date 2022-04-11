import UIKit
import MLBusinessComponents

class PXResultViewModel: NSObject {
    let amountHelper: PXAmountHelper
    var paymentResult: PaymentResult
    var instructionsInfo: PXInstruction?
    var pointsAndDiscounts: PXPointsAndDiscounts?
    var preference: PXPaymentResultConfiguration
    let remedy: PXRemedy?
    let oneTapDto: PXOneTapDto?
    var callback: ((PaymentResult.CongratsState, String?) -> Void)?
    var debinBankName: String?

    var strategyTracking: StrategyTrackings = ImpletationStrategy()

    init(amountHelper: PXAmountHelper, paymentResult: PaymentResult, instructionsInfo: PXInstruction? = nil, pointsAndDiscounts: PXPointsAndDiscounts?, resultConfiguration: PXPaymentResultConfiguration = PXPaymentResultConfiguration(), remedy: PXRemedy? = nil, oneTapDto: PXOneTapDto? = nil, debinBankName: String? = nil) {
        self.paymentResult = paymentResult
        self.instructionsInfo = instructionsInfo
        self.pointsAndDiscounts = pointsAndDiscounts
        self.preference = resultConfiguration
        self.amountHelper = amountHelper
        self.remedy = remedy
        self.oneTapDto = oneTapDto
        self.debinBankName = debinBankName
    }

    func getPaymentData() -> PXPaymentData {
        guard let paymentData = paymentResult.paymentData else {
            fatalError("paymentResult.paymentData cannot be nil")
        }
        return paymentData
    }

    func setCallback(callback: @escaping ((PaymentResult.CongratsState, String?) -> Void)) {
        self.callback = callback
    }

    func getPaymentStatus() -> String {
        return paymentResult.status
    }

    func getPaymentStatusDetail() -> String {
        return paymentResult.statusDetail
    }

    func getPaymentId() -> String? {
        return paymentResult.paymentId
    }

    func isCallForAuth() -> Bool {
        return paymentResult.isCallForAuth()
    }

    func primaryResultColor() -> UIColor {
        return ResourceManager.shared.getResultColorWith(status: paymentResult.status, statusDetail: paymentResult.statusDetail)
    }

    func headerCloseAction() -> () -> Void {
        return { [weak self] in
            guard let self = self else { return }
            MPXTracker.sharedInstance.trackEvent(event: self.getCloseButtonTrack())

            if let callback = self.callback {
                if let url = self.getBackUrl() {
                    PXNewResultUtil.openURL(url: url, success: { _ in
                        callback(PaymentResult.CongratsState.EXIT, nil)
                    })
                } else {
                    callback(PaymentResult.CongratsState.EXIT, nil)
                }
            }
        }
    }

    func creditsExpectationView() -> UIView? {
        guard paymentResult.paymentData?.paymentMethod?.id == PXPaymentTypes.CONSUMER_CREDITS.rawValue else { return nil }
        if let resultInfo = amountHelper.getPaymentData().getPaymentMethod()?.creditsDisplayInfo?.resultInfo,
            let title = resultInfo.title,
            let subtitle = resultInfo.subtitle {
            return PXCreditsExpectationView(title: title, subtitle: subtitle)
        }
        return nil
    }

    func errorBodyView() -> UIView? {
        if let bodyComponent = buildBodyComponent() as? PXBodyComponent,
            bodyComponent.hasBodyError() {
            return bodyComponent.render()
        }
        return nil
    }

    private func getRemedyViewData() -> PXRemedyViewData? {
        if isPaymentResultRejectedWithRemedy(),
           let remedy = remedy {
            return PXRemedyViewData(oneTapDto: oneTapDto,
                                    paymentData: paymentResult.paymentData,
                                    amountHelper: amountHelper,
                                    remedy: remedy,
                                    animatedButtonDelegate: nil,
                                    remedyViewProtocol: nil,
                                    remedyButtonTapped: getRemedyButtonAction())
        }
        return nil
    }

    private func getRemedyButtonAction() -> ((String?) -> Void)? {
        let action = { (text: String?) in
            MPXTracker.sharedInstance.trackEvent(event: PXResultTrackingEvents.didShowRemedyError)

            if let callback = self.callback {
                if self.remedy?.cvv != nil {
                    callback(PaymentResult.CongratsState.RETRY_SECURITY_CODE, text)
                } else if self.remedy?.suggestedPaymentMethod != nil {
                    callback(PaymentResult.CongratsState.RETRY_SILVER_BULLET, text)
                } else {
                    callback(PaymentResult.CongratsState.RETRY, text)
                }
            }
        }
        return action
    }
}

// MARK: PXCongratsTrackingDataProtocol Implementation
extension PXResultViewModel: PXCongratsTrackingDataProtocol {
    func hasBottomView() -> Bool {
        return getBottomCustomView() != nil
    }

    func hasTopView() -> Bool {
        return getTopCustomView() != nil
    }

    func hasImportantView() -> Bool {
        return false
    }

    func hasExpenseSplitView() -> Bool {
        return pointsAndDiscounts?.expenseSplit != nil && MLBusinessAppDataService().isMp() ? true : false
    }

    func getScoreLevel() -> Int? {
        return PXNewResultUtil.getDataForPointsView(points: pointsAndDiscounts?.points)?.getRingNumber()
    }

    func getDiscountsCount() -> Int {
        guard let numberOfDiscounts = PXNewResultUtil.getDataForDiscountsView(discounts: pointsAndDiscounts?.discounts)?.getItems().count else { return 0 }
        return numberOfDiscounts
    }

    func getCampaignsIds() -> String? {
        guard let discounts = PXNewResultUtil.getDataForDiscountsView(discounts: pointsAndDiscounts?.discounts) else { return nil }
        var campaignsIdsArray: [String] = []
        for item in discounts.getItems() {
            if let id = item.trackIdForItem() {
                campaignsIdsArray.append(id)
            }
        }
        return campaignsIdsArray.isEmpty ? "" : campaignsIdsArray.joined(separator: ", ")
    }

    func getCampaignId() -> String? {
        guard let campaignId = amountHelper.campaign?.id else { return nil }
        return "\(campaignId)"
    }
}

// MARK: Tracking
extension PXResultViewModel {
    func getFooterPrimaryActionTrackingPath() -> String {
        let paymentStatus = paymentResult.status
        var screenPath = ""

        if paymentStatus == PXPaymentStatus.APPROVED.rawValue || paymentStatus == PXPaymentStatus.PENDING.rawValue {
            screenPath = ""
        } else if paymentStatus == PXPaymentStatus.IN_PROCESS.rawValue {
            screenPath = ""
        } else if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getErrorChangePaymentMethodPath()
        }
        return screenPath
    }

    func getFooterSecondaryActionTrackingPath() -> String {
        let paymentStatus = paymentResult.status
        var screenPath = ""

        if paymentStatus == PXPaymentStatus.APPROVED.rawValue || paymentStatus == PXPaymentStatus.PENDING.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getSuccessContinuePath()
        } else if paymentStatus == PXPaymentStatus.IN_PROCESS.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getFurtherActionContinuePath()
        } else if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
            screenPath = ""
        }
        return screenPath
    }

    func getHeaderCloseButtonTrackingPath() -> String {
        let paymentStatus = paymentResult.status
        var screenPath = ""

        if paymentStatus == PXPaymentStatus.APPROVED.rawValue || paymentStatus == PXPaymentStatus.PENDING.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getSuccessAbortPath()
        } else if paymentStatus == PXPaymentStatus.IN_PROCESS.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getFurtherActionAbortPath()
        } else if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getErrorAbortPath()
        }
        return screenPath
    }

    private func paymentMethodShouldBeShown() -> Bool {
        let isApproved = paymentResult.isApproved()
        return !hasInstructions() && isApproved
    }

    private func hasInstructions() -> Bool {
        return instructionsInfo != nil
    }

	func getPaymentMethodsImageURLs() -> [String: String]? {
        return pointsAndDiscounts?.paymentMethodsImages
    }

    private func getTopCustomView() -> UIView? {
        if paymentResult.isApproved() {
            return preference.getTopCustomView()
        }
        return nil
    }

    private func getBottomCustomView() -> UIView? {
        if paymentResult.isApproved() {
            return preference.getBottomCustomView()
        }
        return nil
    }

    func getRedirectUrl() -> URL? {
        if let redirectURL = pointsAndDiscounts?.redirectUrl, !redirectURL.isEmpty {
            return getUrl(url: redirectURL, appendLanding: true)
        }
        return getUrl(backUrls: amountHelper.preference.redirectUrls, appendLanding: true)
    }

    private func shouldAutoReturn() -> Bool {
        guard let autoReturn = amountHelper.preference.autoReturn,
            let fieldId = PXNewResultUtil.PXAutoReturnTypes(rawValue: autoReturn),
            getBackUrl() != nil else {
                return false
        }

        let status = PXPaymentStatus(rawValue: getPaymentStatus())
        switch status {
        case .APPROVED:
            return fieldId == .APPROVED
        default:
            return fieldId == .ALL
        }
    }

    func getBackUrl() -> URL? {
        return getUrl(backUrls: amountHelper.preference.backUrls)
    }

    private func getUrl(url: String, appendLanding: Bool = false) -> URL? {
        if appendLanding {
            let landingURL = MLBusinessAppDataService().appendLandingURLToString(url)
            return URL(string: landingURL)
        }
        return URL(string: url)
    }

    private func getUrl(backUrls: PXBackUrls?, appendLanding: Bool = false) -> URL? {
        var urlString: String?
        let status = PXPaymentStatus(rawValue: getPaymentStatus())
        switch status {
        case .APPROVED:
            urlString = backUrls?.success
        case .PENDING:
            urlString = backUrls?.pending
        case .REJECTED:
            urlString = backUrls?.failure
        default:
            return nil
        }
        if let urlString = urlString,
            !urlString.isEmpty {
            if appendLanding {
                let landingURL = MLBusinessAppDataService().appendLandingURLToString(urlString)
                return URL(string: landingURL)
            }
            return URL(string: urlString)
        }
        return nil
    }

    private func isPaymentResultRejectedWithRemedy() -> Bool {
        if paymentResult.isRejectedWithRemedy(),
            let remedy = remedy, remedy.isEmpty == false {
            return true
        }
        return false
    }
}

extension PXResultViewModel: PXViewModelTrackingDataProtocol {
    func getCloseButtonTrack() -> PXResultTrackingEvents {
        return .didTapOnCloseButton(initiative: .checkout, status: paymentResult.status)
    }

    func getTrackingPath() -> PXResultTrackingEvents? {
        let paymentStatus = paymentResult.status
        var screenPath: PXResultTrackingEvents?

        var properties = getTrackingProperties()
        if let debinProperties = getDebinProperties() {
            properties.merge(debinProperties) { current, _ in current }
        }

        if paymentStatus == PXPaymentStatus.APPROVED.rawValue {
            screenPath = .checkoutPaymentApproved(properties)
        } else if paymentStatus == PXPaymentStatus.IN_PROCESS.rawValue || paymentStatus == PXPaymentStatus.PENDING.rawValue {
            screenPath = .checkoutPaymentInProcess(properties)
        } else if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
            screenPath = .checkoutPaymentRejected(properties)
        } else {
            screenPath = .checkoutPaymentUnknown(properties)
        }
        return screenPath
    }

    func getFlowBehaviourResult() -> PXResultKey {
        let isApprovedOfflinePayment = PXPayment.Status.PENDING.elementsEqual(paymentResult.status) && PXPayment.StatusDetails.PENDING_WAITING_PAYMENT.elementsEqual(paymentResult.statusDetail)

        if paymentResult.isApproved() || isApprovedOfflinePayment {
            return .SUCCESS
        } else if paymentResult.isRejected() {
            return .FAILURE
        } else {
            return .PENDING
        }
    }

    func getTrackingProperties() -> [String: Any] {
        var properties: [String: Any] = amountHelper.getPaymentData().getPaymentDataForTracking()
        properties["style"] = "generic"
        if let paymentId = getPaymentId() {
            properties["payment_id"] = Int64(paymentId)
        }
        properties["payment_status"] = paymentResult.status
        properties["payment_status_detail"] = paymentResult.statusDetail

        properties["has_split_payment"] = amountHelper.isSplitPayment
        properties["currency_id"] = SiteManager.shared.getCurrency().id
        properties["discount_coupon_amount"] = amountHelper.getDiscountCouponAmountForTracking()
        properties = PXCongratsTracking.getProperties(dataProtocol: self, properties: properties)

        if let rawAmount = amountHelper.getPaymentData().getRawAmount() {
            properties["total_amount"] = rawAmount.decimalValue
        }

        let paymentStatus = paymentResult.status
        if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
            var remedies: [[String: Any]] = []
            if let remedy = remedy,
                !(remedy.isEmpty) {
                if remedy.suggestedPaymentMethod != nil {
                    remedies.append(["index": 0,
                                     "type": "payment_method_suggestion",
                                     "extra_info": remedy.trackingData ?? ""])
                } else if remedy.cvv != nil {
                    remedies.append(["index": 0,
                                     "type": "cvv_request",
                                     "extra_info": remedy.trackingData ?? ""])
                } else if remedy.highRisk != nil {
                    remedies.append(["index": 0,
                                     "type": "kyc_request",
                                     "extra_info": remedy.trackingData ?? ""])
                }
            }
            properties["remedies"] = remedies
        }

        trackingInfoGeneral(flow: "Result - getTrackingProperties() \(paymentResult)")

        return properties
    }

    func trackingInfoGeneral(flow: String) {
        strategyTracking.getPropertieFlow(flow: flow)
    }

    func getTrackingRemediesProperties(isFromModal: Bool) -> [String: Any] {
        var properties: [String: Any] = amountHelper.getPaymentData().getPaymentDataForTracking()
        properties["style"] = "custom"
        if let paymentId = getPaymentId() {
            properties["payment_id"] = Int64(paymentId)
        }
        properties["payment_status"] = paymentResult.status
        properties["payment_status_detail"] = paymentResult.statusDetail
        properties["has_split_payment"] = amountHelper.isSplitPayment
        properties["currency_id"] = SiteManager.shared.getCurrency().id
        properties["discount_coupon_amount"] = amountHelper.getDiscountCouponAmountForTracking()
        properties["from"] = isFromModal == true ? "modal" : "view"
        properties = PXCongratsTracking.getProperties(dataProtocol: self, properties: properties)

        if let rawAmount = amountHelper.getPaymentData().getRawAmount() {
            properties["total_amount"] = rawAmount.decimalValue
        }
        return properties
    }

    func getViewErrorPaymentResult() -> [String: Any] {
        var properties: [String: Any] = [:]
            properties["style"] = "generic"
            if let paymentId = getPaymentId() {
                properties["payment_id"] = Int64(paymentId)
            }
            properties["payment_status"] = paymentResult.status
            properties["payment_status_detail"] = paymentResult.statusDetail

            properties["has_split_payment"] = amountHelper.isSplitPayment
            properties["currency_id"] = SiteManager.shared.getCurrency().id
            properties["discount_coupon_amount"] = amountHelper.getDiscountCouponAmountForTracking()
            properties = PXCongratsTracking.getProperties(dataProtocol: self, properties: properties)

            if let rawAmount = amountHelper.getPaymentData().getRawAmount() {
                properties["total_amount"] = rawAmount.decimalValue
            }

            let paymentStatus = paymentResult.status
            if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
                var remedies: [[String: Any]] = []
                if let remedy = remedy,
                    !(remedy.isEmpty) {
                    if remedy.suggestedPaymentMethod != nil {
                        remedies.append(["index": 0,
                                         "type": "payment_method_suggestion",
                                         "extra_info": remedy.trackingData ?? ""])
                    } else if remedy.cvv != nil {
                        remedies.append(["index": 0,
                                         "type": "cvv_request",
                                         "extra_info": remedy.trackingData ?? ""])
                    } else if remedy.highRisk != nil {
                        remedies.append(["index": 0,
                                         "type": "kyc_request",
                                         "extra_info": remedy.trackingData ?? ""])
                    }
                }
                properties["remedies"] = remedies
            }

            return properties
    }

    func getDidShowRemedyErrorModal() -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["index"] = 0
        properties["payment_status"] = paymentResult.status
        properties["payment_status_detail"] = paymentResult.statusDetail
        return properties
    }

    func getDebinProperties() -> [String: Any]? {
        guard let paymentTypeId = amountHelper.getPaymentData().paymentMethod?.paymentTypeId, let paymentTypeIdEnum = PXPaymentTypes(rawValue: paymentTypeId), paymentTypeIdEnum == .BANK_TRANSFER else {
            return nil
        }

        var debinProperties: [String: Any] = [:]
        debinProperties["bank_name"] = debinBankName
        debinProperties["external_account_id"] = amountHelper.getPaymentData().transactionInfo?.bankInfo?.accountId

        return debinProperties
    }
}

extension PXResultViewModel {
    func toPaymentCongrats() -> PXPaymentCongrats {
        let paymentcongrats = PXPaymentCongrats()
            .withCongratsType(congratsType(fromResultStatus: self.paymentResult.status))
            .withHeaderColor(primaryResultColor())
            .withHeader(title: titleHeader(forNewResult: true).string, imageURL: nil, closeAction: headerCloseAction())
            .withHeaderImage(iconImageHeader())
            .withHeaderBadgeImage(badgeImage())
            .withReceipt(shouldShowReceipt: hasReceiptComponent(), receiptId: getPaymentId(), action: pointsAndDiscounts?.viewReceiptAction)
            .withLoyalty(pointsAndDiscounts?.points)
            .withDiscounts(pointsAndDiscounts?.discounts)
            .withExpenseSplit(pointsAndDiscounts?.expenseSplit)
            .withAutoReturn(pointsAndDiscounts?.autoReturn)
            .withPrimaryButton(pointsAndDiscounts?.primaryButton)
            .withCrossSelling(pointsAndDiscounts?.crossSelling)
            .withCustomSorting(pointsAndDiscounts?.customOrder)
            .withInstructions(instructionsInfo)
            .withFooterMainAction(getActionButton())
            .withFooterSecondaryAction(getActionLink())
            .withImportantView(nil)
            .withTopView(getTopCustomView())
            .withBottomView(getBottomCustomView())
            .withRemedyViewData(getRemedyViewData())
            .withCreditsExpectationView(creditsExpectationView())
            .shouldShowPaymentMethod(paymentMethodShouldBeShown())
            .withRedirectURLs(getRedirectUrl())
            .shouldAutoReturn(shouldAutoReturn())

        if let paymentInfo = getPaymentMethod(paymentData: paymentResult.paymentData, amountHelper: amountHelper) {
            paymentcongrats.withPaymentMethodInfo(paymentInfo)
        }

        if amountHelper.isSplitPayment,
            let splitPaymentData = amountHelper.splitAccountMoney,
            let splitPaymentInfo = getPaymentMethod(paymentData: splitPaymentData, amountHelper: amountHelper) {
            paymentcongrats.withSplitPaymentInfo(splitPaymentInfo)
        }

        if let infoOperation = pointsAndDiscounts?.infoOperation {
            paymentcongrats.withInfoOperation(infoOperation)
        }

        if let debinProperties = getDebinProperties() {
            paymentcongrats.withBankTransferTrackingProperties(properties: debinProperties)
        }

        paymentcongrats.withStatementDescription(paymentResult.statementDescription)

        paymentcongrats.withFlowBehaviorResult(getFlowBehaviourResult())
                .withTrackingProperties(getTrackingProperties())
                .withTrackingPath(getTrackingPath())
                .withErrorBodyView(errorBodyView())

        return paymentcongrats
    }

    private func getPaymentMethod(paymentData: PXPaymentData?, amountHelper: PXAmountHelper) -> PXCongratsPaymentInfo? {
        guard let paymentData = paymentData,
            let paymentTypeIdString = paymentData.getPaymentMethod()?.paymentTypeId,
            let paymentType = PXPaymentTypes(rawValue: paymentTypeIdString),
            let paymentId = paymentData.getPaymentMethod()?.id
        else { return nil }

        return assemblePaymentMethodInfo(paymentData: paymentData, amountHelper: amountHelper, currency: SiteManager.shared.getCurrency(), paymentType: paymentType, paymentMethodId: paymentId, externalPaymentMethodInfo: paymentData.getPaymentMethod()?.externalPaymentPluginImageData as Data?)
    }

    private func assemblePaymentMethodInfo(paymentData: PXPaymentData, amountHelper: PXAmountHelper, currency: PXCurrency, paymentType: PXPaymentTypes, paymentMethodId: String, externalPaymentMethodInfo: Data?) -> PXCongratsPaymentInfo {
        var paidAmount: String

        if let paymentOptionsAmount = paymentData.amount {
            paidAmount = Utils.getAmountFormated(amount: paymentOptionsAmount, forCurrency: currency)
        } else if let transactionAmountWithDiscount = paymentData.getTransactionAmountWithDiscount() {
            paidAmount = Utils.getAmountFormated(amount: transactionAmountWithDiscount, forCurrency: currency)
        } else {
            paidAmount = Utils.getAmountFormated(amount: amountHelper.amountToPay, forCurrency: currency)
        }

        var noDiscountAmount: String?
        if let paymentDataNoDiscountAmount = paymentData.noDiscountAmount {
            noDiscountAmount = Utils.getAmountFormated(amount: paymentDataNoDiscountAmount, forCurrency: currency)
        }

        let transactionAmount = Utils.getAmountFormated(amount: paymentData.transactionAmount?.doubleValue ?? 0.0, forCurrency: currency)

        var installmentAmount: String?
        if let amount = paymentData.payerCost?.installmentAmount {
            installmentAmount = Utils.getAmountFormated(amount: amount, forCurrency: currency)
        }

        var installmentsTotalAmount: String?
        if let totalForInstallments = paymentData.payerCost?.totalAmount {
            installmentsTotalAmount = Utils.getAmountFormated(amount: totalForInstallments, forCurrency: currency)
        }

        var iconURL: String?
        if let paymentMethod = paymentData.paymentMethod, let paymentMethodsImageURLs = getPaymentMethodsImageURLs(), !paymentMethodsImageURLs.isEmpty {
            iconURL = PXNewResultUtil.getPaymentMethodIconURL(for: paymentMethod.id, using: paymentMethodsImageURLs)
        }

        return PXCongratsPaymentInfo(paidAmount: paidAmount,
                                     rawAmount: noDiscountAmount ?? transactionAmount,
                                     paymentMethodName: paymentData.paymentMethod?.name,
                                     paymentMethodLastFourDigits: paymentData.token?.lastFourDigits,
                                     paymentMethodDescription: paymentData.paymentMethod?.creditsDisplayInfo?.description?.message,
                                     paymentMethodIconURL: iconURL,
                                     paymentMethodType: paymentType,
                                     installmentsRate: paymentData.payerCost?.installmentRate,
                                     installmentsCount: paymentData.payerCost?.installments ?? 0,
                                     installmentsAmount: installmentAmount,
                                     installmentsTotalAmount: installmentsTotalAmount,
                                     discountName: paymentData.discount?.name,
                                     displayInfo: paymentData.paymentMethod?.bankTransferDisplayInfo)
    }

    private func congratsType(fromResultStatus stringStatus: String) -> PXCongratsType {
        switch stringStatus {
        case PXPaymentStatus.APPROVED.rawValue:
            return PXCongratsType.approved
        case PXPaymentStatus.PENDING.rawValue:
            return PXCongratsType.pending
        case PXPaymentStatus.IN_PROCESS.rawValue:
            return PXCongratsType.inProgress
        case PXPaymentStatus.REJECTED.rawValue:
            return PXCongratsType.rejected
        default:
            return PXCongratsType.rejected
        }
    }
}
