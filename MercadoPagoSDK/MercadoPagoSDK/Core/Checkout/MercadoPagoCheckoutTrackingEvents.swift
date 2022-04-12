enum MercadoPagoCheckoutTrackingEvents: TrackingEvents {
    case didInitFlow([String: Any])

    var name: String {
        switch self {
        case .didInitFlow: return "/px_checkout/init"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .didInitFlow(let properties): return properties
        }
    }
}
