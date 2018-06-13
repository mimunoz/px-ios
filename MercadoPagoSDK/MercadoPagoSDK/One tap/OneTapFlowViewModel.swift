//
//  OneTapFlowViewModel.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 09/05/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
class OneTapFlowViewModel: NSObject, PXFlowModel {

    enum Steps: String {
        case finish
        case screenReviewOneTap
        case screenSecurityCode
        case serviceCreateESCCardToken
        case payment
    }

    var paymentData: PaymentData
    let checkoutPreference: CheckoutPreference
    var paymentOptionSelected: PaymentMethodOption
    let search: PaymentMethodSearch
    var readyToPay: Bool = false
    var payerCosts: [PayerCost]?
    var paymentResult: PaymentResult?

    // Payment flow
    var paymentFlow: PaymentFlow?
    var finishOneTapWithPaymentResultCallback: ((PaymentResult) -> Void)?

    // In order to ensure data updated create new instance for every usage
    private var amountHelper: PXAmountHelper {
        get {
            return PXAmountHelper(preference: self.checkoutPreference, paymentData: self.paymentData, discount: self.paymentData.discount, campaign: self.paymentData.campaign)
        }
    }

    let mpESCManager: MercadoPagoESC = MercadoPagoESCImplementation()
    let reviewScreenPreference: ReviewScreenPreference
    let mercadoPagoServicesAdapter = MercadoPagoServicesAdapter(servicePreference: MercadoPagoCheckoutViewModel.servicePreference)

    init(paymentData: PaymentData, checkoutPreference: CheckoutPreference, search: PaymentMethodSearch, paymentOptionSelected: PaymentMethodOption, reviewScreenPreference: ReviewScreenPreference = ReviewScreenPreference()) {
        self.paymentData = paymentData.copy() as? PaymentData ?? paymentData
        self.checkoutPreference = checkoutPreference
        self.search = search
        self.paymentOptionSelected = paymentOptionSelected
        self.reviewScreenPreference = reviewScreenPreference
        super.init()

        if let payerCost = search.oneTap?.oneTapCard?.selectedPayerCost {
            updateCheckoutModel(payerCost: payerCost)
        }
    }
    public func nextStep() -> Steps {
        if needReviewAndConfirmForOneTap() {
            return .screenReviewOneTap
        }
        if needSecurityCode() {
            return .screenSecurityCode
        }
        if needCreateESCToken() {
            return .serviceCreateESCCardToken
        }
        if needCreatePayment() {
            return .payment
        }
        return .finish
    }
}

// MARK: Create view model
extension OneTapFlowViewModel {
    public func savedCardSecurityCodeViewModel() -> SecurityCodeViewModel {
        guard let cardInformation = self.paymentOptionSelected as? CardInformation else {
            fatalError("Cannot convert payment option selected to CardInformation")
        }

        guard let paymentMethod = paymentData.paymentMethod else {
            fatalError("Don't have paymentData to open Security View Controller")
        }

        let reason = SecurityCodeViewModel.Reason.SAVED_CARD
        return SecurityCodeViewModel(paymentMethod: paymentMethod, cardInfo: cardInformation, reason: reason)
    }

    func reviewConfirmViewModel() -> PXOneTapViewModel {
        return PXOneTapViewModel(amountHelper: self.amountHelper, paymentOptionSelected: paymentOptionSelected, reviewScreenPreference: reviewScreenPreference, shouldAnimatePayButton: hasSavedESC())
    }
}

// MARK: Update view models
extension OneTapFlowViewModel {
    func updateCheckoutModel(paymentData: PaymentData) {
        self.paymentData = paymentData
        self.readyToPay = true
    }

    public func updateCheckoutModel(token: Token) {
        self.paymentData.updatePaymentDataWith(token: token)
    }

    public func updateCheckoutModel(payerCost: PayerCost) {
        if paymentOptionSelected.isCard() {
            self.paymentData.updatePaymentDataWith(payerCost: payerCost)
            self.paymentData.cleanToken()
        }
    }

}

// MARK: Flow logic
extension OneTapFlowViewModel {
    func needReviewAndConfirmForOneTap() -> Bool {
        if readyToPay {
            return false
        }

        if paymentData.isComplete(shouldCheckForToken: false) {
            return true
        }

        return false
    }

    func needSecurityCode() -> Bool {
        guard let paymentMethod = self.paymentData.getPaymentMethod() else {
            return false
        }

        if !readyToPay {
            return false
        }

        let hasInstallmentsIfNeeded = paymentData.hasPayerCost() || !paymentMethod.isCreditCard
        let isCustomerCard = paymentOptionSelected.isCustomerPaymentMethod() && paymentOptionSelected.getId() != PaymentTypeId.ACCOUNT_MONEY.rawValue

        if  isCustomerCard && !paymentData.hasToken() && hasInstallmentsIfNeeded && !hasSavedESC() {
            return true
        }
        return false
    }

    func needCreateESCToken() -> Bool {
        guard let paymentMethod = self.paymentData.getPaymentMethod() else {
            return false
        }

        let hasInstallmentsIfNeeded = self.paymentData.getPayerCost() != nil || !paymentMethod.isCreditCard
        let savedCardWithESC = !paymentData.hasToken() && paymentMethod.isCard && hasSavedESC() && hasInstallmentsIfNeeded

        return savedCardWithESC
    }

    func needCreatePayment() -> Bool {
        if !readyToPay {
            return false
        }
        return paymentData.isComplete(shouldCheckForToken: false) && paymentFlow != nil
    }

    func hasSavedESC() -> Bool {
        // TODO: Remove
        return true
        if let card = paymentOptionSelected as? CardInformation {
            return mpESCManager.getESC(cardId: card.getCardId()) == nil ? false : true
        }
        return false
    }
}
