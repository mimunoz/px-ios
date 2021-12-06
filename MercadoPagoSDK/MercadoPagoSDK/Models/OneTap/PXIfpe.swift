import Foundation

public struct PXIfpe: Codable {
    let isCompliant: Bool
    let hasBackoffice: Bool

    enum CodingKeys: String, CodingKey {
        case isCompliant = "is_compliant"
        case hasBackoffice = "has_backoffice"
    }
}
