import Foundation

extension PXCurrency {
    func getCurrencySymbolOrDefault() -> String {
        return self.symbol ?? "$"
    }

    func getThousandsSeparatorOrDefault() -> String {
        return thousandSeparator ?? "."
    }

    func getDecimalPlacesOrDefault() -> Int {
        return decimalPlaces ?? 2
    }

    func getDecimalSeparatorOrDefault() -> String {
        return decimalSeparator ?? ","
    }
}
