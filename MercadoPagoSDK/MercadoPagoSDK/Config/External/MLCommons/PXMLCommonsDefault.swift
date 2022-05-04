import Foundation

final class PXMLCommonsDefault: NSObject, PXMLCommonsProtocol {
    func open(url: URL, from vc: UIViewController, callback: @escaping ([AnyHashable: Any]?) -> Void) {
        print("Opening url: \(url)")
    }
}
