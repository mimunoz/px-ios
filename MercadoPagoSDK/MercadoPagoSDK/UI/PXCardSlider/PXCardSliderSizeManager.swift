import UIKit
import MLCardDrawer

struct PXCardSliderSizeManager {
    static let goldenRatio: CGFloat = 1 / 1.586
    static let interItemSpace: CGFloat = 16
    static let cardDeltaDecrease: CGFloat = 60

    // Card type ratios
    static let largeRatio: CGFloat = 0.61
    static let mediumRatio: CGFloat = 0.492
    static let smallRatio: CGFloat = 0.328
    static let xSmallRatio: CGFloat = 0.265
    static let miniRatio: CGFloat = 0.14

    static func aspectRatio(forType type: MLCardDrawerTypeV3) -> CGFloat {
        switch type {
        case .large:
         return largeRatio
        case .medium:
         return mediumRatio
        case .small:
         return smallRatio
        case .xSmall:
         return xSmallRatio
        case .mini:
         return miniRatio
        }
    }

    static func getCGSizeWithAspectRatioFor(_ width: CGFloat, _ type: MLCardDrawerTypeV3 = .large) -> CGSize {
        return CGSize(width: width, height: width * aspectRatio(forType: type))
    }

    static func getHeaderViewHeight(viewController: UIViewController) -> CGFloat {
        if UIDevice.isSmallDevice() {
            return PXLayout.getAvailabelScreenHeight(in: viewController, applyingMarginFactor: 38)
        } else if UIDevice.isLargeOrExtraLargeDevice() {
            return PXLayout.getAvailabelScreenHeight(in: viewController, applyingMarginFactor: 46)
        } else {
            return PXLayout.getAvailabelScreenHeight(in: viewController, applyingMarginFactor: 40)
        }
    }

    static func getWhiteViewHeight(viewController: UIViewController) -> CGFloat {
        if UIDevice.isSmallDevice() {
            return PXLayout.getAvailabelScreenHeight(in: viewController, applyingMarginFactor: 62)
        } else if UIDevice.isLargeOrExtraLargeDevice() {
            return PXLayout.getAvailabelScreenHeight(in: viewController, applyingMarginFactor: 54)
        } else {
            return PXLayout.getAvailabelScreenHeight(in: viewController, applyingMarginFactor: 60)
        }
    }

    static func getCardTypeForContext(deviceSize: PXDeviceSize.Sizes, hasCharges: Bool, hasDiscounts: Bool, hasInstallments: Bool, hasSplit: Bool) -> MLCardDrawerTypeV3 {
        switch deviceSize {
        case .small:
            if hasInstallments || hasSplit {
                // On small devices, if it has installments or split, return medium size card
                return .small
            } else {
                // On small devices if there is no installments or split return large size card
                return .large
            }
        case .regular:
            // On regular devices, if it has installments, return medium size card
            if hasInstallments {
                if !hasCharges, !hasDiscounts, !hasSplit {
                    return .large
                } else {
                    return .small
                }
            } else {
                return .large
            }
        case .large, .extraLarge:
            // On large or extra-large devices always return large size card
            return .large
        default:
            return .large
        }
    }
}
