import Foundation

open class PXPayerPaymentMethodDisplayInfo: NSObject, Codable {
    let result: PXDisplayInfoResult?
}

open class PXDisplayInfoResult: NSObject, Codable {
    let paymentMethod: PXDisplayInfoPaymentMethod?
    let extraInfo: PXDisplayInfoExtraInfo?

    enum CodingKeys: String, CodingKey {
        case paymentMethod = "payment_method"
        case extraInfo = "extra_info"
    }
}

open class PXDisplayInfoPaymentMethod: NSObject, Codable {
    let iconUrl: String?
    let detail: [PXText]?

    enum CodingKeys: String, CodingKey {
        case iconUrl = "icon_url"
        case detail
    }
}

open class PXDisplayInfoExtraInfo: NSObject, Codable {
    let detail: [PXText]?

    enum CodingKeys: String, CodingKey {
        case detail
    }
}
