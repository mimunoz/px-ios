import UIKit

@objc class MPXTracker: NSObject {
    @objc static let sharedInstance = MPXTracker()
    private var trackListener: PXTrackerListener?
    private var flowDetails: [String: Any]?
    private var flowName: String?
    private var customSessionId: String?
    private var sessionService: SessionService = SessionService()
    private var experiments: [PXExperiment]?
}

// MARK: Getters/setters.
extension MPXTracker {
    func setTrack(listener: PXTrackerListener) {
        if isPXAddonTrackListener() {
            return
        }
        trackListener = listener
    }

    func setFlowDetails(flowDetails: [String: Any]?) {
        self.flowDetails = flowDetails
    }

    func setFlowName(name: String?) {
        self.flowName = name
    }

    func setCustomSessionId(_ customSessionId: String?) {
        self.customSessionId = customSessionId
    }

    func startNewSession() {
        sessionService.startNewSession()
    }

    func startNewSession(externalSessionId: String) {
        sessionService.startNewSession(externalSessionId: externalSessionId)
    }

    func getSessionID() -> String {
        return customSessionId ?? sessionService.getSessionId()
    }

    func getRequestId() -> String {
        return sessionService.getRequestId()
    }

    func clean() {
        if !isPXAddonTrackListener() {
            MPXTracker.sharedInstance.trackListener = nil
        }
        MPXTracker.sharedInstance.flowDetails = [:]
        MPXTracker.sharedInstance.experiments = nil
    }

    func getFlowName() -> String? {
        return flowName
    }

    func setExperiments(_ experiments: [PXExperiment]?) {
        MPXTracker.sharedInstance.experiments = experiments
    }

    private func isPXAddonTrackListener() -> Bool {
        if let trackListener = trackListener,
            String(describing: trackListener.self).contains("PXAddon.PXTrack") {
            return true
        }
        return false
    }

    private func appendFlow(to metadata: [String: Any]) -> [String: Any] {
        var metadata = metadata

        // TODO: Validate default value for flow name
        metadata["flow"] = flowName ?? "PX"

        return metadata
    }

    private func appendExternalData(to metadata: [String: Any]) -> [String: Any] {
        var metadata = metadata

        if let flowDetails = flowDetails {
            metadata["flow_detail"] = flowDetails
        }

        metadata[SessionService.SESSION_ID_KEY] = getSessionID()
        metadata["session_time"] = PXTrackingStore.sharedInstance.getSecondsAfterInit()

        if let checkoutType = PXTrackingStore.sharedInstance.getChoType() {
            metadata["checkout_type"] = checkoutType
        }

        metadata["security_enabled"] = PXConfiguratorManager.hasSecurityValidation()

        if let experiments = experiments {
            metadata["experiments"] = PXExperiment.getExperimentsForTracking(experiments)
        }
        return metadata
    }
}

// MARK: Public interfase.
extension MPXTracker {
    func trackScreen(event: TrackingEvents) {
        if let trackListenerInterfase = trackListener {
            var metadata = appendFlow(to: event.properties)
            metadata = appendExternalData(to: metadata)

            trackListenerInterfase.trackScreen(screenName: event.name, extraParams: metadata)
        }
    }

    func trackEvent(event: TrackingEvents) {
        if let trackListenerInterfase = trackListener {
            var metadata = appendFlow(to: event.properties)

            if event.name == TrackingPaths.Events.getErrorPath() {
                var frictionExtraInfo: [String: Any] = [:]
                if let extraInfo = metadata["extra_info"] as? [String: Any] {
                    frictionExtraInfo = extraInfo
                }

                metadata["extra_info"] = appendExternalData(to: frictionExtraInfo)

                if let experiments = experiments {
                    metadata["experiments"] = PXExperiment.getExperimentsForTracking(experiments)
                }
                metadata["security_enabled"] = PXConfiguratorManager.hasSecurityValidation()
                metadata["session_time"] = PXTrackingStore.sharedInstance.getSecondsAfterInit()
            }
            metadata = appendExternalData(to: metadata)

            trackListenerInterfase.trackEvent(screenName: event.name, action: "", result: "", extraParams: metadata)
        }
    }
}
