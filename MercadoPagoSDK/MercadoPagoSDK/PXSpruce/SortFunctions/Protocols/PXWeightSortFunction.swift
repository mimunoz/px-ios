import Foundation

/// Represents the weighted values for computation
///
/// - light: a small value, 0.5
/// - medium: a default value, 1.0
/// - heavy: a large value, 2.0
/// - custom: you can specify your own value for weight
enum Weight {
    /// a small value, 0.5
    case light

    /// a default value, 1.0
    case medium

    /// a large value, 2.0
    case heavy

    /// you can specify your own value for weight
    case custom(Double)

    var coefficient: Double {
        get {
            switch self {
            case .light:
                return 0.5
            case .medium:
                return 1.0
            case .heavy:
                return 2.0
            case .custom(let value):
                return max(0.0, value)
            }
        }
    }
}

/// A `SortFunction` that takes into account the vertical and horizontal weight of the position of views. The lighter the weight the the faster those views will start to animate. For example, if you had a light `verticalWeight` and a heavy `horizontalWeight`, the views that are vertically aligned with the starting position will animate before those that are horizontally aligned. This allows you to define the exact rigidness of a `radial` like `SortFunction`.
protocol WeightSortFunction: SortFunction {
    /// the horizontal weight that should be applied to each of the distances between views
    var horizontalWeight: Weight { get set }

    /// the vertical weight that should be applied to each of the distances between views
    var verticalWeight: Weight { get set }
}
