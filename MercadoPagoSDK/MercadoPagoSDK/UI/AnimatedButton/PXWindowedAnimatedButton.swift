import Foundation

/**
 Just like the PXAnimatedButton, but using the window as it's anchor point.
 Useful for situtations where the explosion should escape the containing view controller.
 */
class PXWindowedAnimatedButton: PXAnimatedButton {
    override func anchorView() -> UIView? {
        return UIApplication.shared.keyWindow
    }
}
