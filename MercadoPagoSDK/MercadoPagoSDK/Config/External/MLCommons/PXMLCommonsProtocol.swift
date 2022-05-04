import Foundation

@objc public protocol PXMLCommonsProtocol: NSObjectProtocol {
    func open(url: URL, from vc: UIViewController, callback: @escaping ([AnyHashable: Any]?) -> Void)
}
