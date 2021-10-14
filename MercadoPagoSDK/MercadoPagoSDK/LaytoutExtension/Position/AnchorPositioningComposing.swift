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
        equalTo(rootSuperview, constant: constant, priority: priority)
    }
    
    @discardableResult
    func lessThanOrEqualToSuperview(
        constant: CGFloat,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint {
        lessThanOrEqualTo(rootSuperview, constant: constant, priority: priority)
    }
    
    @discardableResult
    func greaterThanOrEqualToSuperview(
        constant: CGFloat,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint {
        greaterThanOrEqualTo(rootSuperview, constant: constant, priority: priority)
    }
}

private extension AnchorPositioningComposing {
    var rootSuperview: UIView {
        if let superview = root.superview {
            return superview
        }
        preconditionFailure("Root doesn't have a superview")
    }
}
