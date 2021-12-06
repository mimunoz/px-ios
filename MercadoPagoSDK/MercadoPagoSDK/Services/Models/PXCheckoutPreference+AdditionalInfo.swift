import Foundation

extension PXCheckoutPreference {
    func populateAdditionalInfoModel() {
        if let additionalInfo = additionalInfo,
            !additionalInfo.isEmpty,
            let data = additionalInfo.data(using: .utf8) {
            do {
                pxAdditionalInfo = try PXAdditionalInfo.fromJSON(data: data)
            } catch {
                printDebug(error)
            }
        }
    }

    func getAdditionalInfoModel() -> PXAdditionalInfo? {
        return pxAdditionalInfo
    }
}
