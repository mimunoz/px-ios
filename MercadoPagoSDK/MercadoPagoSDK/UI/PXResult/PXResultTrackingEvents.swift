enum PXResultTrackingEvents: TrackingEvents {
    // MARK: - Events
    case didTapOnAllDiscounts
    case didtapOnDownload
    case didTapOnReceipt
    case didTapOnScore
    case didTapOnDeeplink([String: Any])
    case didTapOnCrossSelling
    case didShowRemedyError([String: Any])

    // MARK: - ScreenEvents
    case checkoutPaymentApproved([String: Any])
    case checkoutPaymentInProcess([String: Any])
    case checkoutPaymentRejected([String: Any])

    case congratsPaymentApproved([String: Any])
    case congratsPaymentInProcess([String: Any])
    case congratsPaymentRejected([String: Any])

    var name: String {
        switch self {
        case .didTapOnAllDiscounts: return "/px_checkout/result/success/tap_see_all_discounts"
        case .didtapOnDownload: return "/px_checkout/result/success/tap_download_app"
        case .didTapOnReceipt: return "/px_checkout/result/success/tap_view_receipt"
        case .didTapOnScore: return "/px_checkout/result/success/tap_score"
        case .didTapOnDeeplink: return "/px_checkout/result/success/deep_link"
        case .didTapOnCrossSelling: return "/px_checkout/result/success/tap_cross_selling"
        case .didShowRemedyError: return "/px_checkout/result/error/primary_action"
        case .checkoutPaymentApproved: return "/px_checkout/result/success"
        case .checkoutPaymentInProcess: return "/px_checkout/result/further_action_needed"
        case .checkoutPaymentRejected: return "/px_checkout/result/error"
        case .congratsPaymentApproved: return "/payment_congrats/result/success"
        case .congratsPaymentInProcess: return "/payment_congrats/result/further_action_needed"
        case .congratsPaymentRejected: return "/payment_congrats/result/error"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .didTapOnAllDiscounts, .didtapOnDownload, .didTapOnReceipt, .didTapOnScore, .didTapOnCrossSelling: return [:]
        case .didTapOnDeeplink(let properties), .didShowRemedyError(let properties), .checkoutPaymentApproved(let properties),
             .checkoutPaymentInProcess(let properties), .checkoutPaymentRejected(let properties),
             .congratsPaymentApproved(let properties), .congratsPaymentInProcess(let properties),
             .congratsPaymentRejected(let properties): return properties
        }
    }

    var needsExternalData: Bool {
        switch self {
        case .didTapOnAllDiscounts, .didtapOnDownload, .didTapOnReceipt, .didTapOnScore, .didTapOnDeeplink,
             .didTapOnCrossSelling, .didShowRemedyError, .checkoutPaymentApproved:
            return true
        case .checkoutPaymentInProcess, .checkoutPaymentRejected, .congratsPaymentApproved, .congratsPaymentInProcess, .congratsPaymentRejected:
            return false
        }
    }
}
