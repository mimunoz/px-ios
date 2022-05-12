import Foundation

@objcMembers
open class PXNativeReauthConfig: NSObject {
    public let flowIdentifier: String
    public var paymentExperience: ReauthPaymentExperience?
    public var paymentMethod: ReauthPaymentMethod?

    init(_ flowIdentifier: String) {
        self.flowIdentifier = flowIdentifier
    }
}

// MARK: Internals (Only PX)
extension PXNativeReauthConfig {
    func setPaymentExperience(paymentExperience: ReauthPaymentExperience) {
        self.paymentExperience = paymentExperience
    }

    func setPaymentMethod(paymentMethod: ReauthPaymentMethod) {
        self.paymentMethod = paymentMethod
    }

    static func createConfig(withFlowIdentifier flowIdentifier: String? = nil,
                             andPaymentExp paymentExperience: ReauthPaymentExperience? = nil,
                             andPaymentMethod paymentMethod: ReauthPaymentMethod? = nil) -> PXNativeReauthConfig {
        let flowId: String = "px-checkout"
        var defaultConfig = PXNativeReauthConfig(flowId)

        if let flowIdentifier = flowIdentifier {
            defaultConfig = PXNativeReauthConfig(flowIdentifier)
        }

        guard let paymentExperience = paymentExperience else {
            return defaultConfig
        }

        defaultConfig.setPaymentExperience(paymentExperience: paymentExperience)

        guard let paymentMethod = paymentMethod else {
            return defaultConfig
        }

        defaultConfig.setPaymentMethod(paymentMethod: paymentMethod)
        return defaultConfig
    }
}
