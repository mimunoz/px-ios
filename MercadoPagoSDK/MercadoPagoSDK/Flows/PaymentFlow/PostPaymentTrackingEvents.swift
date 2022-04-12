import Foundation

enum PostPaymentTrackingEvents: TrackingEvents {
    case willNavigateToPostPayment([String: Any])

    var name: String {
        switch self {
        case .willNavigateToPostPayment: return "/px_checkout/post_payment_flow"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .willNavigateToPostPayment(let properties): return properties
        }
    }
}
