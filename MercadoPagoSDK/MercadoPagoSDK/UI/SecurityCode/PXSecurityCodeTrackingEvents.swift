enum PXSecurityCodeTrackingEvents: TrackingEvents {
    case didConfirmCode([String: Any])

    var name: String {
        switch self {
        case .didConfirmCode: return "/px_checkout/review/confirm"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .didConfirmCode(let properties): return properties
        }
    }

    var needsExternalData: Bool {
        switch self {
        case .didConfirmCode: return true
        }
    }
}
