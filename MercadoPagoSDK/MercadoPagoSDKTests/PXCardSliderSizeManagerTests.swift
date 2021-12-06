import XCTest
@testable import MercadoPagoSDKV4
@testable import MLCardDrawer

class PXCardSliderSizeManagerTests: XCTestCase {
    // Small devices
    func testGetCardTypeForSmallWithEverything () {
        let cardType = PXCardSliderSizeManager.getCardTypeForContext(deviceSize: PXDeviceSize.Sizes.small, hasCharges: true, hasDiscounts: true, hasInstallments: true, hasSplit: true)

        XCTAssertEqual(cardType, MLCardDrawerTypeV3.small)
    }

    func testGetCardTypeForSmallWithNothing () {
        let cardType = PXCardSliderSizeManager.getCardTypeForContext(deviceSize: PXDeviceSize.Sizes.small, hasCharges: false, hasDiscounts: false, hasInstallments: false, hasSplit: false)

        XCTAssertEqual(cardType, MLCardDrawerTypeV3.large)
    }

    // Regular devices
    func testGetCardTypeForRegularWithEverything () {
        let cardType = PXCardSliderSizeManager.getCardTypeForContext(deviceSize: PXDeviceSize.Sizes.regular, hasCharges: true, hasDiscounts: true, hasInstallments: true, hasSplit: true)

        XCTAssertEqual(cardType, MLCardDrawerTypeV3.small)
    }

    func testGetCardTypeForRegularWithInstallmentsOnly () {
        let cardType = PXCardSliderSizeManager.getCardTypeForContext(deviceSize: PXDeviceSize.Sizes.regular, hasCharges: false, hasDiscounts: false, hasInstallments: true, hasSplit: false)

        XCTAssertEqual(cardType, MLCardDrawerTypeV3.large)
    }

    func testGetCardTypeForRegularWithChargesAndDiscountsOnly () {
        let cardType = PXCardSliderSizeManager.getCardTypeForContext(deviceSize: PXDeviceSize.Sizes.regular, hasCharges: true, hasDiscounts: true, hasInstallments: false, hasSplit: false)

        XCTAssertEqual(cardType, MLCardDrawerTypeV3.large)
    }

    func testGetCardTypeForRegularWithNothing () {
        let cardType = PXCardSliderSizeManager.getCardTypeForContext(deviceSize: PXDeviceSize.Sizes.regular, hasCharges: false, hasDiscounts: false, hasInstallments: false, hasSplit: false)

        XCTAssertEqual(cardType, MLCardDrawerTypeV3.large)
    }

    // Large devices
    func testGetCardTypeForLargeWithEverything () {
        let cardType = PXCardSliderSizeManager.getCardTypeForContext(deviceSize: PXDeviceSize.Sizes.large, hasCharges: true, hasDiscounts: true, hasInstallments: true, hasSplit: true)

        XCTAssertEqual(cardType, MLCardDrawerTypeV3.large)
    }

    func testGetCardTypeForLargeWithInstallmentsOnly () {
        let cardType = PXCardSliderSizeManager.getCardTypeForContext(deviceSize: PXDeviceSize.Sizes.large, hasCharges: false, hasDiscounts: false, hasInstallments: true, hasSplit: false)

        XCTAssertEqual(cardType, MLCardDrawerTypeV3.large)
    }

    func testGetCardTypeForLargeWithChargesAndDiscountsOnly () {
        let cardType = PXCardSliderSizeManager.getCardTypeForContext(deviceSize: PXDeviceSize.Sizes.large, hasCharges: true, hasDiscounts: true, hasInstallments: false, hasSplit: false)

        XCTAssertEqual(cardType, MLCardDrawerTypeV3.large)
    }

    func testGetCardTypeForLargeWithNothing () {
        let cardType = PXCardSliderSizeManager.getCardTypeForContext(deviceSize: PXDeviceSize.Sizes.large, hasCharges: false, hasDiscounts: false, hasInstallments: false, hasSplit: false)

        XCTAssertEqual(cardType, MLCardDrawerTypeV3.large)
    }

    // Extra large devices
    func testGetCardTypeForExtraLargeWithEverything () {
        let cardType = PXCardSliderSizeManager.getCardTypeForContext(deviceSize: PXDeviceSize.Sizes.extraLarge, hasCharges: true, hasDiscounts: true, hasInstallments: true, hasSplit: true)

        XCTAssertEqual(cardType, MLCardDrawerTypeV3.large)
    }

    func testGetCardTypeForExtraLargeWithInstallmentsOnly () {
        let cardType = PXCardSliderSizeManager.getCardTypeForContext(deviceSize: PXDeviceSize.Sizes.extraLarge, hasCharges: false, hasDiscounts: false, hasInstallments: true, hasSplit: false)

        XCTAssertEqual(cardType, MLCardDrawerTypeV3.large)
    }

    func testGetCardTypeForExtraLargeWithChargesAndDiscountsOnly () {
        let cardType = PXCardSliderSizeManager.getCardTypeForContext(deviceSize: PXDeviceSize.Sizes.extraLarge, hasCharges: true, hasDiscounts: true, hasInstallments: false, hasSplit: false)

        XCTAssertEqual(cardType, MLCardDrawerTypeV3.large)
    }

    func testGetCardTypeForExtraLargeWithNothing () {
        let cardType = PXCardSliderSizeManager.getCardTypeForContext(deviceSize: PXDeviceSize.Sizes.extraLarge, hasCharges: false, hasDiscounts: false, hasInstallments: false, hasSplit: false)

        XCTAssertEqual(cardType, MLCardDrawerTypeV3.large)
    }
}
