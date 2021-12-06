import UIKit

/// A representation of a linear direction.
///
/// - topToBottom: the animation will run with top views animating first and then bottom views animating last
/// - bottomToTop: the animation will run with bottom views animating first and then top views animating last
/// - leftToRight: the animation will run with left views animating first and right views animating last
/// - rightToLeft: the animation will run with right views animating first and left views animating last
enum Direction {
    /// the animation will run with top views animating first and then bottom views animating last
    case topToBottom

    /// the animation will run with bottom views animating first and then top views animating last
    case bottomToTop

    /// the animation will run with left views animating first and right views animating last
    case leftToRight

    /// the animation will run with right views animating first and left views animating last
    case rightToLeft
}

/// A `DistanceSortFunction` that defines it's `distancePoint` based on a `Direction`. Any distance based sort functions that use a direction variable in order to determine the setup of the animation should implement this protocol.
protocol DirectionSortFunction: DistanceSortFunction {
    /// the direction that the animation should follow
    var direction: Direction { get set }
}

extension DirectionSortFunction {
    func distancePoint(view: UIView, subviews: [View] = []) -> CGPoint {
        let bounds = view.bounds
        switch direction {
        case .topToBottom:
            return CGPoint(x: (bounds.size.width / 2.0), y: 0.0)
        case .bottomToTop:
            return CGPoint(x: (bounds.size.width / 2.0), y: bounds.size.height)
        case .leftToRight:
            return CGPoint(x: 0.0, y: (bounds.size.height / 2.0))
        case .rightToLeft:
            return CGPoint(x: bounds.size.width, y: (bounds.size.height / 2.0))
        }
    }
}
