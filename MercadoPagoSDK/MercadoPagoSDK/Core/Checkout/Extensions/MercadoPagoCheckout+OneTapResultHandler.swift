import Foundation

extension MercadoPagoCheckout: PXOneTapResultHandlerProtocol {
    func refreshAddAccountFlow(accountId: String) {
        InitFlowRefresh.accountId = accountId
        viewModel.checkoutPreference.setCardId(cardId: "accounts")
        viewModel.prepareForNewSelection()
        viewModel.refreshAddAccountFlow(accountId: accountId)
    }
    
    func finishOneTap(paymentData: PXPaymentData, splitAccountMoney: PXPaymentData?, pointsAndDiscounts: PXPointsAndDiscounts?) {
        viewModel.updateCheckoutModel(paymentData: paymentData)
        viewModel.splitAccountMoney = splitAccountMoney
        viewModel.pointsAndDiscounts = pointsAndDiscounts
        executeNextStep()
    }

    func refreshInitFlow(cardId: String) {
        InitFlowRefresh.cardId = cardId
        viewModel.checkoutPreference.setCardId(cardId: "cards")
        viewModel.prepareForNewSelection()
        viewModel.refreshInitFlow(cardId: cardId)
    }

    func cancelOneTap() {
        viewModel.prepareForNewSelection()
        executeNextStep()
    }

    func cancelOneTapForNewPaymentMethodSelection() {
        viewModel.checkoutPreference.setCardId(cardId: "cards")
        viewModel.prepareForNewSelection()
        executeNextStep()
    }

    func exitCheckout() {
        finish()
    }

    func finishOneTap(paymentResult: PaymentResult, instructionsInfo: PXInstruction?, pointsAndDiscounts: PXPointsAndDiscounts?, paymentOptionSelected: PaymentMethodOption?) {
        if let paymentOptionSelected = paymentOptionSelected, paymentResult.isRejectedWithRemedy() {
            viewModel.updateCheckoutModel(paymentOptionSelected: paymentOptionSelected)
        }
        setPaymentResult(paymentResult: paymentResult)
        viewModel.instructionsInfo = instructionsInfo
        viewModel.pointsAndDiscounts = pointsAndDiscounts
        executeNextStep()
    }

    func finishOneTap(businessResult: PXBusinessResult, paymentData: PXPaymentData, splitAccountMoney: PXPaymentData?, pointsAndDiscounts: PXPointsAndDiscounts?) {
        viewModel.businessResult = businessResult
        viewModel.paymentData = paymentData
        viewModel.splitAccountMoney = splitAccountMoney
        viewModel.pointsAndDiscounts = pointsAndDiscounts
        executeNextStep()
    }
}
