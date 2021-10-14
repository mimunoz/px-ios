import UIKit

final class ComposedPositionAnchor {
    let root: AnchoringRoot
    private let anchors: [AnchorPositioningComposing]
    
    init(root: AnchoringRoot, anchors: [AnchorPositioningComposing]) {
        self.root = root
        self.anchors = anchors
    }
    
    func equalTo(_ target: AnchoringRoot, offset: CGFloat = 0.0, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { $0.equalTo(target, constant: offset, priority: priority) }
    }
    
    func equalTo(_ target: AnchoringRoot, inset: CGFloat, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { anchor in
            anchor.equalTo(target, constant: constant(for: inset, and: anchor), priority: priority)
        }
    }
    
    func equalToSuperview(offset: CGFloat = 0.0, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { anchor in
            anchor.equalToSuperview(constant: offset, priority: priority)
        }
    }
    
    func equalToSuperview(inset: CGFloat, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { anchor in
            anchor.equalToSuperview(constant: constant(for: inset, and: anchor), priority: priority)
        }
    }
    
    func greaterThanOrEqualTo(_ target: AnchoringRoot, offset: CGFloat = 0.0, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { $0.greaterThanOrEqualTo(target, constant: offset, priority: priority) }
    }
    
    func greaterThanOrEqualTo(_ target: AnchoringRoot, inset: CGFloat, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { anchor in
            anchor.greaterThanOrEqualTo(target, constant: constant(for: inset, and: anchor), priority: priority)
        }
    }
    
    func greaterThanOrEqualToSuperview(offset: CGFloat = 0.0, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { anchor in
            anchor.greaterThanOrEqualToSuperview(constant: offset, priority: priority)
        }
    }
    
    func greaterThanOrEqualToSuperview(inset: CGFloat, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { anchor in
            anchor.greaterThanOrEqualToSuperview(constant: constant(for: inset, and: anchor), priority: priority)
        }
    }
    
    func lessThanOrEqualTo(_ target: AnchoringRoot, offset: CGFloat = 0.0, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { $0.lessThanOrEqualTo(target, constant: offset, priority: priority) }
    }
    
    func lessThanOrEqualTo(_ target: AnchoringRoot, inset: CGFloat, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { anchor in
            anchor.lessThanOrEqualTo(target, constant: constant(for: inset, and: anchor), priority: priority)
        }
    }
    
    func lessThanOrEqualToSuperview(offset: CGFloat = 0.0, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        anchors.map { anchor in
            anchor.lessThanOrEqualToSuperview(constant: offset, priority: priority)
        }
    }
    
    func lessThanOrEqualToSuperview(inset: CGFloat, priority: UILayoutPriority = .required) -> [NSLayoutConstraint]  {
        anchors.map { anchor in
            anchor.lessThanOrEqualToSuperview(constant: constant(for: inset, and: anchor), priority: priority)
        }
    }
    
    private func constant(for inset: CGFloat, and anchor: AnchorPositioningComposing) -> CGFloat {
        switch anchor.type {
        case .bottom, .trailing: return -inset
        default: return inset
        }
    }
    
    var trailing: ComposedPositionAnchor { .init(root: root, anchors: anchors + [root.trailing]) }
    var leading: ComposedPositionAnchor { .init(root: root, anchors: anchors + [root.leading]) }
    var centerX: ComposedPositionAnchor { .init(root: root, anchors: anchors + [root.centerX]) }
    var top: ComposedPositionAnchor { .init(root: root, anchors: anchors + [root.top]) }
    var bottom: ComposedPositionAnchor { .init(root: root, anchors: anchors + [root.bottom]) }
    var centerY: ComposedPositionAnchor { .init(root: root, anchors: anchors + [root.centerY]) }
}
