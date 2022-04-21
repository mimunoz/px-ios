 import Foundation

 public struct PXPaymentMethodBehaviour: Codable {
    let paymentTypeRules: [String]?
    let paymentMethodRules: [String]?
    let sliderTitle: String?
    let behaviours: [PXPMBehaviour]?

    public enum CodingKeys: String, CodingKey {
        case paymentTypeRules = "payment_type_rules"
        case paymentMethodRules = "payment_method_rules"
        case sliderTitle = "slider_title"
        case behaviours
    }
 }

 public struct PXPMBehaviour: Codable {
    let type: String
    let modalContent: PXModalContent

    public enum CodingKeys: String, CodingKey {
        case type
        case modalContent = "modal_content"
    }
 }

 public struct PXModalContent: Codable {
    let title: PXText
    let description: PXText
    let button: PXModalButton
    let imageURL: String?

    public enum CodingKeys: String, CodingKey {
        case title
        case description
        case button
        case imageURL = "image_url"
    }
 }

 public struct PXModalButton: Codable {
    let label: String
    let target: String?

    public enum CodingKeys: String, CodingKey {
        case label
        case target
    }
 }
