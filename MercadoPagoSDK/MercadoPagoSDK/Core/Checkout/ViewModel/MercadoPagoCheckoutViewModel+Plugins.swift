import Foundation

extension MercadoPagoCheckoutViewModel {
    func needToShowPaymentMethodConfigPlugin() -> Bool {
        guard let paymentMethodPluginSelected = paymentOptionSelected as? PXPaymentMethodPlugin else {
            return false
        }

        if wasPaymentMethodConfigPluginShowed() {
            return false
        }

        populateCheckoutStore()

        if let shouldSkip = paymentMethodPluginSelected.paymentMethodConfigPlugin?.shouldSkip(store: PXCheckoutStore.sharedInstance) {
            return !shouldSkip
        }

        return paymentMethodPluginSelected.paymentMethodConfigPlugin != nil
    }

    func needToCreatePaymentForPaymentMethodPlugin() -> Bool {
        return needToCreatePayment() && self.paymentOptionSelected is PXPaymentMethodPlugin
    }

    func wasPaymentMethodConfigPluginShowed() -> Bool {
        return paymentMethodConfigPluginShowed
    }

    func willShowPaymentMethodConfigPlugin() {
        paymentMethodConfigPluginShowed = true
    }

    func resetPaymentMethodConfigPlugin() {
        paymentMethodConfigPluginShowed = false
    }

    func paymentMethodPluginToPaymentMethod(plugin: PXPaymentMethodPlugin) {
        let paymentMethod = plugin.toPaymentMethod(financialInstitutions: financialInstitutions)
        self.paymentData.paymentMethod = paymentMethod
    }
}

// MARK: Payment Plugin
extension MercadoPagoCheckoutViewModel {
    func needToCreatePaymentForPaymentPlugin() -> Bool {
        if paymentPlugin == nil {
            return false
        }
        populateCheckoutStore()
        paymentPlugin?.didReceive?(checkoutStore: PXCheckoutStore.sharedInstance)
        if let shouldSupport = paymentPlugin?.support() {
            return shouldSupport
        }
        return needToCreatePayment()
    }
}
