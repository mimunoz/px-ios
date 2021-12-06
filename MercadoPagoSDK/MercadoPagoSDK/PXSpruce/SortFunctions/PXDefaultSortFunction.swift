import UIKit

/// The basic `SortFunction`. Use this sort function if you want to animate in all views at the same time and give an `interObjectDelay` of `0.0`. Note that this `SortFunction` will animate the views based on the order they were added to the animation view. This means that the way the views are sorted in the `subviews` array is the way that they will be sorted by this `SortFunction`. 
struct DefaultSortFunction: SortFunction {
    var interObjectDelay: TimeInterval = 0.0

    init() {
    }

    init(interObjectDelay: TimeInterval) {
        self.interObjectDelay = interObjectDelay
    }

    func timeOffsets(view: UIView, recursiveDepth: Int) -> [TimedView] {
        var timedViews: [TimedView] = []
        var currentTimeOffset: TimeInterval = 0.0
        let subviews = view.pxSpruce.subviews(withRecursiveDepth: recursiveDepth)
        for subView in subviews {
            let timedView = TimedView(spruceView: subView, timeOffset: currentTimeOffset)
            timedViews.append(timedView)
            currentTimeOffset += interObjectDelay
        }
        return timedViews
    }
}
