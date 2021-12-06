import UIKit

final class ComposedDimensionAnchor {
    let root: AnchoringRoot
    private let anchors: [AnchorDimensionComposing]

    init(root: AnchoringRoot, anchors: [AnchorDimensionComposing]) {
        self.root = root
        self.anchors = anchors
    }

    var superview: UIView? { root.superview }
    var translatesAutoresizingMaskIntoConstraints: Bool {
        get { root.translatesAutoresizingMaskIntoConstraints }
        set { root.translatesAutoresizingMaskIntoConstraints = newValue }
    }

    func equalTo(_ target: AnchoringRoot, multiplier: CGFloat = 0.0, constant: CGFloat = 0.0, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { $0.equalTo(target, multiplier: multiplier, constant: constant, priority: priority) }
    }

    func equalToSuperview(multiplier: CGFloat = 0.0, constant: CGFloat = 0.0, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { anchor in
            anchor.equalToSuperview(multiplier: multiplier, constant: constant, priority: priority)
        }
    }

    func greaterThanOrEqualTo(_ target: AnchoringRoot, multiplier: CGFloat = 0.0, constant: CGFloat = 0.0, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { $0.greaterThanOrEqualTo(target, multiplier: multiplier, constant: constant, priority: priority) }
    }

    func greaterThanOrEqualToSuperview(multiplier: CGFloat = 0.0, constant: CGFloat = 0.0, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { anchor in
            anchor.greaterThanOrEqualToSuperview(multiplier: multiplier, constant: constant, priority: priority)
        }
    }

    func lessThanOrEqualTo(_ target: AnchoringRoot, multiplier: CGFloat = 0.0, constant: CGFloat = 0.0, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { $0.lessThanOrEqualTo(target, multiplier: multiplier, constant: constant, priority: priority) }
    }

    func lessThanOrEqualToSuperview(multiplier: CGFloat = 0.0, constant: CGFloat = 0.0, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { anchor in
            anchor.lessThanOrEqualToSuperview(multiplier: multiplier, constant: constant, priority: priority)
        }
    }

    func equalTo(constant: CGFloat, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { anchor in
            anchor.equalTo(constant: constant, priority: priority)
        }
    }

    func lessThanOrEqualTo(constant: CGFloat, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { anchor in
            anchor.lessThanOrEqualTo(constant: constant, priority: priority)
        }
    }

    func greaterThanOrEqualTo(constant: CGFloat, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { anchor in
            anchor.greaterThanOrEqualTo(constant: constant, priority: priority)
        }
    }

    var width: ComposedDimensionAnchor { .init(root: root, anchors: anchors + [root.width]) }
    var height: ComposedDimensionAnchor { .init(root: root, anchors: anchors + [root.height]) }
}
