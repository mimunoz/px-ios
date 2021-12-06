import Foundation

extension MercadoPagoCheckout {
    class func showPayerCostDescription() -> Bool {
        let dictionary = ResourceManager.shared.getDictionaryForResource(named: "PayerCostPreferences")
        let site = SiteManager.shared.getSiteId()

        if let siteDic = dictionary?.value(forKey: site) as? NSDictionary {
            if let payerCostDescription = siteDic.value(forKey: "payerCostDescription") as? Bool {
                return payerCostDescription
            }
        }

        return true
    }
}
