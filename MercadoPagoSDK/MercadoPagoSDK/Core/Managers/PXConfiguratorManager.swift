import Foundation

/// :nodoc
@objcMembers
open class PXConfiguratorManager: NSObject {
    // MARK: Internal definitions. (Only PX)
    // PX Biometric
    static var biometricProtocol: PXBiometricProtocol = PXBiometricDefault()
    static var biometricConfig: PXBiometricConfig = PXBiometricConfig.createConfig()
    static func hasSecurityValidation() -> Bool {
        return biometricProtocol.isValidationRequired(config: biometricConfig)
    }

    // PX Flow Behaviour
    static var flowBehaviourProtocol: PXFlowBehaviourProtocol = PXFlowBehaviourDefault()

    // ESC
    static var escProtocol: PXESCProtocol = PXESCDefault()
    static var escConfig: PXESCConfig = PXESCConfig.createConfig()

    // 3DS
    static var threeDSProtocol: PXThreeDSProtocol = PXThreeDSDefault()
    static var threeDSConfig: PXThreeDSConfig = PXThreeDSConfig.createConfig()

    // ProfileID
    static var profileIDProtocol: PXProfileIDProtocol = PXProfileIDDefault()

    // MARK: Public
    // Set external implementation of PXBiometricProtocol
    public static func with(biometric biometricProtocol: PXBiometricProtocol) {
        self.biometricProtocol = biometricProtocol
    }

    // Set external implementation of PXFlowBehaviourProtocol
    public static func with(flowBehaviourProtocol: PXFlowBehaviourProtocol) {
        self.flowBehaviourProtocol = flowBehaviourProtocol
    }

    // Set external implementation of PXESCProtocol
    public static func with(escProtocol: PXESCProtocol) {
        self.escProtocol = escProtocol
    }

    // Set external implementation of PXThreeDSProtocol
    public static func with(threeDSProtocol: PXThreeDSProtocol) {
        self.threeDSProtocol = threeDSProtocol
    }

    // Set external implementation of PXProfileIDProtocol
    public static func with(profileIDProtocol: PXProfileIDProtocol) {
        self.profileIDProtocol = profileIDProtocol
    }
}
