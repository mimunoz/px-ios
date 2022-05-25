//
//  PXMLRemoteConfigurationsDefault.swift
//  MercadoPagoSDKV4
//
//  Created by Ricardo Couto d'Alambert on 21/05/2022.
//  Copyright © 2022 Mercado Pago. All rights reserved.
//

import Foundation

/**
Default PX implementation of MLRemoteConfigurations for public distribution. (No-validation)
 */
final class PXMLRemoteConfigurationsDefault: NSObject, PXMLRemoteConfigurationsProtocol {
    
    func setProvider(keepnite: AnyObject?) {
        
    }
    
    func isFlagEnable(flag: String, defaultValue: Bool) -> Bool {
        return false
    }
    
    func isFlagEnabled(flag : String, defaultValue: Bool) -> Bool {
        return false
    }
    
    func flagsUpdateNotificationName() -> Notification.Name {
        return Notification.Name(rawValue: "")
    }
}
