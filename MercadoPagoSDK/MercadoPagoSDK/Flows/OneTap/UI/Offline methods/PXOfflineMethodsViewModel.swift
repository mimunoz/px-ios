import Foundation

final class PXOfflineMethodsViewModel: PXReviewViewModel {
    let paymentTypes: [PXOfflinePaymentType]
    var paymentMethods: [PXPaymentMethod] = [PXPaymentMethod]()
    private let payerCompliance: PXPayerCompliance?
    private let displayInfo: PXOneTapDisplayInfo?

    var selectedIndexPath: IndexPath?

    public init(offlinePaymentTypes: [PXOfflinePaymentType]?,
                paymentMethods: [PXPaymentMethod],
                amountHelper: PXAmountHelper,
                paymentOptionSelected: PaymentMethodOption?,
                advancedConfig: PXAdvancedConfiguration,
                userLogged: Bool,
                disabledOption: PXDisabledOption? = nil,
                payerCompliance: PXPayerCompliance?,
                displayInfo: PXOneTapDisplayInfo?) {
        self.paymentTypes = PXOfflineMethodsViewModel.filterPaymentTypes(offlinePaymentTypes: offlinePaymentTypes)
        self.paymentMethods = paymentMethods
        self.payerCompliance = payerCompliance
        self.displayInfo = displayInfo
        super.init(amountHelper: amountHelper, paymentOptionSelected: paymentOptionSelected, advancedConfig: advancedConfig, userLogged: userLogged)
        autoSelectPaymentMethodIfNeeded()
    }

    func getTotalTitle() -> PXText {
        let amountString = Utils.getAmountFormated(amount: amountHelper.amountToPay, forCurrency: SiteManager.shared.getCurrency())
        let totalString = "Total".localized + " \(amountString)"

        return PXText(message: totalString, backgroundColor: nil, textColor: nil, weight: "semi_bold", alignment: nil)
    }

    func numberOfSections() -> Int {
        return paymentTypes.count
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return paymentTypes[section].paymentMethods.count
    }

    func heightForRowAt(_ indexPath: IndexPath) -> CGFloat {
        return 82
    }

    func dataForCellAt(_ indexPath: IndexPath) -> PXOfflineMethodsCellData {
        let isSelected: Bool = selectedIndexPath == indexPath
        let model = paymentTypes[indexPath.section].paymentMethods[indexPath.row]

        return PXOfflineMethodsCellData(title: model.name, subtitle: model.description, imageUrl: model.imageUrl, isSelected: isSelected)
    }

    func headerTitleForSection(_ section: Int) -> PXText? {
        return paymentTypes[section].name
    }

    func getTitleForLastSection() -> String? {
        if let message = paymentTypes.last?.name?.message {
            return message.lowercased().firstCapitalized
        }
        return nil
    }

    func getSelectedOfflineMethod() -> PXOfflinePaymentMethod? {
        guard let selectedIndex = selectedIndexPath else {
            return nil
        }

        return paymentTypes[selectedIndex.section].paymentMethods[selectedIndex.row]
    }

    func getOfflinePaymentMethod(targetOfflinePaymentMethod: PXOfflinePaymentMethod) -> PXPaymentMethod? {
        return Utils.findOfflinePaymentMethod(paymentMethods, offlinePaymentMethod: targetOfflinePaymentMethod)
    }

    func getPayerCompliance() -> PXPayerCompliance? {
        return payerCompliance
    }

    func getPayerFirstName() -> String? {
        return payerCompliance?.offlineMethods.sensitiveInformation?.firstName
    }

    func getPayerLastName() -> String? {
        return payerCompliance?.offlineMethods.sensitiveInformation?.lastName
    }

    func getPayerIdentification() -> PXIdentification? {
        return payerCompliance?.offlineMethods.sensitiveInformation?.identification
    }

    func getDisplayInfo() -> PXOneTapDisplayInfo? {
        return displayInfo
    }
}

// MARK: Privates
private extension PXOfflineMethodsViewModel {
    class func filterPaymentTypes(offlinePaymentTypes: [PXOfflinePaymentType]?) -> [PXOfflinePaymentType] {
        var filteredOfflinePaymentTypes: [PXOfflinePaymentType] = [PXOfflinePaymentType]()
        var filteredPaymentMethods: [PXOfflinePaymentMethod] = [PXOfflinePaymentMethod]()

        guard let offlinePaymentTypes = offlinePaymentTypes else {
            return filteredOfflinePaymentTypes
        }

        for paymentType in offlinePaymentTypes {
            for paymentMethod in paymentType.paymentMethods where paymentMethod.status.enabled {
                filteredPaymentMethods.append(paymentMethod)
            }
            let offlinePaymentType = PXOfflinePaymentType(id: paymentType.id, name: paymentType.name, paymentMethods: filteredPaymentMethods)
            filteredOfflinePaymentTypes.append(offlinePaymentType)
            filteredPaymentMethods.removeAll()
        }
        return filteredOfflinePaymentTypes
    }

    private func autoSelectPaymentMethodIfNeeded() {
        guard (paymentTypes.flatMap { $0.paymentMethods }.count) > 0 else { return }
        selectedIndexPath = IndexPath(row: 0, section: 0)
    }
}

// MARK: Tracking OfflineMethods
extension PXOfflineMethodsViewModel {
    func getScreenTrackingProperties() -> [String: Any] {
        var infoArray: [[String: Any]] = [[String: Any]]()
        for paymentType in paymentTypes {
            for paymentMethod in paymentType.paymentMethods {
                var info: [String: Any] = [:]
                info["payment_method_type"] = paymentType.id
                info["payment_method_id"] = paymentMethod.id
                infoArray.append(info)
            }
        }
        var availableMethods: [String: Any] = [String: Any]()
        availableMethods["available_methods"] = infoArray
        return availableMethods
    }

    func getEventTrackingProperties(_ selectedOfflineMethod: PXOfflinePaymentMethod) -> [String: Any] {
        var properties: [String: Any] = [String: Any]()
        properties["payment_method_type"] = selectedOfflineMethod.instructionId
        properties["payment_method_id"] = selectedOfflineMethod.id
        properties["review_type"] = "one_tap"
        var info: [String: Any] = [:]
        info["has_payer_information"] = getPayerCompliance()?.offlineMethods.isCompliant
        info["additional_information_needed"] = selectedOfflineMethod.hasAdditionalInfoNeeded
        properties["extra_info"] = info
        return properties
    }
}
