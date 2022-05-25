//
//  PXMLRemoteConfigurationsProtocol.swift
//  MercadoPagoSDKV4
//
//  Created by Ricardo Couto d'Alambert on 21/05/2022.
//  Copyright © 2022 Mercado Pago. All rights reserved.
//

import Foundation

@objc public protocol PXMLRemoteConfigurationsProtocol: NSObjectProtocol {
    
    func setProvider(keepnite: AnyObject?)
    
    func isFlagEnable(flag: String, defaultValue: Bool) -> Bool
    
    func isFlagEnabled(flag : String, defaultValue: Bool) -> Bool
    
    func flagsUpdateNotificationName() -> Notification.Name
}
