import Foundation

protocol PaymenteToggle {
    mutating func toggle()
}

enum IsPaymentToggle: PaymenteToggle {
    case noPaying, paying
    mutating func toggle() {
        switch self {
        case .noPaying:
            self = .paying
        case .paying:
            self = .noPaying
        }
    }

    func isPayment() -> Bool {
        switch self {
        case .noPaying:
            return false
        case .paying:
            return true
        }
    }
}
