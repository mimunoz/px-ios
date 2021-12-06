import Foundation
/// :nodoc:
open class PXCause: NSObject, Codable {
    open var code: String?
    open var _description: String?

    public init(code: String?, description: String?) {
        self.code = code
        self._description = description
    }

    public enum PXCauseKeys: String, CodingKey {
        case code
        case description = "description"
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXCauseKeys.self)
        var code = ""
        do {
            let codeInt = try container.decodeIfPresent(Int.self, forKey: .code)
            code = (codeInt?.stringValue)!
        } catch {
            let stringId = try container.decodeIfPresent(String.self, forKey: .code)
            code = stringId!
        }
        let description: String? = try container.decodeIfPresent(String.self, forKey: .description)

        self.init(code: code, description: description)
    }
}
