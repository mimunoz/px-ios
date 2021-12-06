import Foundation

@objc protocol PXComponentizable {
    func render() -> UIView
    @objc optional func oneTapRender() -> UIView
}

protocol PXXibComponentizable {
    func xibName() -> String
    func containerView() -> UIView
    func renderXib() -> UIView
}
