import Foundation

// MARK: Tracking
extension PXOneTapDto {
    private func getPaymentInfoForTracking() -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["payment_method_type"] = paymentTypeId
        properties["payment_method_id"] = paymentMethodId
        return properties
    }

    private func getBenefitsInfoForTracking(payerPaymentMethods: [PXCustomOptionSearchItem]? = nil) -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["has_interest_free"] = benefits?.interestFree != nil ? true : false
        properties["has_reimbursement"] = benefits?.reimbursement != nil ? true : false
        if paymentMethodId == PXPaymentMethodId.DEBIN.rawValue {
            properties["bank_name"] = payerPaymentMethods?.first(where: {
                $0.paymentMethodId == PXPaymentMethodId.DEBIN.rawValue && $0.id == bankTransfer?.id
            })?.bankInfo?.name
            properties["external_account_id"] = bankTransfer?.id
        }

        return properties
    }

    func getAccountMoneyForTracking() -> [String: Any] {
        var accountMoneyDic = getPaymentInfoForTracking()
        var extraInfo = getBenefitsInfoForTracking()
        extraInfo["balance"] = accountMoney?.availableBalance
        extraInfo["invested"] = accountMoney?.invested
        accountMoneyDic["extra_info"] = extraInfo

        return accountMoneyDic
    }

    func getPaymentMethodForTracking(payerPaymentMethods: [PXCustomOptionSearchItem]? = nil, amountHelper: PXAmountHelper? = nil) -> [String: Any] {
        var paymentMethodDic = getPaymentInfoForTracking()
        paymentMethodDic["extra_info"] = getBenefitsInfoForTracking(payerPaymentMethods: payerPaymentMethods)
        return paymentMethodDic
    }

    func getCardForTracking(amountHelper: PXAmountHelper) -> [String: Any] {
        var savedCardDic = getPaymentInfoForTracking()
        var extraInfo = getBenefitsInfoForTracking()
        extraInfo["card_id"] = oneTapCard?.cardId
        let cardIdsEsc = PXTrackingStore.sharedInstance.getData(forKey: PXTrackingStore.cardIdsESC) as? [String] ?? []
        extraInfo["has_esc"] = cardIdsEsc.contains(oneTapCard?.cardId ?? "")
        if let cardId = oneTapCard?.cardId {
            extraInfo["selected_installment"] = amountHelper.paymentConfigurationService.getSelectedPayerCostsForPaymentMethod(paymentOptionID: cardId, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId)?.getPayerCostForTracking()
            extraInfo["has_split"] = amountHelper.paymentConfigurationService.getSplitConfigurationForPaymentMethod(paymentOptionID: cardId, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) != nil
        }
        if let issuerId = oneTapCard?.cardUI?.issuerId {
            extraInfo["issuer_id"] = Int64(issuerId)
        }

        savedCardDic["extra_info"] = extraInfo
        return savedCardDic
    }
}
