import UIKit

/// Access to all of the Spruce library animations. Use this to call functions such as `.animate` or `.prepare`

struct PXSpruce {
    struct PXDefaultAnimation {
        static let slideUpAnimation: [StockAnimation] = [.slide(.up, .moderately), .fadeIn]
        static let rightToLeftAnimation: [StockAnimation] = [.slide(.left, .slightly), .fadeIn]
        static let appearSortFunction: SortFunction = LinearSortFunction(direction: .topToBottom, interObjectDelay: 0.2)
    }

    /// Internal housing of a `UIView` so that we do not conflict with namespaces
    let view: UIView
    init(view: UIView) {
        self.view = view
    }
}

/// Used to keep track of the `UIView` object and a changing reference point. Since Spruce allows for
/// recursive subview lookup, we need to handle changing the coordinate space. Once the coordinate space
/// has been accounted for we can then alter the reference point.

protocol View {
    /// The view that should be animating
    var view: UIView? { get }
    /// The adjusted for reference point.
    var referencePoint: CGPoint { get set }
}

struct PXSpruceUIView: View {
    weak var view: UIView?
    var referencePoint: CGPoint
    init(view: UIView, referencePoint: CGPoint) {
        self.view = view
        self.referencePoint = referencePoint
    }
}
