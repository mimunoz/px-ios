import UIKit

final class PXHeaderView: PXComponentView {
    weak var delegate: PXHeaderTrackingProtocol?
    var circleImage: PXUIImageView?
    var badgeImage: PXAnimatedImageView?
    var statusLabel: UILabel?
    var messageLabel: UILabel?
    var closeButton: UIButton?
}
