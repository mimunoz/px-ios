import UIKit

protocol AnchorDimensionComposing {
    var root: AnchoringRoot { get }
    var type: AnchorType { get }

    @discardableResult
    func equalTo(
        _ root: AnchoringRoot,
        multiplier: CGFloat,
        constant: CGFloat,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint

    @discardableResult
    func lessThanOrEqualTo(
        _ root: AnchoringRoot,
        multiplier: CGFloat,
        constant: CGFloat,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint

    @discardableResult
    func greaterThanOrEqualTo(
        _ root: AnchoringRoot,
        multiplier: CGFloat,
        constant: CGFloat,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint

    @discardableResult
    func equalTo(
        constant: CGFloat,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint

    @discardableResult
    func lessThanOrEqualTo(
        constant: CGFloat,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint

    @discardableResult
    func greaterThanOrEqualTo(
        constant: CGFloat,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint
}

extension AnchorDimensionComposing {
    var width: ComposedDimensionAnchor { .init(root: root, anchors: [self, root.width]) }
    var height: ComposedDimensionAnchor { .init(root: root, anchors: [self, root.height]) }

    func equalToSuperview(
        multiplier: CGFloat = 1.0,
        constant: CGFloat = 0.0,
        priority: UILayoutPriority = .required
    ) -> NSLayoutConstraint {
        equalTo(
            rootSuperview,
            multiplier: multiplier,
            constant: constant,
            priority: priority
        )
    }

    func lessThanOrEqualToSuperview(
        multiplier: CGFloat = 1.0,
        constant: CGFloat = 0.0,
        priority: UILayoutPriority = .required
    ) -> NSLayoutConstraint {
        lessThanOrEqualTo(
            rootSuperview,
            multiplier: multiplier,
            constant: constant,
            priority: priority
        )
    }

    func greaterThanOrEqualToSuperview(multiplier: CGFloat = 1.0, constant: CGFloat = 0.0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        greaterThanOrEqualTo(
            rootSuperview,
            multiplier: multiplier,
            constant: constant,
            priority: priority
        )
    }
}

private extension AnchorDimensionComposing {
    var rootSuperview: UIView {
        if let superview = root.superview {
            return superview
        }
        preconditionFailure("Root doesn't have a superview")
    }
}
