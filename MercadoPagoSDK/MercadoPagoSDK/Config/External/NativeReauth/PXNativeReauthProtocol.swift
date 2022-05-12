import Foundation

@objc public protocol PXNativeReauthProtocol: NSObjectProtocol {
    func validate(withConfig config: PXNativeReauthConfig, onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void)
}
