import UIKit

// MARK: Build Helpers
extension PXResultViewModel {
    func iconImageHeader() -> UIImage? {
        if paymentResult.isAccepted() {
            if self.paymentResult.isApproved() {
                return preference.getHeaderApprovedIcon() // * **
            } else if self.paymentResult.isWaitingForPayment() {
                return preference.getHeaderPendingIcon()
            } else if self.paymentResult.isPixOrOfflinePayment() {
                return ResourceManager.shared.getImage("default_item_icon")
            } else {
                return preference.getHeaderImageFor(paymentResult.paymentData?.paymentMethod)
            }
        } else {
            return preference.getHeaderRejectedIcon(paymentResult.paymentData?.paymentMethod)
        }
    }

    func badgeImage() -> UIImage? {
        if !preference.showBadgeImage {
            return nil
        }
        return ResourceManager.shared.getBadgeImageWith(status: paymentResult.status, statusDetail: paymentResult.statusDetail)
    }

    func titleHeader(forNewResult: Bool = false) -> NSAttributedString {
        let fontSize = forNewResult ? PXNewResultHeader.TITLE_FONT_SIZE : PXHeaderRenderer.TITLE_FONT_SIZE

        if self.instructionsInfo != nil {
            return titleForInstructions()
        }
        if paymentResult.isAccepted() {
            if self.paymentResult.isApproved() {
                return getHeaderAttributedString(string: preference.getApprovedTitle(), size: fontSize)
            } else {
                return getHeaderAttributedString(string: "Estamos procesando el pago".localized, size: fontSize)
            }
        }
        if preference.rejectedTitleSetted {
            return getHeaderAttributedString(string: preference.getRejectedTitle(), size: fontSize)
        }
        return titleForStatusDetail(statusDetail: self.paymentResult.statusDetail, paymentMethod: self.paymentResult.paymentData?.paymentMethod)
    }

    func titleForStatusDetail(statusDetail: String, paymentMethod: PXPaymentMethod?) -> NSAttributedString {
        // Set title for remedy
        if let title = remedy?.title {
            return title.toAttributedString()
        }

        guard let paymentMethod = paymentMethod else {
            return "".toAttributedString()
        }
        // Set title for paymentMethod
        var statusDetail = statusDetail
        let badFilledKey = "cc_rejected_bad_filled"
        if statusDetail.contains(badFilledKey) {
            statusDetail = badFilledKey
        }

        let title = PXResourceProvider.getErrorTitleKey(statusDetail: statusDetail).localized
        return getTitleForRejected(paymentMethod, title)
    }

    func titleForInstructions() -> NSAttributedString {
        guard let instructionsInfo = self.instructionsInfo else { return "".toAttributedString() }
        return getHeaderAttributedString(string: instructionsInfo.title, size: 26)
    }

    func getTitleForRejected(_ paymentMethod: PXPaymentMethod, _ title: String) -> NSAttributedString {
        guard let paymentMethodName = paymentMethod.name else {
            return getDefaultRejectedTitle()
        }

        return getHeaderAttributedString(string: (title.localized as NSString).replacingOccurrences(of: "{0}", with: "\(paymentMethodName)"))
    }

    func getDefaultRejectedTitle() -> NSAttributedString {
        return getHeaderAttributedString(string: PXHeaderResutlConstants.REJECTED_HEADER_TITLE.localized)
    }

    func getHeaderAttributedString(string: String, size: CGFloat = PXHeaderRenderer.TITLE_FONT_SIZE) -> NSAttributedString {
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.font: Utils.getFont(size: size)])
    }
}
