
import XCTest
@testable import MercadoPagoSDKV4

class PXDeviceSizeTests: XCTestCase {
    let iPhone12ProMax: CGFloat = 926
    let iPhone12Pro: CGFloat = 844
    let iPhone12: CGFloat = 844
    let iPhone12mini: CGFloat = 812
    let iPhone11ProMax: CGFloat = 896
    let iPhone11Pro: CGFloat = 812
    let iPhone11: CGFloat = 896
    let iPhoneXSMax: CGFloat = 896
    let iPhoneXS: CGFloat = 812
    let iPhoneXR: CGFloat = 896
    let iPhoneX: CGFloat = 812
    let iPhone8Plus: CGFloat = 736
    let iPhone8: CGFloat = 667
    let iPhone7Plus: CGFloat = 736
    let iPhone7: CGFloat = 667
    let iPhone6sPlus: CGFloat = 736
    let iPhone6s: CGFloat = 667
    let iPhone6Plus: CGFloat = 736
    let iPhone6: CGFloat = 667
    let iPhoneSE2: CGFloat = 667
    let iPhoneSE1: CGFloat = 568

    func testiPhoneSE1stGen () {
        let deviceSize = PXDeviceSize.getDeviceSize(deviceHeight: iPhoneSE1)

        XCTAssertEqual(deviceSize, PXDeviceSize.Sizes.small)
    }

    func testiPhoneSE2stGen () {
        let deviceSize = PXDeviceSize.getDeviceSize(deviceHeight: iPhoneSE2)

        XCTAssertEqual(deviceSize, PXDeviceSize.Sizes.regular)
    }

    func testiPhone7 () {
        let deviceSize = PXDeviceSize.getDeviceSize(deviceHeight: iPhone7)

        XCTAssertEqual(deviceSize, PXDeviceSize.Sizes.regular)
    }

    func testiPhone8Plus () {
        let deviceSize = PXDeviceSize.getDeviceSize(deviceHeight: iPhone8Plus)

        XCTAssertEqual(deviceSize, PXDeviceSize.Sizes.regular)
    }

    func testiPhoneX () {
        let deviceSize = PXDeviceSize.getDeviceSize(deviceHeight: iPhoneX)

        XCTAssertEqual(deviceSize, PXDeviceSize.Sizes.large)
    }

    func testiPhoneXR () {
        let deviceSize = PXDeviceSize.getDeviceSize(deviceHeight: iPhoneXR)

        XCTAssertEqual(deviceSize, PXDeviceSize.Sizes.extraLarge)
    }

    func testiPhone12ProMax () {
        let deviceSize = PXDeviceSize.getDeviceSize(deviceHeight: iPhone12ProMax)

        XCTAssertEqual(deviceSize, PXDeviceSize.Sizes.extraLarge)
    }
}
