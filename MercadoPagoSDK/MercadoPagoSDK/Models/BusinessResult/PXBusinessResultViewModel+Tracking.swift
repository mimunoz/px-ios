import Foundation
// MARK: Tracking
extension PXBusinessResultViewModel {
    func getFooterPrimaryActionTrackingPath() -> String {
        let paymentStatus = businessResult.paymentStatus
        var screenPath = ""
        if paymentStatus == PXPaymentStatus.APPROVED.rawValue || paymentStatus == PXPaymentStatus.PENDING.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getSuccessPrimaryActionPath()
        } else if paymentStatus == PXPaymentStatus.IN_PROCESS.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getFurtherActionPrimaryActionPath()
        } else if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getErrorPrimaryActionPath()
        }
        return screenPath
    }

    func getFooterSecondaryActionTrackingPath() -> String {
        let paymentStatus = businessResult.paymentStatus
        var screenPath = ""
        if paymentStatus == PXPaymentStatus.APPROVED.rawValue || paymentStatus == PXPaymentStatus.PENDING.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getSuccessSecondaryActionPath()
        } else if paymentStatus == PXPaymentStatus.IN_PROCESS.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getFurtherActionSecondaryActionPath()
        } else if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getErrorSecondaryActionPath()
        }
        return screenPath
    }

    func getHeaderCloseButtonTrackingPath() -> String {
        let paymentStatus = businessResult.paymentStatus
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
}

// MARK: PXCongratsTrackingDataProtocol Implementation
extension PXBusinessResultViewModel: PXCongratsTrackingDataProtocol {
    func hasBottomView() -> Bool {
        return businessResult.getBottomCustomView() != nil
    }

    func hasTopView() -> Bool {
        return businessResult.getTopCustomView() != nil
    }

    func hasImportantView() -> Bool {
        return businessResult.getImportantCustomView() != nil
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

extension PXBusinessResultViewModel: PXViewModelTrackingDataProtocol {
    func getPrimaryButtonTrack() -> PXResultTrackingEvents {
        .didTapButton(initiative: .checkout, status: businessResult.paymentStatus, action: .primaryButton)
    }

    func getSecondaryButtonTrack() -> PXResultTrackingEvents {
        .didTapButton(initiative: .checkout, status: businessResult.paymentStatus, action: .secondaryButton)
    }

    func getDebinProperties() -> [String: Any]? {
        guard let paymentTypeId = amountHelper.getPaymentData().paymentMethod?.paymentTypeId,
                let paymentTypeIdEnum = PXPaymentTypes(rawValue: paymentTypeId),
                paymentTypeIdEnum == .BANK_TRANSFER else {
            return nil
        }

        var debinProperties: [String: Any] = [:]
        debinProperties["bank_name"] = debinBankName
        debinProperties["external_account_id"] = amountHelper.getPaymentData().transactionInfo?.bankInfo?.accountId

        return debinProperties
    }

    func getCloseButtonTrack() -> PXResultTrackingEvents {
        return .didTapOnCloseButton(initiative: .checkout, status: businessResult.paymentStatus)
    }

    func getTrackingPath() -> PXResultTrackingEvents? {
        let paymentStatus = businessResult.paymentStatus
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
        switch businessResult.getBusinessStatus() {
        case .APPROVED:
            return .SUCCESS
        case .REJECTED:
            return .FAILURE
        case .PENDING:
            return .PENDING
        case .IN_PROGRESS:
            return .PENDING
        }
    }

    func getTrackingProperties() -> [String: Any] {
       var properties: [String: Any] = amountHelper.getPaymentData().getPaymentDataForTracking()
       properties["style"] = "custom"
       if let paymentId = getPaymentId() {
           properties["payment_id"] = Int64(paymentId)
       }
       properties["payment_status"] = businessResult.paymentStatus
       properties["payment_status_detail"] = businessResult.paymentStatusDetail
       properties["has_split_payment"] = amountHelper.isSplitPayment
       properties["currency_id"] = SiteManager.shared.getCurrency().id
       properties["discount_coupon_amount"] = amountHelper.getDiscountCouponAmountForTracking()
       properties = PXCongratsTracking.getProperties(dataProtocol: self, properties: properties)

       if let rawAmount = amountHelper.getPaymentData().getRawAmount() {
           properties["total_amount"] = rawAmount.decimalValue
       }

       return properties
    }

    func getTrackingRemediesProperties(isFromModal: Bool) -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["index"] = 0
        properties["type"] = businessResult.getPaymentMethodTypeId()
        properties["payment_status"] = businessResult.paymentStatus
        properties["payment_status_detail"] = businessResult.getStatusDetail()
        properties["from"] = isFromModal == true ? "modal" : "view"
        return properties
    }

    func getViewErrorPaymentResult() -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["index"] = 0
        properties["type"] = businessResult.getPaymentMethodTypeId()
        properties["payment_status"] = businessResult.paymentStatus
        properties["payment_status_detail"] = businessResult.getStatusDetail()
        return properties
    }

    func getDidShowRemedyErrorModal() -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["index"] = 0
        properties["type"] = businessResult.getPaymentMethodTypeId()
        properties["payment_status"] = businessResult.paymentStatus
        properties["payment_status_detail"] = businessResult.getStatusDetail()
        return properties
    }
}
