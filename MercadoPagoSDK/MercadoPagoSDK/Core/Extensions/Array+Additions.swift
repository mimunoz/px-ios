import Foundation
extension Array {
    static func isNullOrEmpty(_ value: Array?) -> Bool {
        return value == nil || value?.count == 0
    }
}
