import UIKit

class PXPaymentConfigurationServices {
    private var configurations: Set<PXPaymentMethodConfiguration> = []
    private var defaultDiscountConfiguration: PXDiscountConfiguration?

    // Payer Costs for Payment Method
    func getPayerCostsForPaymentMethod(paymentOptionID: String, paymentMethodId: String?, paymentTypeId: String?, splitPaymentEnabled: Bool = false) -> [PXPayerCost]? {
        if let paymentOptionConfiguration = getPaymentOptionConfiguration(paymentOptionID: paymentOptionID, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) {
            if splitPaymentEnabled {
                return paymentOptionConfiguration.amountConfiguration?.splitConfiguration?.primaryPaymentMethod?.payerCosts
            } else {
                return paymentOptionConfiguration.amountConfiguration?.payerCosts
            }
        }
        return nil
    }

    // Amount Configuration for Payment Method
    func getAmountConfigurationForPaymentMethod(paymentOptionID: String?, paymentMethodId: String?, paymentTypeId: String?) -> PXAmountConfiguration? {
        guard let paymentOptionID = paymentOptionID else {
            return nil
        }
        if let paymentOptionConfiguration = getPaymentOptionConfiguration(paymentOptionID: paymentOptionID, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) {
            return paymentOptionConfiguration.amountConfiguration
        }
        return nil
    }

    // Split Configuration for Payment Method
    func getSplitConfigurationForPaymentMethod(paymentOptionID: String, paymentMethodId: String?, paymentTypeId: String?) -> PXSplitConfiguration? {
        if let paymentOptionConfiguration = getPaymentOptionConfiguration(paymentOptionID: paymentOptionID, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) {
            return paymentOptionConfiguration.amountConfiguration?.splitConfiguration
        }
        return nil
    }

    // Selected Payer Cost for Payment Method
    func getSelectedPayerCostsForPaymentMethod(paymentOptionID: String, paymentMethodId: String?, paymentTypeId: String?, splitPaymentEnabled: Bool = false) -> PXPayerCost? {
        if let paymentOptionConfiguration = getPaymentOptionConfiguration(paymentOptionID: paymentOptionID, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) {
            if splitPaymentEnabled {
                return paymentOptionConfiguration.amountConfiguration?.splitConfiguration?.primaryPaymentMethod?.selectedPayerCost
            } else {
                return paymentOptionConfiguration.amountConfiguration?.selectedPayerCost
            }
        }
        return nil
    }

    // Amount to pay without payer cost for Payment Method
    func getAmountToPayWithoutPayerCostForPaymentMethod(paymentOptionID: String?, paymentMethodId: String?, paymentTypeId: String?) -> Double? {
        guard let paymentOptionID = paymentOptionID else {
            return nil
        }
        if let paymentOptionConfiguration = getPaymentOptionConfiguration(paymentOptionID: paymentOptionID, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) {
            return paymentOptionConfiguration.amountConfiguration?.amount
        }
        return nil
    }

    // Amount for Payment Method
    func getAmount(paymentOptionId: String?, paymentMethodId: String?, paymentTypeId: String?) -> Double? {
        guard let paymentOptionId = paymentOptionId else {
            return nil
        }
        if let paymentOptionConfiguration = getPaymentOptionConfiguration(paymentOptionID: paymentOptionId, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) {
            return paymentOptionConfiguration.amountConfiguration?.amount
        }
        return nil
    }

    // Tax Free Amount for Payment Method
    func getTaxFreeAmount(paymentOptionId: String?, paymentMethodId: String?, paymentTypeId: String?) -> Double? {
        guard let paymentOptionId = paymentOptionId else {
            return nil
        }
        if let paymentOptionConfiguration = getPaymentOptionConfiguration(paymentOptionID: paymentOptionId, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) {
            return paymentOptionConfiguration.amountConfiguration?.taxFreeAmount
        }
        return nil
    }

    // No Discount Amount for Payment Method
    func getNoDiscountAmount(paymentOptionId: String?, paymentMethodId: String?, paymentTypeId: String?) -> Double? {
        guard let paymentOptionId = paymentOptionId else {
            return nil
        }
        if let paymentOptionConfiguration = getPaymentOptionConfiguration(paymentOptionID: paymentOptionId, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) {
            return paymentOptionConfiguration.amountConfiguration?.noDiscountAmount
        }
        return nil
    }

    // Discount Configuration for Payment Method
    func getDiscountConfigurationForPaymentMethod(paymentOptionID: String, paymentMethodId: String?, paymentTypeId: String?) -> PXDiscountConfiguration? {
        if let paymentOptionConfiguration = getPaymentOptionConfiguration(paymentOptionID: paymentOptionID, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) {
            let discountConfiguration = paymentOptionConfiguration.discountConfiguration
            return discountConfiguration
        }
        return nil
    }

    // Discount Configuration for Payment Method or Default
    func getDiscountConfigurationForPaymentMethodOrDefault(paymentOptionID: String?, paymentMethodId: String?, paymentTypeId: String?) -> PXDiscountConfiguration? {
        if let paymentOptionID = paymentOptionID,
           let pmDiscountConfiguration = getDiscountConfigurationForPaymentMethod(paymentOptionID: paymentOptionID, paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId) {
            return pmDiscountConfiguration
        }
        return getDefaultDiscountConfiguration()
    }

    // Default Discount Configuration
    func getDefaultDiscountConfiguration() -> PXDiscountConfiguration? {
        return self.defaultDiscountConfiguration
    }

    func getPaymentOptionConfiguration(paymentOptionID: String, paymentMethodId: String?, paymentTypeId: String?) -> PXPaymentOptionConfiguration? {
        if let configuration = configurations.first(where: {
            $0.paymentOptionID == paymentOptionID &&
            $0.paymentMethodId == paymentMethodId &&
            $0.paymentTypeId == paymentTypeId
        }) {
            return configuration.paymentOptionsConfigurations.first(where: { $0.id == configuration.selectedAmountConfiguration })
        }
        printDebug("PaymentOptionConfiguration not found")
        return nil
    }

    func setConfigurations(_ configurations: Set<PXPaymentMethodConfiguration>) {
        self.configurations = configurations
    }

    func setDefaultDiscountConfiguration(_ discountConfiguration: PXDiscountConfiguration?) {
        self.defaultDiscountConfiguration = discountConfiguration
    }
}
