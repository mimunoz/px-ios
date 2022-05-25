//
//  ConcurrentToSerialQueueProtocol.swift
//  QueuePOC
//
//  Created by Ricardo Couto D Alambert on 06/05/22.
//

import Foundation

protocol ConcurrentToSerialQueueProtocol: AnyObject {
    static var shared: ConcurrentToSerialQueueProtocol { get }

    var queue: DispatchQueue { get }
    var processedPayments: [(String, Any?)] { get set }

    func executeByCriteria( data: AnyObject?, _ executeHandler: (() -> Void)?)

    func generateUniqueKey(data: AnyObject?) -> String
    func criteria(data: AnyObject?) -> Bool
    func append(data: AnyObject?)
    func revert(data: AnyObject?)
}
