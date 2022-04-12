enum MercadoPagoUITrackingEvents: TrackingEvents {
    // MARK: - Events
    case didAbort(String, [String: Any])
    case didGoBack(String)

    // MARK: - Screen Events
    case appliedDiscount([String: Any])
    case termsAndConditions([String: Any])
    case secureCode([String: Any])
    case offlineMethodds([String: Any])
    case reviewOneTap([String: Any])
    case disabledPaymentMethods
    case installments([String: Any])

    var name: String {
        switch self {
        case .didAbort(let screen, _): return "\(screen)/abort"
        case .didGoBack(let screen): return "\(screen)/back"
        case .appliedDiscount: return "/px_checkout/payments/applied_discount"
        case .termsAndConditions: return "/px_checkout/payments/terms_and_conditions"
        case .secureCode: return "/px_checkout/security_code"
        case .offlineMethodds: return "/px_checkout/review/one_tap/offline_methods"
        case .reviewOneTap: return "/px_checkout/review/one_tap"
        case .disabledPaymentMethods: return "/px_checkout/review/one_tap/disabled_payment_method_detail"
        case .installments: return "/px_checkout/review/one_tap/installments"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .didAbort(_, let properties), .appliedDiscount(let properties), .termsAndConditions(let properties),
             .secureCode(let properties), .offlineMethodds(let properties), .reviewOneTap(let properties),
             .installments(let properties): return properties
        case .didGoBack, .disabledPaymentMethods: return [:]
        }
    }
}
