import Foundation

struct PXRemedyDisplayInfo: Codable {
    let header: PXRemedyDisplayInfoHeader?
}

struct PXRemedyDisplayInfoHeader: Codable {
    let title: String?
    let iconUrl: String?
    let badgeUrl: String?
}
