import Foundation

enum PostPaymentStatus: Equatable {
    case pending(Notification.Name)
    case continuing

    var isPending: Bool {
        guard case .pending = self else { return false }
        return true
    }

    static func == (lhs: PostPaymentStatus, rhs: PostPaymentStatus) -> Bool {
        switch (lhs, rhs) {
        case (.pending(let lhs), .pending(let rhs)): return lhs == rhs
        case (.continuing, .continuing): return true
        default: return false
        }
    }
}
