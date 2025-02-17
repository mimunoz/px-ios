import Foundation

@objcMembers
public class PXPoints: NSObject, Codable {
    let progress: PXPointsProgress
    let title: String
    let action: PXRemoteAction

    public init(progress: PXPointsProgress, title: String, action: PXRemoteAction) {
        self.progress = progress
        self.title = title
        self.action = action
    }

    enum CodingKeys: String, CodingKey {
        case progress
        case title
        case action
    }
}
