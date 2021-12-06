import Foundation

struct TrackingPaths {
    static let pxTrack = "/px_checkout"
    static let payments = "/payments"
    static let selectMethod = "/select_method"
    static let addPaymentMethod = "/add_payment_method"
    /// When not making use of PX's checkout, and instead goes directly into congrats
    static let paymentCongrats = "/payment_congrats"
}

struct Tracking {
    struct Style {
        static let customComponent = "custom_component"
        static let screen = "screen"
        static let noScreen = "non_screen"
        static let snackbar = "snackbar"
    }

    struct Error {
        struct Atrributable {
            static let user = "user"
            static let mercadopago = "mercadopago"
            static let merchant = "merchant"
        }

        struct Id {
            static let genericError = "px_generic_error"
            static let invalidDocument = "invalid_document_number"
            static let invalidCVV = "invalid_cvv"
            static let invalidName = "invalid_name"
            static let invalidLastName = "invalid_lastname"
            static let invalidBin = "invalid_bin"
            static let invalidNumber = "invalid_cc_number"
            static let invalidExpirationDate = "invalid_expiration_date"
            static let invalidESC = "invalid_esc"
            static let invalidFingerprint = "invalid_fingerprint"
        }
    }
}
