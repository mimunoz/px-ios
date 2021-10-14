import UIKit

protocol AnchorPositioningComposing {
    var root: AnchoringRoot { get }
    var type: AnchorType { get }
    
    @discardableResult
    func equalTo(
        _ root: AnchoringRoot,
        constant: CGFloat,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint
    
    
    @discardableResult
    func lessThanOrEqualTo(
        _ root: AnchoringRoot,
        constant: CGFloat,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint
    
    @discardableResult
    func greaterThanOrEqualTo(
        _ root: AnchoringRoot,
        constant: CGFloat,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint
}

extension AnchorPositioningComposing {
    var trailing: ComposedPositionAnchor { .init(root: root, anchors: [self, root.trailing]) }
    var leading: ComposedPositionAnchor { .init(root: root, anchors: [self, root.leading]) }
    var centerX: ComposedPositionAnchor { .init(root: root, anchors: [self, root.centerX]) }
    var top: ComposedPositionAnchor { .init(root: root, anchors: [self, root.top]) }
    var bottom: ComposedPositionAnchor { .init(root: root, anchors: [self, root.bottom]) }
    var centerY: ComposedPositionAnchor { .init(root: root, anchors: [self, root.centerY]) }
    
    @discardableResult
    func equalToSuperview(
        constant: CGFloat,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint {
        guard let superview = root.superview else {
            preconditionFailure("Root doesn't have a superview")
        }
        return equalTo(superview, constant: constant, priority: priority)
    }
    
    @discardableResult
    func lessThanOrEqualToSuperview(
        constant: CGFloat,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint {
        guard let superview = root.superview else {
            preconditionFailure("Root doesn't have a superview")
        }
        return lessThanOrEqualTo(superview, constant: constant, priority: priority)
    }
    
    @discardableResult
    func greaterThanOrEqualToSuperview(
        constant: CGFloat,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint {
        guard let superview = root.superview else {
            preconditionFailure("Root doesn't have a superview")
        }
        return greaterThanOrEqualTo(superview, constant: constant, priority: priority)
    }
}
