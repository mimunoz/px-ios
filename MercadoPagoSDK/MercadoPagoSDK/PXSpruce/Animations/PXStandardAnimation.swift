import UIKit

/// A wrapper around the standard `UIViewAnimation` block with options publicly accessible. See, [UIViewAnimation](apple-reference-documentation://hsLqXZ_dD1) for more
/// - Note: `animationOptions` defaults to `.curveEaseOut`. If you do not update this value before calling the animate method than the changes will not be reflected.
struct StandardAnimation: Animation {
    var changeFunction: ChangeFunction?
    var duration: TimeInterval
    var animationOptions: UIView.AnimationOptions = .curveEaseOut

    init(duration: TimeInterval) {
        self.duration = duration
    }

    init(duration: TimeInterval, changes: @escaping ChangeFunction) {
        self.init(duration: duration)
        self.changeFunction = changes
    }

    func animate(delay: TimeInterval, view: UIView, completion: CompletionHandler?) {
        if view.pxShouldAnimated {
            UIView.animate(withDuration: duration, delay: delay, options: animationOptions, animations: {
                self.changeFunction?(view)
            }, completion: completion)
        } else {
            fadeInSubViews(forView: view)
        }
    }

    private func fadeInSubViews(forView: UIView) {
        changeFunction?(forView)
        for subView in forView.subviews {
            subView.alpha = 0
        }
        forView.alpha = 1
        for subView in forView.subviews {
            UIView.animate(withDuration: 0.45, animations: {
                subView.alpha = 1
            })
        }
    }
}
