import Foundation

public struct PXStatus: Codable {
    let mainMessage: PXText?
    let secondaryMessage: PXText?
    let enabled: Bool
    let detail: String?
    let label: PXText?

    enum CodingKeys: String, CodingKey {
        case mainMessage = "main_message"
        case secondaryMessage = "secondary_message"
        case enabled
        case detail
        case label
    }

    func isUsable() -> Bool {
        return enabled && !isSuspended()
    }

    func isDisabled() -> Bool {
        return !enabled
    }

    func isSuspended() -> Bool {
        return detail == "suspended"
    }
}
