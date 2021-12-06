import Foundation
/// :nodoc:
open class PXDevice: NSObject, Codable {
    open var fingerprint: PXFingerprint = PXFingerprint()

    open func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    open func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    open class func fromJSON(data: Data) throws -> PXDevice {
        return try JSONDecoder().decode(PXDevice.self, from: data)
    }
}
