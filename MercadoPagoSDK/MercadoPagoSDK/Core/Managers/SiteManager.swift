import Foundation

class SiteManager {
    private var site: PXSite?
    private var currency: PXCurrency!
    static let shared = SiteManager()

    func setSite(site: PXSite) {
        self.site = site
    }

    func getTermsAndConditionsURL() -> String {
        return site?.termsAndConditionsUrl ?? ""
    }

    func setCurrency(currency: PXCurrency) {
        self.currency = currency
    }

    func getCurrency() -> PXCurrency {
        return currency
    }

    func getSiteId() -> String {
        return site?.id ?? ""
    }

    func getSite() -> PXSite? {
        return site
    }
}
