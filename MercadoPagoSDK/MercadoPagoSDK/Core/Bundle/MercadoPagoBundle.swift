import Foundation

class MercadoPagoBundle {
    static func bundle() -> Bundle {
        let bundle = Bundle(for: MercadoPagoBundle.self)
        if let path = bundle.path(forResource: "MercadoPagoSDKResources", ofType: "bundle"),
            let resourcesBundle = Bundle(path: path) {
            return resourcesBundle
        }
        return bundle
    }

    static func bundleShortVersionString() -> String? {
        return bundle().infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
