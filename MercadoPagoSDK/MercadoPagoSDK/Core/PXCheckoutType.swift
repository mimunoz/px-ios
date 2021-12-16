import Foundation

@objc public enum PXCheckoutType: Int {
    case CUSTOM_SCHEDULED
    case DEFAULT_REGULAR
    case CUSTOM_REGULAR

    func getString() -> String {
        switch self {
        case .CUSTOM_SCHEDULED: return "scheduled"
        case .DEFAULT_REGULAR: return "default_regular"
        case .CUSTOM_REGULAR: return "regular"
        }
    }
}
