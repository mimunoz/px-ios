import UIKit

/// A `Linear` wiping `SortFunction`. This will consider the rows or columns of the views rather than looking at their exact coordinates. Views that have the same vertical or horizontal components, based on the `direction`, will animate in at the same time.
struct LinearSortFunction: DirectionSortFunction {
    var direction: Direction
    var interObjectDelay: TimeInterval
    var reversed: Bool = false

    init(direction: Direction, interObjectDelay: TimeInterval) {
        self.direction = direction
        self.interObjectDelay = interObjectDelay
    }

    func distanceBetween(_ left: CGPoint, and right: CGPoint) -> Double {
        var left = left
        var right = right
        switch direction {
        case .bottomToTop, .topToBottom:
            left.x = 0.0
            right.x = 0.0
        case .leftToRight, .rightToLeft:
            left.y = 0.0
            right.y = 0.0
        }
        return left.spruce.euclideanDistance(to: right)
    }
}
