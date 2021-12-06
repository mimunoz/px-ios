import Foundation
/// :nodoc:
open class PXOrder: NSObject, Codable {
    open var id: String!
    open var type: String?

    open func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    open func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    open class func fromJSONToPXOrder(data: Data) throws -> PXOrder {
        return try JSONDecoder().decode(PXOrder.self, from: data)
    }

    open class func fromJSON(data: Data) throws -> [PXOrder] {
        return try JSONDecoder().decode([PXOrder].self, from: data)
    }
}
