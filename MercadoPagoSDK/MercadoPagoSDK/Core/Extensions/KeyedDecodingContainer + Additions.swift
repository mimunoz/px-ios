import Foundation

extension KeyedDecodingContainer {
    func decodeDateFromStringIfPresent(forKey key: K) throws -> Date? {
        let stringDate = try self.decodeIfPresent(String.self, forKey: key)
        let date = String.getDate(stringDate)
        return date
    }
}
