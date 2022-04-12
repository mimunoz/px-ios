//
//  PXPaymentsInfoGeneralEvents.swift
//  MercadoPagoSDKV4
//

import Foundation

enum PXPaymentsInfoGeneralEvents: TrackingEvents {
    case infoGeneral_Follow_One_Tap([String: Any])
    case infoGeneral_Follow_Success
    case infoGeneral_Follow_Reject
    case infoGeneral_Follow_Pending
    case infoGeneral_Follow_Confirm_Payments([String: Any])
    case infoGeneral_Follow_Confirm_Security_Code([String: Any])

    var name: String {
        switch self {
        case .infoGeneral_Follow_One_Tap: return "/px_checkout/follow/px_one_tap"
        case .infoGeneral_Follow_Success: return "/px_checkout/follow/success"
        case .infoGeneral_Follow_Reject: return "/px_checkout/follow/reject"
        case .infoGeneral_Follow_Pending: return "/px_checkout/follow/pending"
        case .infoGeneral_Follow_Confirm_Payments: return "/px_checkout/follow/confirm_payments_button_pressed"
        case .infoGeneral_Follow_Confirm_Security_Code: return "/px_checkout/securityCode/pay_button_pressed"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .infoGeneral_Follow_One_Tap(let properties), .infoGeneral_Follow_Confirm_Payments(let properties), .infoGeneral_Follow_Confirm_Security_Code(let properties): return properties
        case  .infoGeneral_Follow_Success, .infoGeneral_Follow_Reject, .infoGeneral_Follow_Pending: return [:]
        }
    }
}
