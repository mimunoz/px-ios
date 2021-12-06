import Foundation

@objcMembers
public class PXExpenseSplit: NSObject, Codable {
    let title: PXText
    let action: PXRemoteAction
    let imageUrl: String

    public init(title: PXText, action: PXRemoteAction, imageUrl: String) {
        self.title = title
        self.action = action
        self.imageUrl = imageUrl
        super.init()
    }

    enum CodingKeys: String, CodingKey {
        case title
        case action
        case imageUrl = "image_url"
    }
}
