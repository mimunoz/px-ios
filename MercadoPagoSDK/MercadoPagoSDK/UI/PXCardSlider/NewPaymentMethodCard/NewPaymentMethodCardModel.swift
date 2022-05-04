import Foundation

struct NewPaymentMethodCardModel {
    let title: PXText?
    let subtitle: PXText?
    let defaultIcon: UIImage?
    let iconUrl: String?
    let border: PXOneTapNewCardBorderDto?
    let shadow: Bool
    let backgroundColor: String?
}
