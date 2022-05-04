import Foundation

public struct PXPaymentMethodBehaviour: Codable {
    let paymentTypeRules: [String]?
    let paymentMethodRules: [String]?
    let sliderTitle: String?
    let behaviours: [Behaviour]?

    public init(paymentTypeRules: [String]?, paymentMethodRules: [String]?, sliderTitle: String?, behaviours: [Behaviour]?) {
        self.paymentTypeRules = paymentTypeRules
        self.paymentMethodRules = paymentMethodRules
        self.sliderTitle = sliderTitle
        self.behaviours = behaviours
    }

    public enum CodingKeys: String, CodingKey {
        case paymentTypeRules = "payment_type_rules"
        case paymentMethodRules = "payment_method_rules"
        case sliderTitle = "slider_title"
        case behaviours = "behaviours"
    }
}

public struct Behaviour: Codable {
    let type: String
    let modalContent: ModalContent

    public init(type: String, modalContent: ModalContent) {
        self.type = type
        self.modalContent = modalContent
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case modalContent = "modal_content"
    }
}

public struct ModalContent: Codable {
    let title: PXText
    let description: PXText
    let button: Button
    let imageURL: String?

    public init(title: PXText, description: PXText, button: Button, imageURL: String?) {
        self.title = title
        self.description = description
        self.button = button
        self.imageURL = imageURL
    }

    public enum CodingKeys: String, CodingKey {
        case title
        case description
        case button
        case imageURL = "image_url"
    }
}

public struct Button: Codable {
    let label: String
    let target: String?

    public init(label: String, target: String?) {
        self.label = label
        self.target = target
    }

    public enum CodingKeys: String, CodingKey {
        case label
        case target
    }
}
