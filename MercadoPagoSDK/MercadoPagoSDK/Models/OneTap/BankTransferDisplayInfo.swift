import Foundation

public struct BankTransferDisplayInfo: Codable {
    let color: String?
    let gradientColor: [String]?
    let paymentMethodImageURL: String?
    let title: PXText?
    let subtitle: PXText?
    let description: PXText?
    let sliderTitle: String?

    enum CodingKeys: String, CodingKey {
        case color
        case gradientColor = "gradient_color"
        case paymentMethodImageURL = "payment_method_image_url"
        case title
        case subtitle
        case description
        case sliderTitle = "slider_title"
    }
}
