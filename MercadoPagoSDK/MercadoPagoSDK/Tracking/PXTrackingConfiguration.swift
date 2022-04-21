import UIKit

@objcMembers
open class PXTrackingConfiguration: NSObject {
    let trackListener: PXTrackerListener?
    let flowName: String?
    let flowDetails: [String: Any]?
    let sessionId: String?

    public init(
        trackListener: PXTrackerListener? = nil,
        flowName: String? = nil,
        flowDetails: [String: Any]? = nil,
        sessionId: String?
    ) {
        self.trackListener = trackListener
        self.flowName = flowName
        self.flowDetails = flowDetails
        self.sessionId = sessionId
    }

    func updateTracker() {
        if let trackListener = trackListener {
            MPXTracker.sharedInstance.setTrack(listener: trackListener)
        }
        MPXTracker.sharedInstance.setFlowName(name: flowName)
        MPXTracker.sharedInstance.setFlowDetails(flowDetails: flowDetails)
        if let sessionId = sessionId {
            MPXTracker.sharedInstance.setCustomSessionId(sessionId)
        }
    }
}
