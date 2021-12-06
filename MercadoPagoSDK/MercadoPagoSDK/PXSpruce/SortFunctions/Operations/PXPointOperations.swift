import UIKit

extension SprucePoint {
    /// Calculate the euclidean distance between two points
    ///
    /// ```
    /// distance = sqrt((x1 - x2)^2 + (y1 - y2)^2)
    /// ```
    /// - Parameter point: the end point of the line for calculating the distance
    /// - Returns: a double value of the euclidean distance between the two points
    func euclideanDistance(to point: CGPoint) -> Double {
        let pointX = Double(pow(self.point.x - point.x, 2.0))
        let pointY = Double(pow(self.point.y - point.y, 2.0))
        return sqrt(pointX + pointY)
    }

    /// Calculate the horizontal euclidean distance between two points. Esentially the same thing as euclideanDistance except it ignores the `y` components of the two points.
    ///
    /// - Parameter point: the end point of the line for calculating the distance
    /// - Returns: a double value of the distance horizontal euclidean between the two points
    func horizontalDistance(to point: CGPoint) -> Double {
        let pointX = Double(self.point.x - point.x)
        return abs(pointX)
    }

    /// Calculate the vertical euclidean distance between two points. Esentially the same thing as euclideanDistance except it ignores the `x` components of the two points.
    ///
    /// - Parameter point: the end point of the line for calculating the distance
    /// - Returns: a double value of the distance vertical euclidean between the two points
    func verticalDistance(to point: CGPoint) -> Double {
        let pointY = Double(self.point.y - point.y)
        return abs(pointY)
    }
}
