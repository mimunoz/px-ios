import Foundation

protocol TokenizationServiceResultHandler: NSObjectProtocol {
    func finishFlow(token: PXToken, shouldResetESC: Bool)
    func finishWithESCError()
    func finishWithError(error: MPSDKError, securityCode: String?)
    func finishInvalidIdentificationNumber()
}
