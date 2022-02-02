import Foundation

public struct BankTransferDto: Codable {
    let id: String?
    let displayInfo: BankTransferDisplayInfo?

    enum CodingKeys: String, CodingKey {
        case id
        case displayInfo = "display_info"
    }
}
