import Foundation
/// :nodoc:
open class PXPaymentType: NSObject, Codable {
    open var id: String!

    open func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    open func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    open class func fromJSONToPXPaymentType(data: Data) throws -> PXPaymentType {
        return try JSONDecoder().decode(PXPaymentType.self, from: data)
    }

    open class func fromJSON(data: Data) throws -> [PXPaymentType] {
        return try JSONDecoder().decode([PXPaymentType].self, from: data)
    }
}
