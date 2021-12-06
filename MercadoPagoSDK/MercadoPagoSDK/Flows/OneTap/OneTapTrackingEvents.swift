enum OneTapTrackingEvents: TrackingEvents {
    case didTapOnOfflineMethods
    case didGetTargetBehaviour([String: Any])
    case didOpenDialog([String: Any])
    case didConfirmPayment([String: Any])
    case didSwipe
    case didDismissDialog([String: Any])

    var name: String {
        switch self {
        case .didTapOnOfflineMethods: return "/px_checkout/review/one_tap/offline_methods/start_kyc_flow"
        case .didGetTargetBehaviour: return "/px_checkout/review/one_tap/target_behaviour"
        case .didOpenDialog: return "/px_checkout/dialog/open"
        case .didConfirmPayment: return "/px_checkout/review/confirm"
        case .didSwipe: return "/px_checkout/review/one_tap/swipe"
        case .didDismissDialog: return "/px_checkout/dialog/dismiss"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .didGetTargetBehaviour(let properties), .didOpenDialog(let properties), .didConfirmPayment(let properties), .didDismissDialog(let properties): return properties
        case .didTapOnOfflineMethods, .didSwipe: return [:]
        }
    }

    var needsExternalData: Bool {
        switch self {
        case .didTapOnOfflineMethods, .didGetTargetBehaviour, .didConfirmPayment, .didSwipe:
            return true
        case .didOpenDialog, .didDismissDialog:
            return false
        }
    }
}
