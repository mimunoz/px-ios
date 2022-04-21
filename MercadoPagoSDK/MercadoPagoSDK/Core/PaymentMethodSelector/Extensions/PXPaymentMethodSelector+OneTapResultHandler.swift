import Foundation

func executeNextStep () {
    print("Execute nextStep")
}

extension PXPaymentMethodSelector: PXOneTapResultHandlerProtocol {
    func finishOneTap(paymentData: PXPaymentData, splitAccountMoney: PXPaymentData?, pointsAndDiscounts: PXPointsAndDiscounts?) {
        viewModel?.updateCheckoutModel(paymentData: paymentData)

        viewModel?.populateCheckoutStore()

        if let callback = viewModel?.delegate?.didSelectPaymentMethod() {
            callback(PXCheckoutStore.sharedInstance)
        }
//        viewModel.splitAccountMoney = splitAccountMoney
//        executeNextStep()
        commonFinish()
        defaultExitAction()
    }

    func refreshInitFlow(cardId: String) {
        InitFlowRefresh.cardId = cardId
        viewModel?.checkoutPreference.setCardId(cardId: "cards")
        viewModel?.prepareForNewSelection()
        viewModel?.refreshInitFlow(cardId: cardId)
    }

    func cancelOneTap() {
        viewModel?.prepareForNewSelection()
        executeNextStep()
    }

    func cancelOneTapForNewPaymentMethodSelection() {
        viewModel?.checkoutPreference.setCardId(cardId: "cards")
        viewModel?.prepareForNewSelection()
        executeNextStep()
    }

    // This method should not be executed on PXPaymentSelector mode
    func finishOneTap(paymentResult: PaymentResult, instructionsInfo: PXInstruction?, pointsAndDiscounts: PXPointsAndDiscounts?, paymentOptionSelected: PaymentMethodOption?) {
        if let paymentOptionSelected = paymentOptionSelected, paymentResult.isRejectedWithRemedy() {
            viewModel?.updateCheckoutModel(paymentOptionSelected: paymentOptionSelected)
        }
        return
    }

    // This method should not be executed on PXPaymentSelector mode
    func finishOneTap(businessResult: PXBusinessResult, paymentData: PXPaymentData, splitAccountMoney: PXPaymentData?, pointsAndDiscounts: PXPointsAndDiscounts?) {
        return
    }
}
