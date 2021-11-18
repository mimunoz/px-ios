import Foundation

protocol PXOneTapHeaderProtocol: PXOneTapSummaryProtocol {
    func didTapMerchantHeader()
    func splitPaymentSwitchChangedValue(isOn: Bool, isUserSelection: Bool)
    func didTapBackButton()
}
