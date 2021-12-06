import Foundation

@objcMembers
public class PXRemoteAction: NSObject, Codable {
    let label: String
    let target: String?

    public init(label: String, target: String?) {
        self.label = label
        self.target = target
    }

    enum CodingKeys: String, CodingKey {
        case label
        case target
    }
}
