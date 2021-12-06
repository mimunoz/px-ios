import Foundation

public struct PXDiscountDescription: Codable {
    let title: PXText
    let subtitle: PXText?
    let badge: PXDiscountInfo?
    let summary: PXText
    let description: PXText
    let legalTerms: PXDiscountInfo

    enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case badge
        case summary
        case description
        case legalTerms = "legal_terms"
    }
}
