import Foundation

@objcMembers
public class PXDownloadAction: NSObject, Codable {
    let title: String
    let action: PXRemoteAction

    public init(title: String, action: PXRemoteAction) {
        self.title = title
        self.action = action
    }
}
