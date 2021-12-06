enum PXDiscountTrackingEvents: TrackingEvents {
    case discount(String, String, [String: Any])

    var name: String {
        switch self {
        case .discount(let touchPoint, let action, _): return "/discount_center/payers/touchpoint/\(touchPoint)/\(action)"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .discount(_, _, let properties): return properties
        }
    }

    var needsExternalData: Bool {
        return true
    }
}
