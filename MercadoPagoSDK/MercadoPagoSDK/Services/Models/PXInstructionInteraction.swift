import Foundation
/// :nodoc:
open class PXInstructionInteraction: NSObject, Codable {
    open var title: String?
    open var content: String?
    open var action: PXInstructionAction?
    open var showMultiLine: Bool

    public init(title: String?, content: String?, action: PXInstructionAction?, showMultiLine: Bool) {
        self.title = title
        self.content = content
        self.action = action
        self.showMultiLine = showMultiLine
    }

    public enum PXInstructionInteractionKeys: String, CodingKey {
        case title
        case content
        case action
        case showMultiLine = "show_multiline_content"
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXInstructionInteractionKeys.self)
        let title: String? = try container.decodeIfPresent(String.self, forKey: .title)
        let content: String? = try container.decodeIfPresent(String.self, forKey: .content)
        let action: PXInstructionAction? = try container.decodeIfPresent(PXInstructionAction.self, forKey: .action)
        let showMultiLine: Bool = try container.decodeIfPresent(Bool.self, forKey: .showMultiLine) ?? true

        self.init(title: title, content: content, action: action, showMultiLine: showMultiLine)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXInstructionInteractionKeys.self)
        try container.encodeIfPresent(self.title, forKey: .title)
        try container.encodeIfPresent(self.content, forKey: .content)
        try container.encodeIfPresent(self.action, forKey: .action)
    }

    open func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    open func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    open class func fromJSONToPXInstructionInteraction(data: Data) throws -> PXInstructionInteraction {
        return try JSONDecoder().decode(PXInstructionInteraction.self, from: data)
    }

    open class func fromJSON(data: Data) throws -> [PXInstructionInteraction] {
        return try JSONDecoder().decode([PXInstructionInteraction].self, from: data)
    }
}
