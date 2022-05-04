import Foundation

final class PXOneTapInstallmentInfoViewModel {
    var text: NSAttributedString
    var installmentData: PXInstallment?
    var selectedPayerCost: PXPayerCost?
    var shouldShowArrow: Bool
    var status: PXStatus
    let benefits: PXBenefits?
    let shouldShowInstallmentsHeader: Bool
    let behaviours: [String: PXBehaviour]?

    init(text: NSAttributedString, installmentData: PXInstallment?, selectedPayerCost: PXPayerCost?, shouldShowArrow: Bool, status: PXStatus, benefits: PXBenefits?, shouldShowInstallmentsHeader: Bool, behaviours: [String: PXBehaviour]?) {
        self.text = text
        self.installmentData = installmentData
        self.selectedPayerCost = selectedPayerCost
        self.shouldShowArrow = shouldShowArrow
        self.status = status
        self.benefits = benefits
        self.shouldShowInstallmentsHeader = shouldShowInstallmentsHeader
        self.behaviours = behaviours
    }
}
