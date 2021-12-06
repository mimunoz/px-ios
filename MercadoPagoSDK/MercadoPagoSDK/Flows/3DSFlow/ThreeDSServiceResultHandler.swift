import Foundation

protocol ThreeDSServiceResultHandler: NSObjectProtocol {
    func finishFlow(threeDSAuthorization: Bool)
    func finishWithError(error: MPSDKError)
}
