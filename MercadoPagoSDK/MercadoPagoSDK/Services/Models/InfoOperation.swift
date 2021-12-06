import AndesUI

struct InfoOperation: Codable {
    let hierarchy: String
    let type: String
    let body: String

    var andesHierarchy: AndesMessageHierarchy {
        switch hierarchy.uppercased() {
        case "LOUD": return .loud
        case "QUIET": return .quiet
        default: return .quiet
        }
    }

    var andesType: AndesMessageType {
        switch type.uppercased() {
        case "NEUTRAL": return .neutral
        case "SUCCESS": return .success
        case "WARNING": return .warning
        case "ERROR": return .error
        default: return .neutral
        }
    }
}
