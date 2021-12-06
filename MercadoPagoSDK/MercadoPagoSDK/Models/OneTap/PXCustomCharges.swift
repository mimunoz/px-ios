import Foundation

public typealias PXCustomCharges = [String: PXCustomCharge?]

public struct PXCustomCharge: Codable {
    let charge: Double
    let label: String?

    enum CodingKeys: String, CodingKey {
        case charge
        case label
    }
}
