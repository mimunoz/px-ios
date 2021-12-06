import Foundation
/// :nodoc:
open class PXInstructionAction: NSObject, Codable {
    open var label: String?
    open var url: String?
    open var tag: String?
    open var content: String?

    open func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    open func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    open class func fromJSONToPXInstructionAction(data: Data) throws -> PXInstructionAction {
        return try JSONDecoder().decode(PXInstructionAction.self, from: data)
    }

    open class func fromJSON(data: Data) throws -> [PXInstructionAction] {
        return try JSONDecoder().decode([PXInstructionAction].self, from: data)
    }

    init(label: String?, url: String?, tag: String?, content: String?) {
        self.label = label
        self.url = url
        self.tag = tag
        self.content = content
    }
}
