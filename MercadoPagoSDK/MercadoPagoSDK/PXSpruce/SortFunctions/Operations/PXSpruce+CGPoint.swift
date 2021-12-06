import UIKit

/// Internal struct to access CGPoint extensions. Use this to call methods such as `.euclideanDistance`
struct SprucePoint {
    /// Internal storage of a `CGPoint` to not conflict with namespaces
    let point: CGPoint

    init(point: CGPoint) {
        self.point = point
    }
}

extension CGPoint {
    /// Access point extensions from Spruce. Call methods such as `.euclideanDistance`.
    var spruce: SprucePoint {
        return SprucePoint(point: self)
    }
}
