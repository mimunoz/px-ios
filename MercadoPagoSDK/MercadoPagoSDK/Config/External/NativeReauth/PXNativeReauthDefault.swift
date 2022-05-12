import Foundation

final class PXNativeReauthDefault: NSObject, PXNativeReauthProtocol {
    func validate(withConfig config: PXNativeReauthConfig, onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void) {
        onSuccess()
    }
}
