import Foundation

open class PXOneTapNewPaymentMethodDto: NSObject, Codable {
    let version: String?
    let label: PXText?
    let descriptionText: PXText?
    let cardFormInitType: String?
    let sheetOptions: [PXOneTapSheetOptionsDto]?
    let deeplink: String?
    let displayInfo: PXOneTapDisplayInfo?
    let genericCardDisplayInfo: PXGenericCardDisplayInfo?
    let paymentTypes: [PXOfflinePaymentType]?

    enum CodingKeys: String, CodingKey {
        case version
        case label
        case descriptionText = "description"
        case cardFormInitType = "card_form_init_type"
        case sheetOptions = "sheet_options"
        case deeplink
        case displayInfo = "display_info"
        case paymentTypes = "payment_types"
        case genericCardDisplayInfo = "generic_card_display_info"
    }
}

public struct PXGenericCardDisplayInfo: Codable {
    let iconUrl: String?
    let border: PXOneTapNewCardBorderDto?
    let backgroundColor: String?
    let shadow: Bool?

    enum CodingKeys: String, CodingKey {
        case iconUrl = "icon_url"
        case border
        case backgroundColor = "background_color"
        case shadow
    }
}

open class PXOneTapNewCardBorderDto: NSObject, Codable {
    var type: String?
    let color: String?
}

enum PXOneTapNewCardBorderType: String, Codable {
    case dotted
    case solid
}
