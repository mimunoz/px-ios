import UIKit

// MARK: Build Helpers
extension PXResultViewModel {
    typealias Action = (() -> Void)?

    func getActionButton() -> PXAction? {
        return getAction(label: getButtonLabel(), action: getButtonAction())
    }

    func getActionLink() -> PXAction? {
        if getButtonLabel() == getLinkLabel() {
            // Prevents showing same label on both primary and secondary buttons
            return nil
        }

        return getAction(label: getLinkLabel(), action: getLinkAction())
    }

    private func getAction(label: String?, action: Action) -> PXAction? {
        guard let label = label, let action = action else {
            return nil
        }
        return PXAction(label: label, action: action)
    }

    private func getButtonLabel() -> String? {
        if paymentResult.isAccepted() {
            return nil
        } else if paymentResult.isError() {
            if paymentResult.isHighRisk(),
                let label = remedy?.highRisk?.actionLoud?.label {
                return label
            } else {
                return PXFooterResultConstants.GENERIC_ERROR_BUTTON_TEXT.localized
            }
        } else if paymentResult.isWarning() {
            return getWarningButtonLabel()
        }
        return PXFooterResultConstants.DEFAULT_BUTTON_TEXT
    }

    private func getWarningButtonLabel() -> String? {
        if paymentResult.isRejectedWithRemedy(), let remedy = remedy, remedy.shouldShowAnimatedButton {
            // Some remedy types have its own animated button
            return nil
        }
        if paymentResult.isCallForAuth() {
            return PXFooterResultConstants.C4AUTH_BUTTON_TEXT.localized
        } else if paymentResult.isBadFilled() {
            return PXFooterResultConstants.BAD_FILLED_BUTTON_TEXT.localized
        } else if self.paymentResult.isDuplicatedPayment() {
            return PXFooterResultConstants.DUPLICATED_PAYMENT_BUTTON_TEXT.localized
        } else if self.paymentResult.isCardDisabled() {
            return PXFooterResultConstants.CARD_DISABLE_BUTTON_TEXT.localized
        } else if self.paymentResult.isFraudPayment() {
            return PXFooterResultConstants.FRAUD_BUTTON_TEXT.localized
        } else {
            return PXFooterResultConstants.GENERIC_ERROR_BUTTON_TEXT.localized
        }
    }

    private func selectOther() {
        guard let callback = callback else { return }
        MPXTracker.sharedInstance.trackEvent(event: PXRemediesTrackEvents.changePaymentMethod(isFromModal: false))
        callback(PaymentResult.CongratsState.SELECT_OTHER, nil)
    }

    private func getLinkLabel() -> String? {
        if paymentResult.hasSecondaryButton() {
            return PXFooterResultConstants.GENERIC_ERROR_BUTTON_TEXT.localized
        } else if paymentResult.isAccepted() {
            return PXFooterResultConstants.APPROVED_LINK_TEXT.localized
        }

        if let remedy = remedy {
            if remedy.shouldShowAnimatedButton || (paymentResult.isHighRisk() && remedy.highRisk != nil) {
                return PXFooterResultConstants.GENERIC_ERROR_BUTTON_TEXT.localized
            }
        } else {
            // If there is no remedy, show generic secondary button
            if paymentResult.isRejected() {
                return PXFooterResultConstants.GENERIC_SECONDARY_BUTTON_TEXT.localized
            }
        }

        return nil
    }

    private func getButtonAction() -> Action {
        return { [weak self] in
            guard let self = self else { return }
            guard let callback = self.callback else { return }
            if self.paymentResult.isAccepted() {
                callback(PaymentResult.CongratsState.EXIT, nil)
            } else if self.paymentResult.isError() {
                if self.paymentResult.isHighRisk(), let deepLink = self.remedy?.highRisk?.deepLink {
                    callback(PaymentResult.CongratsState.DEEPLINK, deepLink)
                } else {
                    self.selectOther()
                }
            } else if self.paymentResult.isBadFilled() {
                self.selectOther()
            } else if self.paymentResult.isWarning() {
                switch self.paymentResult.statusDetail {
                case PXPayment.StatusDetails.REJECTED_CALL_FOR_AUTHORIZE:
                    callback(PaymentResult.CongratsState.CALL_FOR_AUTH, nil)
                case PXPayment.StatusDetails.REJECTED_CARD_DISABLED:
                    callback(PaymentResult.CongratsState.RETRY, nil)
                default:
                    self.selectOther()
                }
            }
        }
    }

    private func getLinkAction() -> Action {
        return { [weak self] in
            guard let self = self else { return }

            if self.pointsAndDiscounts?.primaryButton != nil {
                if let url = self.getPrimaryButtonBackUrl() {
                    PXNewResultUtil.openURL(url: url, success: { _ in
                        self.callback?(PaymentResult.CongratsState.EXIT, nil)
                    })
                }
            } else {
                if let url = self.getBackUrl() {
                    PXNewResultUtil.openURL(url: url, success: { [weak self] _ in
                        self?.pressLink()
                    })
                } else {
                    self.pressLink()
                }
            }
        }
    }

    private func getPrimaryButtonBackUrl() -> URL? {
        if let action = pointsAndDiscounts?.primaryButton?.action, action == "continue",
            let backURL = pointsAndDiscounts?.backUrl, let url = URL(string: backURL) {
            return url
        } else if let target = pointsAndDiscounts?.primaryButton?.target, let url = URL(string: target) {
            return url
        }
        return nil
    }

    private func pressLink() {
        guard let callback = callback else { return }
        if paymentResult.isAccepted() {
            callback(PaymentResult.CongratsState.EXIT, nil)
        } else {
            switch self.paymentResult.statusDetail {
            case PXPayment.StatusDetails.REJECTED_FRAUD:
                callback(PaymentResult.CongratsState.EXIT, nil)
            case PXPayment.StatusDetails.REJECTED_DUPLICATED_PAYMENT:
                callback(PaymentResult.CongratsState.EXIT, nil)
            default:
                if remedy != nil {
                    selectOther()
                } else {
                    callback(PaymentResult.CongratsState.EXIT, nil)
                }
            }
        }
    }
}
