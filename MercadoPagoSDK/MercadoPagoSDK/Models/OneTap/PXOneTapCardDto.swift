import Foundation

/// :nodoc:
open class PXOneTapCardDto: NSObject, Codable {
    open var cardId: String
    open var cardUI: PXCardDisplayInfoDto?
    open var retry: PXRetry?

    public init(cardId: String, cardUI: PXCardDisplayInfoDto?, retry: PXRetry?) {
        self.cardId = cardId
        self.cardUI = cardUI
        self.retry = retry
    }

    public enum PXOneTapCardDtoKeys: String, CodingKey {
        case cardId = "id"
        case cardUI = "display_info"
        case retry = "retry"
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXOneTapCardDtoKeys.self)
        let cardId: String = try container.decode(String.self, forKey: .cardId)
        let cardUI: PXCardDisplayInfoDto? = try container.decodeIfPresent(PXCardDisplayInfoDto.self, forKey: .cardUI)
        let retry: PXRetry? = try container.decodeIfPresent(PXRetry.self, forKey: .retry)
        self.init(cardId: cardId, cardUI: cardUI, retry: retry)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXOneTapCardDtoKeys.self)
        try container.encodeIfPresent(self.cardId, forKey: .cardId)
        try container.encodeIfPresent(self.cardUI, forKey: .cardUI)
        try container.encodeIfPresent(self.retry, forKey: .retry)
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

    open class func fromJSON(data: Data) throws -> PXOneTapCardDto {
        return try JSONDecoder().decode(PXOneTapCardDto.self, from: data)
    }
}

open class PXRetry: NSObject, Codable {
    open var isNeeded: Bool?
    open var reason: String?

    public enum CodingKeys: String, CodingKey {
        case isNeeded = "is_needed"
        case reason = "reason"
    }
}
