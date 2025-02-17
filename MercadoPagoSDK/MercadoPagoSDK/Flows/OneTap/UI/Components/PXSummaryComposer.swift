import UIKit

struct PXSummaryComposer {
    // returns the composed summary items
    var summaryItems: [PXOneTapSummaryRowData] {
        return generateSummaryItems()
    }

    // MARK: constants
    let isDefaultStatusBarStyle = ThemeManager.shared.statusBarStyle() == .default
    let currency = SiteManager.shared.getCurrency()
    let textTransparency: CGFloat = 1

    // MARK: initialization properties
    let amountHelper: PXAmountHelper
    let additionalInfoSummary: PXAdditionalInfoSummary?
    let selectedCard: PXCardSliderViewModel?
    let shouldDisplayChargesHelp: Bool

    init(amountHelper: PXAmountHelper,
         additionalInfoSummary: PXAdditionalInfoSummary?,
         selectedCard: PXCardSliderViewModel?,
         shouldDisplayChargesHelp: Bool = false) {
        self.amountHelper = amountHelper
        self.additionalInfoSummary = additionalInfoSummary
        self.selectedCard = selectedCard
        self.shouldDisplayChargesHelp = shouldDisplayChargesHelp
    }

    private func generateSummaryItems() -> [PXOneTapSummaryRowData] {
        if selectedCard == nil {
            return [purchaseRow(haveDiscount: true)]
        }

        var internalSummary = [PXOneTapSummaryRowData]()

        if shouldDisplayCharges() || shouldDisplayDiscount() {
            internalSummary.append(purchaseRow(haveDiscount: false))
        }

        if shouldDisplayDiscount(), let discRow = discountRow() {
            internalSummary.append(discRow)
        }

        if shouldDisplayCharges() {
            internalSummary.append(chargesRow())
        }

        internalSummary.append(totalToPayRow())
        return internalSummary
    }
}
