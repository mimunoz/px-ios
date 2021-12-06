import UIKit

protocol AnchoringRoot: AnyObject {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var widthAnchor: NSLayoutDimension { get }
    var heightAnchor: NSLayoutDimension { get }
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }
    var superview: UIView? { get }
    var translatesAutoresizingMaskIntoConstraints: Bool { get set }
}

extension AnchoringRoot {
    var leading: AnchorX { .init(anchor: leadingAnchor, root: self, type: .leading) }
    var trailing: AnchorX { .init(anchor: trailingAnchor, root: self, type: .trailing) }
    var centerX: AnchorX { .init(anchor: centerXAnchor, root: self, type: .centerX) }
    var top: AnchorY { .init(anchor: topAnchor, root: self, type: .top) }
    var bottom: AnchorY { .init(anchor: bottomAnchor, root: self, type: .bottom) }
    var centerY: AnchorY { .init(anchor: centerYAnchor, root: self, type: .centerY) }
    var width: AnchorDimension { .init(anchor: widthAnchor, root: self, type: .width) }
    var height: AnchorDimension { .init(anchor: heightAnchor, root: self, type: .height) }
    var centerXY: ComposedPositionAnchor { .init(root: self, anchors: [centerX, centerY]) }
    var edges: ComposedPositionAnchor { .init(root: self, anchors: [top, leading, bottom, trailing]) }
    var size: ComposedDimensionAnchor { .init(root: self, anchors: [width, height] ) }
}

extension UIView: AnchoringRoot {}

extension UILayoutGuide: AnchoringRoot {
    var superview: UIView? { owningView?.superview }
    var translatesAutoresizingMaskIntoConstraints: Bool {
        get { owningView?.translatesAutoresizingMaskIntoConstraints ?? false }
        set { owningView?.translatesAutoresizingMaskIntoConstraints = newValue }
    }
}
