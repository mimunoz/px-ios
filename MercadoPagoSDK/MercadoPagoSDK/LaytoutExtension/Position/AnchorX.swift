import UIKit

final class AnchorX: AnchorPositioning, AnchorPositioningComposing {
    let anchor: NSLayoutXAxisAnchor
    let type: AnchorType
    let root: AnchoringRoot

    init(anchor: NSLayoutXAxisAnchor, root: AnchoringRoot, type: AnchorType) {
        self.anchor = anchor
        self.type = type
        self.root = root
        self.root.translatesAutoresizingMaskIntoConstraints = false
    }

    @discardableResult
    func equalTo(
        _ otherConstraint: AnchorX,
        constant: CGFloat = 0.0,
        priority: UILayoutPriority = .required)
    -> NSLayoutConstraint {
        let constraint = anchor.constraint(equalTo: otherConstraint.anchor, constant: constant)
        return prepare(constraint, with: priority)
    }

    @discardableResult
    func lessThanOrEqualTo(
        _ otherConstraint: AnchorX,
        constant: CGFloat = 0.0,
        priority: UILayoutPriority = .required)
    -> NSLayoutConstraint {
        let constraint = anchor.constraint(lessThanOrEqualTo: otherConstraint.anchor, constant: constant)
        return prepare(constraint, with: priority)
    }

    @discardableResult
    func greaterThanOrEqualTo(
        _ otherConstraint: AnchorX,
        constant: CGFloat = 0.0,
        priority: UILayoutPriority = .required)
    -> NSLayoutConstraint {
        let constraint = anchor.constraint(greaterThanOrEqualTo: otherConstraint.anchor, constant: constant)
        return prepare(constraint, with: priority)
    }

    private func prepare(_ constraint: NSLayoutConstraint, with priority: UILayoutPriority) -> NSLayoutConstraint {
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
}
