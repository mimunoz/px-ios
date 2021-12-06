import UIKit

/// A position on the screen. Use this to define specific locations on the screen where the animation should start
enum Position {
    /// the top left point of the view
    case topLeft

    /// the top center point of the view
    case topMiddle

    /// the top right point of the view
    case topRight

    /// the left point of the view, centered vertically
    case left

    /// the absolute center of the view (both horizontally and vertically)
    case middle

    /// the right point of the view, centered vertically
    case right

    /// the bottom left point of the view
    case bottomLeft

    /// the bottom center point of the view
    case bottomMiddle

    /// the bottom right point of the view
    case bottomRight
}

/// A `DistanceSortFunction` that uses a position attribute to define an animation's starting point.
protocol PositionSortFunction: DistanceSortFunction {
    /// the starting position of the animation
    var position: Position { get set }
}

extension PositionSortFunction {
    func distancePoint(view: UIView, subviews: [View]) -> CGPoint {
        guard subviews.count > 0 else {
            return .zero
        }
        let distancePoint: CGPoint
        let bounds = view.bounds

        switch position {
        case .topLeft:
            distancePoint = CGPoint.zero
        case .topMiddle:
            distancePoint = CGPoint(x: (bounds.size.width / 2.0), y: 0.0)
        case .topRight:
            distancePoint = CGPoint(x: bounds.size.width, y: 0.0)
        case .left:
            distancePoint = CGPoint(x: 0.0, y: (bounds.size.height / 2.0))
        case .middle:
            distancePoint = CGPoint(x: (bounds.size.width / 2.0), y: (bounds.size.height / 2.0))
        case .right:
            distancePoint = CGPoint(x: bounds.size.width, y: (bounds.size.height / 2.0))
        case .bottomLeft:
            distancePoint = CGPoint(x: 0.0, y: bounds.size.height)
        case .bottomMiddle:
            distancePoint = CGPoint(x: (bounds.size.width / 2.0), y: bounds.size.height)
        case .bottomRight:
            distancePoint = CGPoint(x: bounds.size.width, y: bounds.size.height)
        }

        return translate(distancePoint: distancePoint, intoSubviews: subviews)
    }
}
