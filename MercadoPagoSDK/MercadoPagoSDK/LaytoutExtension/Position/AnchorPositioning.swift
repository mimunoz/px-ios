import UIKit

protocol AnchorPositioning {
    var type: AnchorType { get }
    var root: AnchoringRoot { get }
    
    @discardableResult
    func equalTo(
        _ otherConstraint: Self,
        constant: CGFloat,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint
    
    @discardableResult
    func lessThanOrEqualTo(
        _ otherConstraint: Self,
        constant: CGFloat,
        priority: UILayoutPriority)
    -> NSLayoutConstraint
    
    @discardableResult
    func greaterThanOrEqualTo(
        _ otherConstraint: Self,
        constant: CGFloat,
        priority: UILayoutPriority)
    -> NSLayoutConstraint
}

extension AnchorPositioning {
    @discardableResult
    func equalToSuperview(constant: CGFloat = 0.0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        equalTo(
            rootSuperview,
            constant: constant,
            priority: priority
        )
    }
    
    @discardableResult
    func lessThanOrEqualToSuperview(constant: CGFloat = 0.0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        lessThanOrEqualTo(
            rootSuperview,
            constant: constant,
            priority: priority
        )
    }
    
    @discardableResult
    func greaterThanOrEqualToSuperview(constant: CGFloat = 0.0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        greaterThanOrEqualTo(
            rootSuperview,
            constant: constant,
            priority: priority
        )
    }
    
    @discardableResult
    func equalTo(_ root: AnchoringRoot, constant: CGFloat = 0.0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        equalTo(
            anchorFor(root: root),
            constant: constant,
            priority: priority
        )
    }
    
    @discardableResult
    func lessThanOrEqualTo(_ root: AnchoringRoot, constant: CGFloat = 0.0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        lessThanOrEqualTo(
            anchorFor(root: root),
            constant: constant,
            priority: priority
        )
    }
    
    @discardableResult
    func greaterThanOrEqualTo(_ root: AnchoringRoot, constant: CGFloat = 0.0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        greaterThanOrEqualTo(
            anchorFor(root: root),
            constant: constant,
            priority: priority
        )
    }
}

private extension AnchorPositioning {
    func anchorFor(root: AnchoringRoot) -> Self {
        let anchor: Self?
        
        switch type {
        case .leading:
            anchor = root.leading as? Self
        case .trailing:
            anchor = root.trailing as? Self
        case .centerX:
            anchor = root.centerX as? Self
        case .top:
            anchor = root.top as? Self
        case .bottom:
            anchor = root.bottom as? Self
        case .centerY:
            anchor = root.centerY as? Self
        default:
            anchor = nil
        }
        
        if let anchor = anchor {
            return anchor
        }
        
        preconditionFailure("Could not resolve \(type) anchor for this root \(root)")
    }
    
    var rootSuperview: UIView {
        if let superview = root.superview {
            return superview
        }
        
        preconditionFailure("Root doesn't have a superview")
    }
}
