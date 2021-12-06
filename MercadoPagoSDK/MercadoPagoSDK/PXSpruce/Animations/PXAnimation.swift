import UIKit

typealias ChangeFunction = (_ view: UIView) -> Void
typealias CompletionHandler = (_ finished: Bool) -> Void
typealias PrepareHandler = (_ view: UIView) -> Void

/// An animation type that handles how the views will change. Most of these are simply wrappers around the standard `UIViewAnimation` methods. This gives `Spruce` the flexibility to work with any style of animating.
protocol Animation {
    /// Animate the given view using the `changeFunction`.
    ///
    /// - Parameters:
    ///   - delay: the time interval that this animation should wait to start from the moment this method is called
    ///   - view: the view to animate
    ///   - completion: a closure that is called upon the animation completing. A `Bool` is passed into the closure letting you know if the animation has completed.
    func animate(delay: TimeInterval, view: UIView, completion: CompletionHandler?)

    /// Given a view, this closure will define the manipulations that will happen to that view
    var changeFunction: ChangeFunction? { get set }
}
