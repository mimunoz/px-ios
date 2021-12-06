import UIKit

final class AnchorDimension: AnchorDimensionComposing {
    let anchor: NSLayoutDimension
    let type: AnchorType
    let root: AnchoringRoot

    init(
        anchor: NSLayoutDimension,
        root: AnchoringRoot,
        type: AnchorType
    ) {
        self.anchor = anchor
        self.type = type
        self.root = root
        self.root.translatesAutoresizingMaskIntoConstraints = false
    }

    @discardableResult
    func equalTo(
        _ otherConstraint: AnchorDimension,
        multiplier: CGFloat = 1.0,
        constant: CGFloat = 0.0,
        priority: UILayoutPriority = .required
    ) -> NSLayoutConstraint {
        let constraint = anchor.constraint(
            equalTo: otherConstraint.anchor,
            multiplier: multiplier,
            constant: constant
        )
        return prepare(constraint, with: priority)
    }

    @discardableResult
    func lessThanOrEqualTo(
        _ otherConstraint: AnchorDimension,
        multiplier: CGFloat = 1.0,
        constant: CGFloat = 0.0,
        priority: UILayoutPriority = .required
    ) -> NSLayoutConstraint {
        let constraint = anchor.constraint(
            lessThanOrEqualTo: otherConstraint.anchor,
            multiplier: multiplier,
            constant: constant
        )
        return prepare(constraint, with: priority)
    }

    @discardableResult
    func greaterThanOrEqualTo(
        _ otherConstraint: AnchorDimension,
         multiplier: CGFloat = 1.0,
         constant: CGFloat = 0.0,
         priority: UILayoutPriority = .required
    ) -> NSLayoutConstraint {
        let constraint = anchor.constraint(
            greaterThanOrEqualTo: otherConstraint.anchor,
            multiplier: multiplier,
            constant: constant
        )
        return prepare(constraint, with: priority)
    }

    @discardableResult
    func equalTo(
        constant: CGFloat,
        priority: UILayoutPriority = .required
    ) -> NSLayoutConstraint {
        let constraint = anchor.constraint(equalToConstant: constant)
        return prepare(constraint, with: priority)
    }

    @discardableResult
    func lessThanOrEqualTo(
        constant: CGFloat,
        priority: UILayoutPriority = .required
    ) -> NSLayoutConstraint {
        let constraint = anchor.constraint(lessThanOrEqualToConstant: constant)
        return prepare(constraint, with: priority)
    }

    @discardableResult
    func greaterThanOrEqualTo(
        constant: CGFloat,
        priority: UILayoutPriority = .required
    ) -> NSLayoutConstraint {
        let constraint = anchor.constraint(greaterThanOrEqualToConstant: constant)
        return prepare(constraint, with: priority)
    }

    @discardableResult
    func equalTo(
        _ root: AnchoringRoot,
        multiplier: CGFloat = 1.0,
        constant: CGFloat = 0.0,
        priority: UILayoutPriority = .required
    ) -> NSLayoutConstraint {
        equalTo(
            anchorFor(root: root),
            multiplier: multiplier,
            constant: constant,
            priority: priority
        )
    }

    @discardableResult
    func lessThanOrEqualTo(
        _ root: AnchoringRoot,
        multiplier: CGFloat = 1.0,
        constant: CGFloat = 0.0,
        priority: UILayoutPriority = .required
    ) -> NSLayoutConstraint {
        lessThanOrEqualTo(
            anchorFor(root: root),
            multiplier: multiplier,
            constant: constant,
            priority: priority
        )
    }

    @discardableResult
    func greaterThanOrEqualTo(
        _ root: AnchoringRoot,
        multiplier: CGFloat = 1.0,
        constant: CGFloat = 0.0,
        priority: UILayoutPriority = .required
    ) -> NSLayoutConstraint {
        greaterThanOrEqualTo(
            anchorFor(root: root),
            multiplier: multiplier,
            constant: constant,
            priority: priority
        )
    }
}

private extension AnchorDimension {
    func anchorFor(root: AnchoringRoot) -> AnchorDimension {
        switch type {
        case .width:
            return root.width
        case .height:
            return root.height
        default:
            preconditionFailure("Could not resolve \(type) anchor for this root \(root)")
        }
    }

    func prepare(
        _ constraint: NSLayoutConstraint,
        with priority: UILayoutPriority
    ) -> NSLayoutConstraint {
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
}
