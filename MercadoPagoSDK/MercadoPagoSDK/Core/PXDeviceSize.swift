import UIKit

public class PXDeviceSize {
    // Breakpoints took from https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/adaptivity-and-layout/

    static let smallBreakpoint: CGFloat = 568
    static let regularBreakpoint: CGFloat = 736
    static let largeBreakpoint: CGFloat = 812
    static let extraLargeBreakpoint: CGFloat = 926

    enum Sizes {
        case small
        case regular
        case large
        case extraLarge
    }

    static func getDeviceSize(deviceHeight: CGFloat) -> Sizes {
        if deviceHeight <= smallBreakpoint {
            return .small
        } else if deviceHeight <= regularBreakpoint {
            return .regular
        } else if deviceHeight <= largeBreakpoint {
            return .large
        } else {
            return .extraLarge
        }
    }
}
