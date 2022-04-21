import XCTest

@testable import MercadoPagoSDKV4

final class PXPaymentMethodSelectorTest: XCTestCase {
    func testBuilderWithoutAccessToken() throws {
        let builder = PXPaymentMethodSelector.Builder(publicKey: "public-key", preferenceId: "pref-id")

        var pxPMSelector: PXPaymentMethodSelector?

        XCTAssertThrowsError(try pxPMSelector = builder.build()) { error in
            guard let error = error as? PXPaymentMethodSelectorError else {
                return XCTFail("Error type missmatch")
            }

            XCTAssertEqual( error, PXPaymentMethodSelectorError.missingAccessToken)
        }

        XCTAssertNil(pxPMSelector)
    }

    func testBuilder() throws {
        let builder = PXPaymentMethodSelector.Builder(publicKey: "public-key", preferenceId: "pref-id")

        builder.setAccessToken(accessToken: "access-token")

        var pxPMSelector: PXPaymentMethodSelector?

        XCTAssertNoThrow(try pxPMSelector = builder.build())

        XCTAssertNotNil(pxPMSelector)
    }
}
