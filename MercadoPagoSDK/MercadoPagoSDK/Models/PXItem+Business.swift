import Foundation
extension PXItem {
    // MARK: Validation.
    func validate() -> String? {
        if quantity <= 0 {
            return "La cantidad de items no es valida".localized
        }
        return nil
    }

    // MARK: Tracking
    func getItemForTracking() -> [String: Any] {
        var itemDic: [String: Any] = [:]
        var idItemDic: [String: Any] = [:]
        idItemDic["id"] = id
        idItemDic["description"] = getDescription()
        idItemDic["price"] = getUnitPrice()
        itemDic["item"] = idItemDic
        itemDic["quantity"] = getQuantity()
        itemDic["currency_id"] = currencyId

        return itemDic
    }
}
