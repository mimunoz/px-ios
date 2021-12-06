enum PXRemediesTrackEvents: TrackingEvents {
    case didResultRemedyError([String: Any])
    case viewErrorPaymentResult([String: Any])
    case changePaymentMethod(isFromModal: Bool)
    case didShowRemedyErrorModal
    case didCloseRemedyModalAbort

    var name: String {
        switch self {
        case .viewErrorPaymentResult: return "/px_checkout/result/error"
        case .didResultRemedyError: return "px_checkout/result/error/remedy"
        case .changePaymentMethod: return "/px_checkout/result/error/change_payment_method"
        case .didShowRemedyErrorModal: return "/px_checkout/result/error/remedy/modal"
        case .didCloseRemedyModalAbort: return "/px_checkout/result/error/remedy/modal/abort"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .didResultRemedyError(let properties), .viewErrorPaymentResult(let properties): return properties
        case .changePaymentMethod(let isFromModal): return ["from": isFromModal ? "modal" : "view"]
        case .didCloseRemedyModalAbort, .didShowRemedyErrorModal: return [:]
        }
    }

    var needsExternalData: Bool {
        switch self {
        case .didResultRemedyError, .viewErrorPaymentResult:
            return true
        case .changePaymentMethod, .didShowRemedyErrorModal, .didCloseRemedyModalAbort:
            return false
        }
    }
}
