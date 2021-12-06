import Foundation

struct PXOneTapHeaderMerchantLayout {
    enum LayoutType {
        case onlyTitle
        case titleSubtitle
    }

    private struct Constants {
        static let smallDeviceSize: CGFloat = 48
        static let regularDeviceSize: CGFloat = 48
        static let largeDeviceSize: CGFloat = 55
        static let extraLargeDeviceSize: CGFloat = 65
    }

    private let layoutType: LayoutType
    private var horizontalLayoutConstraints: [NSLayoutConstraint] = []
    private var verticalLayoutConstraints: [NSLayoutConstraint] = []

    private let showHorizontally: Bool

    let IMAGE_NAV_SIZE: CGFloat = 40
    var IMAGE_SIZE: CGFloat {
        if showHorizontally {
            return IMAGE_NAV_SIZE
        } else {
            // Define device size
            let deviceSize = PXDeviceSize.getDeviceSize(deviceHeight: UIScreen.main.bounds.height)

            switch deviceSize {
                case .small:
                    return Constants.smallDeviceSize
                case .regular:
                    return Constants.regularDeviceSize
                case .large:
                    return Constants.largeDeviceSize
                case .extraLarge:
                    return Constants.extraLargeDeviceSize
            }
        }
    }

    init(layoutType: PXOneTapHeaderMerchantLayout.LayoutType, showHorizontally: Bool = false) {
        self.layoutType = layoutType
        self.showHorizontally = showHorizontally
    }
}

// MARK: Publics
extension PXOneTapHeaderMerchantLayout {
    func getLayoutType() -> LayoutType {
        return layoutType
    }
}
