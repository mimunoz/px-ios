enum PXResultTrackingEvents: TrackingEvents {
    enum Status: String {
        case success = "success"
        case error = "error"
        case furtherActionNeeded = "further_action_needed"
        case unknown = "unknown"
    }

    enum Initiative: String {
        case paymentCongrats = "payment_congrats"
        case checkout = "px_checkout"
    }

    // MARK: - Events
    case didTapOnAllDiscounts
    case didtapOnDownload
    case didTapOnReceipt
    case didTapOnScore
    case didTapOnDeeplink([String: Any])
    case didTapOnCrossSelling
    case didShowRemedyError
    case didTapOnCloseButton(initiative: Initiative, status: String)

    // MARK: - ScreenEvents
    case checkoutPaymentApproved([String: Any])
    case checkoutPaymentInProcess([String: Any])
    case checkoutPaymentRejected([String: Any])
    case checkoutPaymentUnknown([String: Any])

    case congratsPaymentApproved([String: Any])
    case congratsPaymentInProcess([String: Any])
    case congratsPaymentRejected([String: Any])
    case congratsPaymentUnknown([String: Any])

    var name: String {
        switch self {
        case .didTapOnAllDiscounts: return "/px_checkout/result/success/tap_see_all_discounts"
        case .didtapOnDownload: return "/px_checkout/result/success/tap_download_app"
        case .didTapOnReceipt: return "/px_checkout/result/success/tap_view_receipt"
        case .didTapOnScore: return "/px_checkout/result/success/tap_score"
        case .didTapOnDeeplink: return "/px_checkout/result/success/deep_link"
        case .didTapOnCrossSelling: return "/px_checkout/result/success/tap_cross_selling"
        case .didShowRemedyError: return "/px_checkout/result/error/primary_action"
        case .didTapOnCloseButton(let initiative, let status): return didTapOnCloseButton(initiative: initiative, paymentStatus: status)
        case .checkoutPaymentApproved: return "/px_checkout/result/success"
        case .checkoutPaymentInProcess: return "/px_checkout/result/further_action_needed"
        case .checkoutPaymentRejected: return "/px_checkout/result/error"
        case .checkoutPaymentUnknown: return "/px_checkout/result/unknown"
        case .congratsPaymentApproved: return "/payment_congrats/result/success"
        case .congratsPaymentInProcess: return "/payment_congrats/result/further_action_needed"
        case .congratsPaymentRejected: return "/payment_congrats/result/error"
        case .congratsPaymentUnknown: return "/payment_congrats/result/unknown"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .didTapOnAllDiscounts,
                .didtapOnDownload,
                .didTapOnReceipt,
                .didTapOnScore,
                .didTapOnCrossSelling,
                .didShowRemedyError,
                .didTapOnCloseButton:
            return [:]
        case .didTapOnDeeplink(let properties),
                .checkoutPaymentApproved(let properties),
                .checkoutPaymentInProcess(let properties),
                .checkoutPaymentRejected(let properties),
                .congratsPaymentApproved(let properties),
                .congratsPaymentInProcess(let properties),
                .congratsPaymentRejected(let properties),
                .checkoutPaymentUnknown(let properties),
                .congratsPaymentUnknown(let properties):
            return properties
        }
    }

    var needsExternalData: Bool {
        switch self {
        case .didTapOnAllDiscounts, .didtapOnDownload, .didTapOnReceipt, .didTapOnScore, .didTapOnDeeplink,
                .didTapOnCrossSelling, .didShowRemedyError, .checkoutPaymentApproved, .didTapOnCloseButton:
            return true
        case .checkoutPaymentInProcess, .checkoutPaymentRejected, .congratsPaymentApproved, .congratsPaymentInProcess, .congratsPaymentRejected, .checkoutPaymentUnknown, .congratsPaymentUnknown:
            return false
        }
    }

    private func didTapOnCloseButton(initiative: Initiative, paymentStatus: String) -> String {
        let status: PXResultTrackingEvents.Status

        if paymentStatus == PXPaymentStatus.APPROVED.rawValue {
            status = .success
        } else if paymentStatus == PXPaymentStatus.IN_PROCESS.rawValue || paymentStatus == PXPaymentStatus.PENDING.rawValue {
            status = .furtherActionNeeded
        } else if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
            status = .error
        } else {
            status = .unknown
        }

        return "/\(initiative.rawValue)/result/\(status.rawValue)/abort"
    }
}
