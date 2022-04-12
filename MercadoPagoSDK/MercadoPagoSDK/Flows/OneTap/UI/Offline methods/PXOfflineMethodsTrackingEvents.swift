enum PXOfflineMethodsTrackingEvents: TrackingEvents {
    case didConfirm([String: Any])

    var name: String {
        switch self {
        case .didConfirm: return "/px_checkout/review/confirm"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .didConfirm(let properties): return properties
        }
    }
}
