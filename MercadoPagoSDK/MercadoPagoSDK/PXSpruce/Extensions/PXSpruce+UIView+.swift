import UIKit

/// Spruce adds `UIView` extensions so that you can easily access a Spruce animation anywere. To make things
/// simple all Spruce functions are under the computed variable `spruce` or use our spruce tree emoji!
extension UIView: PXPropertyStoring {
    /// Access to all of the Spruce library animations. Use this to call functions such as `.animate` or `.prepare`
    var pxSpruce: PXSpruce {
        return PXSpruce(view: self)
    }

    private struct PXCustomProperties {
        static var animationEnabled: Bool = true
        static var onetapRowAnimatedEnabled: Bool = false
    }

    typealias CustomT = Bool

    var pxShouldAnimated: Bool {
        get {
            return getAssociatedObject(&PXCustomProperties.animationEnabled, defaultValue: true)
        }
        set {
            return objc_setAssociatedObject(self, &PXCustomProperties.animationEnabled, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    var pxShouldAnimatedOneTapRow: Bool {
        get {
            return getAssociatedObject(&PXCustomProperties.onetapRowAnimatedEnabled, defaultValue: false)
        }
        set {
            return objc_setAssociatedObject(self, &PXCustomProperties.onetapRowAnimatedEnabled, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
