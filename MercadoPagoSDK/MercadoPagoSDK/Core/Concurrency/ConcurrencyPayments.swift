//
//  ConcurrencyPayments.swift
//  QueuePOC
//
//  Created by Ricardo Couto D Alambert on 06/05/22.
//

import Foundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

final class ConcurrencyPayments: ConcurrentToSerialQueueProtocol {
    internal var queue: DispatchQueue = DispatchQueue.init(label: "ConcurrencyPaymentsDispatch")
    internal var processedPayments: [(String, Any?)] = []

    static var shared: ConcurrentToSerialQueueProtocol = ConcurrencyPayments()

    /*
     * ExecuteByCriteria - specific implementation
     */

    func executeByCriteria(data: AnyObject?, _ executeHandler: (() -> Void)? = nil) {
        // featureFlag - if the featureFlag is disabled, code runs as it was before (ExecuteHandler and get out)

        if !PXFeatureFlag.shared.isEnabled(.concurrencyPayments) {
            executeHandler?()
            return
        }

        queue.sync {
            if criteria(data: data) {
                self.append(data: data)

                executeHandler?()
            } else {
                print("\(Thread.current) \(String(describing: data)) already processed")
            }
        }
    }

    /**
     * generateUniqueKey - concrete implementation of abstract key generation method - MD5 return
     */

    internal func generateUniqueKey(data: AnyObject?) -> String {
        let source = data as? PXCheckoutStore

        var result = "\(source?.checkoutPreference?.payer.email ?? String())-" +
        "\(source?.checkoutPreference?.siteId ?? String())-" +
        "\(source?.checkoutPreference?.payer.id ?? String())-" +
        "\(source?.checkoutPreference?.payer.accessToken ?? String())"

        for item in source?.checkoutPreference?.items ?? [] {
            result += "-\(item.id ?? String())-\(item.title)-\(item.quantity)\(item.unitPrice)"
        }

        // MD5

        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = result.data(using: .utf8)
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData?.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData?.count ?? 0)

                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }

                return 0
            } ?? 0
        }

        let md5Hex = digestData.map { String(format: "%02hhx", $0) }.joined()
        print("md5Hex: \(md5Hex)")

        let md5Base64 = digestData.base64EncodedString()
        print("md5Base64: \(md5Base64)")

        return md5Hex
    }

    /*
     * Internal criteria - specific concrete implementation
     */

    internal func criteria(data: AnyObject?) -> Bool {
        let key = self.generateUniqueKey(data: data)

        let result = processedPayments.filter { object in
            let interval = object.1 as? TimeInterval ?? 0

            // timeCriteria - diff in seconds from the last payment and the current one - LocalTime
            let timeCriteria = NSDate().timeIntervalSince1970 - (interval) < 3

            print("diff: \(NSDate().timeIntervalSince1970 - interval)")

            return object.0 == key && timeCriteria
        }

        return result.isEmpty
    }

    /*
     * Append method - specific implementation
     */

    internal func append(data: AnyObject?) {
        let key: String = self.generateUniqueKey(data: data)

        processedPayments.append((key, NSDate().timeIntervalSince1970))
    }

    /*
     * Revert method - specific implementation
     */

    internal func revert(data: AnyObject?) {
        let data = data as? PXCheckoutPreference

        let source = PXCheckoutStore()
        source.checkoutPreference = data

        let key = self.generateUniqueKey(data: source)

        if let index = processedPayments.lastIndex(where: { object in object.0 == key }) {
            processedPayments.remove(at: index)
        }
    }
}
