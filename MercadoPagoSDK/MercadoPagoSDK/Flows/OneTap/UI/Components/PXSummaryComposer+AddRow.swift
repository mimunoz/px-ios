import Foundation

extension PXSummaryComposer {
    func chargesRow() -> PXOneTapSummaryRowData {
        let amount = getChargesAmount()
        let shouldDisplayHelper = shouldDisplayChargesHelp
        let helperImage = shouldDisplayHelper ? helpIcon(color: UIColor.Andes.blueMP500) : nil
        let amountToShow = Utils.getAmountFormated(amount: amount, forCurrency: currency)
        let defaultChargeText = "Cargos".localized
        let chargeText = getChargesLabel() ?? additionalInfoSummary?.charges ?? defaultChargeText
        let row = PXOneTapSummaryRowData(title: chargeText, value: amountToShow, highlightedColor: UIColor.Andes.gray550, alpha: textTransparency, isTotal: false, image: helperImage, type: .charges)
        return row
    }

    func discountRow() -> PXOneTapSummaryRowData? {
        guard let discount = getDiscount() else {
            printError("Discount is required to add the discount row")
            return nil
        }

        let discountToShow = Utils.getAmountFormated(amount: discount.couponAmount, forCurrency: currency)
        let helperImage = helpIcon(color: discountColor())
        let row = PXOneTapSummaryRowData(title: discount.getDiscountDescription(),
                                          value: "- \(discountToShow)",
            highlightedColor: discountColor(),
            alpha: textTransparency,
            isTotal: false,
            image: helperImage,
            type: .discount,
            discountOverview: getDiscountOverview(),
            briefColor: discountBriefColor())
        return row
    }

    func purchaseRow() -> PXOneTapSummaryRowData {
        let row = PXOneTapSummaryRowData( title: yourPurchaseSummaryTitle(),
                                           value: yourPurchaseToShow(),
                                           highlightedColor: summaryColor(),
                                           alpha: textTransparency,
                                           isTotal: false,
                                           image: nil,
                                           type: .generic)
        return row
    }

    func totalToPayRow() -> PXOneTapSummaryRowData {
        let totalAmountToShow = Utils.getAmountFormated(amount: amountHelper.getAmountToPayWithoutPayerCost(paymentOptionID: selectedCard?.cardId, paymentMethodId: selectedCard?.selectedApplication?.paymentMethodId, paymentTypeId: selectedCard?.selectedApplication?.paymentTypeId), forCurrency: currency)
        let text = "total_row_title_default".localized
        let row = PXOneTapSummaryRowData(title: text,
                                          value: totalAmountToShow,
                                          highlightedColor: summaryColor(),
                                          alpha: textTransparency,
                                          isTotal: true,
                                          image: nil,
                                          type: .generic)
        return row
    }
}
