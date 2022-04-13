import UIKit

/**
 This object is for custom actions. It takes a label and a closure. Closures in Swift are similar to blocks in Objective-C. We need this object in certains scenarios, like in `PXBusinessResult` custom button actions.
 */
@objcMembers
open class PXAction: NSObject {
    var label: String
    var action : (() -> Void)
    // MARK: Initialization
    /**
     Mandatory init.
     - parameter label: The label for your custom action.
     - parameter action: Clousure custom block.
     */
    public init(label: String, action:  @escaping (() -> Void)) {
        self.label = label
        self.action = action
    }
}

extension PXAction {
    func addTrackingEvent(_ trackingEvent: PXResultTrackingEvents) -> PXAction {
        PXAction(label: self.label) { [action] in
            MPXTracker.sharedInstance.trackEvent(event: trackingEvent)
            action()
        }
    }
}
