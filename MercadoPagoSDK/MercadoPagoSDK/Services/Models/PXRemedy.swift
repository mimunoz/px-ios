import Foundation

enum CardSize: String, Codable {
    case mini = "mini"
    case xSmall = "xsmall"
    case small = "small"
    case medium = "medium"
    case large = "large"
}

struct PXRemedy: Codable {
    let cvv: PXInvalidCVV?
    let highRisk: PXHighRisk?
    let callForAuth: PXCallForAuth?
    let suggestedPaymentMethod: PXSuggestedPaymentMethod?
    let trackingData: [String: String]?
    let displayInfo: PXRemedyDisplayInfo?
}

// PXRemedy Helpers
extension PXRemedy {
    init() {
        self.init(cvv: nil, highRisk: nil, callForAuth: nil, suggestedPaymentMethod: nil, trackingData: nil, displayInfo: nil)
    }

    var isEmpty: Bool {
        return cvv == nil && highRisk == nil && callForAuth == nil && suggestedPaymentMethod == nil
    }

    var shouldShowAnimatedButton: Bool {
        // These remedy types have its own animated button
        return cvv != nil || suggestedPaymentMethod != nil
    }

    var title: String? {
        // Get title for remedy
        if let title = suggestedPaymentMethod?.title {
            return title
        } else if let title = cvv?.title {
            return title
        } else if let title = highRisk?.title {
            return title
        }
        return nil
    }
}

struct PXInvalidCVV: Codable {
    let title: String?
    let message: String?
    let fieldSetting: PXFieldSetting?
}

struct PXHighRisk: Codable {
    let title: String?
    let message: String?
    let deepLink: String?
    let actionLoud: PXButtonAction?
}

struct PXCallForAuth: Codable {
    let title: String?
    let message: String?
}

struct PXFieldSetting: Codable {
    let name: String?
    let length: Int
    let title: String?
    let hintMessage: String?
}

struct PXButtonAction: Codable {
    let label: String?
}

struct PXSuggestedPaymentMethod: Codable {
    let title: String?
    let message: String?
    let actionLoud: PXButtonAction?
    let bottomMessage: PXRemedyBottomMessage?
    let alternativePaymentMethod: PXRemedyPaymentMethod?
    let modal: Modal?
}

struct PXRemedyPaymentMethod: Codable {
    let bin: String?
    let customOptionId: String?
    let paymentMethodId: String?
    let paymentTypeId: String?
    let escStatus: String
    let issuerName: String?
    let lastFourDigit: String?
    let securityCodeLocation: String?
    let securityCodeLength: Int?
    let installmentsList: [PXPaymentMethodInstallment]?
    let installment: PXPaymentMethodInstallment?
    let cardSize: CardSize?
}

struct PXPaymentMethodInstallment: Codable {
    let installments: Int
    let totalAmount: Double
}

struct PXRemedyBottomMessage: Codable {
    let message: String
    let backgroundColor: String
    let textColor: String
    let weight: String
}
