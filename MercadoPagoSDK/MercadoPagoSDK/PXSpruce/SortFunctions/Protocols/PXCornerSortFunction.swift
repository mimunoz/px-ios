import UIKit

/// A representation of the corners of the view
///
/// - topLeft: top left corner of the view
/// - topRight: top right corner of the view
/// - bottomLeft: bottom left corner of the view
/// - bottomRight: bottom right corner of the view
enum Corner {
    /// top left corner of the view
    case topLeft

    /// top right corner of the view
    case topRight

    /// bottom left corner of the view
    case bottomLeft

    /// bottom right corner of the view
    case bottomRight
}

/// A `DistanceSortFunction` that uses a corner attribute to define an animation's starting point.
protocol CornerSortFunction: DistanceSortFunction {
    /// The starting corner for the animation. Views will animate vertically and horizontally from this corner.
    var corner: Corner { get set }
}

extension CornerSortFunction {
    func distancePoint(view: UIView, subviews: [View] = []) -> CGPoint {
        let distancePoint: CGPoint
        let bounds = view.bounds
        switch corner {
        case .topLeft:
            distancePoint = CGPoint.zero
        case .topRight:
            distancePoint = CGPoint(x: bounds.size.width, y: 0.0)
        case .bottomLeft:
            distancePoint = CGPoint(x: 0.0, y: bounds.size.height)
        case .bottomRight:
            distancePoint = CGPoint(x: bounds.size.width, y: bounds.size.height)
        }
        return translate(distancePoint: distancePoint, intoSubviews: subviews)
    }
}
