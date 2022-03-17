//
//  StrategyTrackings.swift
//  MercadoPagoSDKV4
//
//  Created by Rafaela Torres Alves Ribeiro Galdino on 17/02/22.
//

import Foundation

protocol StrategyTrackings {
    func getPropertieFlow(flow: String)
    func getPropertieFlowSuccess(flow: String)
    func getPropertiesSecurityCode(flow: String, buttonPressed: Int)
    func getPropertiesTrackings(versionLib: String, counter: Int, paymentMethod: PXPaymentMethod?, offlinePaymentMethod: PXOfflinePaymentMethod?, businessResult: PaymentResult?) -> [String: Any]
}
