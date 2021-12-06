import UIKit
import MLBusinessComponents

class PXDiscountsTouchpointsData: NSObject, MLBusinessTouchpointsData {
    let touchpoint: PXDiscountsTouchpoint

    init(touchpoint: PXDiscountsTouchpoint) {
        self.touchpoint = touchpoint
    }

    func getTouchpointId() -> String {
        return touchpoint.id
    }

    func getTouchpointType() -> String {
        return touchpoint.type
    }

    func getTouchpointContent() -> [String: Any] {
        return touchpoint.content.rawValue
    }

    func getTouchpointTracking() -> [String: Any] {
        guard let tracking = touchpoint.tracking else { return [:] }
        return tracking.rawValue
    }

    func getAdditionalEdgeInsets() -> [String: Any] {
        guard let additionalEdgeInsets = touchpoint.additionalEdgeInsets else { return [:] }
        return additionalEdgeInsets.rawValue
    }
}
