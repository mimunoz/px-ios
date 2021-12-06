import UIKit

open class PXOneTapOfflineCard: NSObject, Codable {
    open var displayInfo: PXCardDisplayInfoDto?

    public enum CodingKeys: String, CodingKey {
        case displayInfo = "display_info"
    }
}
