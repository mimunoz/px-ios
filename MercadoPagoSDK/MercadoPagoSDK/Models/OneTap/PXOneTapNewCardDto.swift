import Foundation

open class PXOneTapNewCardDto: NSObject, Codable {
    let version: String?
    let label: PXText
    let descriptionText: PXText?
    let cardFormInitType: String?
    let sheetOptions: [PXOneTapSheetOptionsDto]?
    let deeplink: String?
    let iconUrl: String?
    let border: PXOneTapNewCardBorderDto?
    let backgroundColor: String?

    enum CodingKeys: String, CodingKey {
        case version
        case label
        case descriptionText = "description"
        case cardFormInitType = "card_form_init_type"
        case sheetOptions = "sheet_options"
        case deeplink
        case iconUrl = "icon_url"
        case border
        case backgroundColor = "background_color"
    }
}

open class PXOneTapNewCardBorderDto: NSObject, Codable {
    let type: String?
    let color: String?
}
