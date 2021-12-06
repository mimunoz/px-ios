import Foundation

public struct PXDiscountOverview: Codable, Equatable {
    let description: [PXText]
    let amount: PXText
    let brief: [PXText]?
    let url: String?
}
