import UIKit

/// A wrapper around the spring `UIViewAnimation` block with options publicly accessible. See, [UIViewAnimation](apple-reference-documentation://hsEaMPVO1d) for more
/// - Note: `animationOptions` defaults to `[]`. If you do not update this value before calling the animate method than the changes will not be reflected.
/// - Note: `damping` defaults to 0.5 and `initialVelocity` defaults to 0.7
struct SpringAnimation: Animation {
    var changeFunction: ChangeFunction?
    var duration: TimeInterval

    /// A mask of options indicating how you want to perform the animations
    var animationOptions: UIView.AnimationOptions = []
    var damping: CGFloat = 0.5
    var initialVelocity: CGFloat = 0.7

    init(duration: TimeInterval) {
        self.duration = duration
    }

    init(duration: TimeInterval, changes: @escaping ChangeFunction) {
        self.init(duration: duration)
        self.changeFunction = changes
    }

    func animate(delay: TimeInterval, view: UIView, completion: CompletionHandler?) {
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: initialVelocity, options: animationOptions, animations: { [changeFunction] in
            changeFunction?(view)
        }, completion: completion)
    }
}
