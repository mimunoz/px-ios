import Foundation
/// :nodoc:
open class PXCurrency: NSObject, Codable {
    open var id: String!
    open var _description: String?
    open var symbol: String?
    open var decimalPlaces: Int?
    open var decimalSeparator: String?
    open var thousandSeparator: String?

    public init (id: String, description: String?, symbol: String?, decimalPlaces: Int?, decimalSeparator: String?, thousandSeparator: String?) {
        self.id = id
        self._description = description
        self.symbol = symbol
        self.decimalPlaces = decimalPlaces
        self.decimalSeparator = decimalSeparator
        self.thousandSeparator = thousandSeparator
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case _description = "description"
        case symbol
        case decimalPlaces = "decimal_places"
        case decimalSeparator = "decimal_separator"
        case thousandSeparator = "thousands_separator"
    }
}
