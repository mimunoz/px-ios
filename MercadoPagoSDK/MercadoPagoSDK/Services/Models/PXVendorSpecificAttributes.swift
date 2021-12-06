import Foundation
/// :nodoc:
open class PXVendorSpecificAttributes: NSObject, Codable {
    open var deviceIdiom: String?
    open var canSendSMS = 1
    open var canMakePhoneCalls = 1
    open var deviceLanguaje: String?
    open var deviceModel: String?
    open var deviceName: String?
    open var simulator = 0

    override public init() {
        let device: UIDevice = UIDevice.current

        if device.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            self.deviceIdiom = "Pad"
        } else {
            self.deviceIdiom = "Phone"
        }

        if Locale.preferredLanguages.count > 0 {
            self.deviceLanguaje = Locale.preferredLanguages[0]
        }

        if !String.isNullOrEmpty(device.model) {
            self.deviceModel = device.model
        }

        if !String.isNullOrEmpty(device.name) {
            self.deviceName = device.name
        }
    }

    public enum PXvendorSpecificAttributesKeys: String, CodingKey {
        case deviceIdiom = "device_idiom"
        case canSendSMS = "can_send_sms"
        case canMakePhoneCalls = "can_make_phone_calls"
        case deviceLanguaje = "device_languaje"
        case deviceModel = "device_model"
        case deviceName = "device_name"
        case simulator
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXvendorSpecificAttributesKeys.self)
        try container.encodeIfPresent(self.deviceIdiom, forKey: .deviceIdiom)
        try container.encode(self.canSendSMS, forKey: .canSendSMS)
        try container.encode(self.canMakePhoneCalls, forKey: .canMakePhoneCalls)
        try container.encodeIfPresent(self.deviceLanguaje, forKey: .deviceLanguaje)
        try container.encodeIfPresent(self.deviceModel, forKey: .deviceModel)
        try container.encodeIfPresent(self.deviceName, forKey: .deviceName)
        try container.encode(self.simulator, forKey: .simulator)
    }
}
