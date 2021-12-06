import XCTest
@testable import MercadoPagoSDKV4

class PXPaymentTypeChargeRuleBuilderTests: XCTestCase {
    func testFreeChargeRule() {
        var myCharge: PXPaymentTypeChargeRule?
        var err: Error?

        do {
            try myCharge = PXPaymentTypeChargeRuleBuilder(paymentTypeId: PXPaymentTypes.ACCOUNT_MONEY.rawValue, amount: 0.0)
                .build()
        } catch {
            err = error
        }

        guard let error = err else { return XCTFail() }

        XCTAssertEqual(error.localizedDescription, PXPaymentTypeChargeRuleBuilderError.invalidAmount.localizedDescription)

        XCTAssertNil(myCharge)
    }

    func testNonFreeChargeRule() {
        var myCharge: PXPaymentTypeChargeRule?
        var err: Error?

        do {
            try myCharge = PXPaymentTypeChargeRuleBuilder(paymentTypeId: PXPaymentTypes.ACCOUNT_MONEY.rawValue, amount: 1.0)
                .build()
        } catch {
            err = error
        }

        XCTAssertNil(err)

        XCTAssertEqual(myCharge?.paymentTypeId, PXPaymentTypes.ACCOUNT_MONEY.rawValue)
        XCTAssertEqual(myCharge?.amountCharge, 1.0)
        XCTAssertEqual(myCharge?.taxable, true)
    }

    func testChargeRuleWithLabel() {
        var myCharge: PXPaymentTypeChargeRule?
        var err: Error?

        do {
            try myCharge = PXPaymentTypeChargeRuleBuilder(paymentTypeId: PXPaymentTypes.ACCOUNT_MONEY.rawValue, amount: 1.0)
                .setLabel("Charge label")
                .build()
        } catch {
            err = error
        }

        XCTAssertNil(err)

        XCTAssertEqual(myCharge?.paymentTypeId, PXPaymentTypes.ACCOUNT_MONEY.rawValue)
        XCTAssertEqual(myCharge?.amountCharge, 1.0)
        XCTAssertEqual(myCharge?.taxable, true)
        XCTAssertEqual(myCharge?.label, "Charge label")
    }

    func testChargeRuleWithDetailModal() {
        var myCharge: PXPaymentTypeChargeRule?
        var err: Error?

        do {
            try myCharge = PXPaymentTypeChargeRuleBuilder(paymentTypeId: PXPaymentTypes.ACCOUNT_MONEY.rawValue, amount: 1.0)
                .setLabel("Charge label")
                .setDetailModal(UIViewController())
                .build()
        } catch {
            err = error
        }

        XCTAssertNil(err)

        XCTAssertEqual(myCharge?.paymentTypeId, PXPaymentTypes.ACCOUNT_MONEY.rawValue)
        XCTAssertEqual(myCharge?.amountCharge, 1.0)
        XCTAssertEqual(myCharge?.taxable, true)
        XCTAssertEqual(myCharge?.label, "Charge label")
        XCTAssertNotNil(myCharge?.detailModal)
    }

    func testChargeRuleWithTaxable() {
        var myCharge: PXPaymentTypeChargeRule?
        var err: Error?

        do {
            try myCharge = PXPaymentTypeChargeRuleBuilder(paymentTypeId: PXPaymentTypes.ACCOUNT_MONEY.rawValue, amount: 1.0)
                .setLabel("Charge label")
                .setDetailModal(UIViewController())
                .setTaxable(false)
                .build()
        } catch {
            err = error
        }

        XCTAssertNil(err)

        XCTAssertEqual(myCharge?.paymentTypeId, PXPaymentTypes.ACCOUNT_MONEY.rawValue)
        XCTAssertEqual(myCharge?.amountCharge, 1.0)
        XCTAssertEqual(myCharge?.taxable, false)
        XCTAssertEqual(myCharge?.label, "Charge label")
        XCTAssertNotNil(myCharge?.detailModal)
    }
}
