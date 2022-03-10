//
//  ImpletationStrategyButton.swift
//  MercadoPagoSDKV4
//
//  Created by Rafaela Torres Alves Ribeiro Galdino on 17/02/22.
//

import Foundation

class ImpletationStrategy: StrategyTrackings {
    func getPropertieFlow(flow: String) {
        var properties: [String: Any] = [:]
        let flowIdentifier = MPXTracker.sharedInstance.getFlowName() ?? "PX_Follow"
        properties["flow"] = "/\(flowIdentifier + " " + flow)"
        MPXTracker.sharedInstance.trackScreen(event: PXPaymentsInfoGeneralEvents.infoGeneral_Follow_One_Tap(properties))
    }

    func getPropertiesSecurityCode(flow: String, buttonPressed: Int) {
        var properties: [String: Any] = [:]
        let flowIdentifier = MPXTracker.sharedInstance.getFlowName() ?? "PX_Follow"
        properties["flow"] = "/\(flowIdentifier + flow)"
        properties["button_count_pressed"] = buttonPressed
        MPXTracker.sharedInstance.trackScreen(event: PXPaymentsInfoGeneralEvents.infoGeneral_Follow_Confirm_Security_Code(properties))
    }

    func getPropertiesTrackings(versionLib: String = "0", counter: Int = 0, paymentMethod: PXPaymentMethod?, offlinePaymentMethod: PXOfflinePaymentMethod?, businessResult: PaymentResult?) -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["version_lib"] = versionLib
        properties["button_count_pressed"] = counter

        if let paymentMethod = paymentMethod {
            properties["payment_status"] = paymentMethod.status
            properties["payment_method_id"] = paymentMethod.name
        }

        if let offlinePaymentMethod = offlinePaymentMethod {
            properties["payment_status"] = offlinePaymentMethod.status
            properties["payment_method_id"] = offlinePaymentMethod.name
        }

        if let businessResult = businessResult {
            properties["payment_status"] = businessResult.status
            properties["payment_status_detail"] = businessResult.statusDetail
            properties["payment_method_id"] = businessResult.paymentMethodId
        }

        return properties
    }
}
