import XCTest
@testable import MercadoPagoSDKV4

final class PXCheckoutTypeTests: XCTestCase {
    let checkoutPreference = PXCheckoutPreference(siteId: "MLA", payerEmail: "1234@gmail.com", items: [PXItem(title: "Taza de té", quantity: 1, unitPrice: 15.0)])

    func testCustomPaymentProcessor() {
        // Create an instance of your custom payment processor
        let customProcessor: PXPaymentProcessor = CustomPaymentProcessorTestImpl()

        // Create a payment configuration instance using the recently created payment processor
        let configuration = PXPaymentConfiguration(paymentProcessor: customProcessor)

        let builder = MercadoPagoCheckoutBuilder.init(publicKey: "XXX", checkoutPreference: checkoutPreference, paymentConfiguration: configuration)

        XCTAssertEqual(builder.paymentConfig?.getProcessorType(), PXCheckoutType.CUSTOM_REGULAR.getString())
    }

    func testScheduledPaymentProcessor() {
        // Create an instance of your custom payment processor
        let customProcessor: PXPaymentProcessor = ScheduledPaymentProcessorTestImpl()

        // Create a payment configuration instance using the recently created payment processor
        let configuration = PXPaymentConfiguration(scheduledPaymentProcessor: customProcessor)

        let builder = MercadoPagoCheckoutBuilder.init(publicKey: "XXX", checkoutPreference: checkoutPreference, paymentConfiguration: configuration)

        XCTAssertEqual(builder.paymentConfig?.getProcessorType(), PXCheckoutType.CUSTOM_SCHEDULED.getString())
    }

    func testSplitPaymentProcessor() {
        // Create an instance of your custom payment processor
        let customProcessor: PXSplitPaymentProcessor = SplitPaymentProcessorTestImpl()

        // Create a payment configuration instance using the recently created payment processor
        let configuration = PXPaymentConfiguration(splitPaymentProcessor: customProcessor)

        let builder = MercadoPagoCheckoutBuilder.init(publicKey: "XXX", checkoutPreference: checkoutPreference, paymentConfiguration: configuration)

        XCTAssertEqual(builder.paymentConfig?.getProcessorType(), PXCheckoutType.CUSTOM_REGULAR.getString())
    }

    func testDefaultProcessor() {
        // Create an instance of your custom payment processor
        let customProcessor: PXSplitPaymentProcessor = SplitPaymentProcessorTestImpl()

        // Create a payment configuration instance using the recently created payment processor
        let configuration = PXPaymentConfiguration(splitPaymentProcessor: customProcessor)

        let builder = MercadoPagoCheckoutBuilder.init(publicKey: "XXX", preferenceId: "XXX")

        XCTAssertNil(builder.paymentConfig)

        let services = MercadoPagoServices.init(publicKey: "XXX", privateKey: "XXX", customService: CustomServiceImpl(), remedyService: RemedyServiceImpl(), gatewayService: TokenServiceImpl(), checkoutService: CheckoutServiceImpl(), checkoutType: nil)

        XCTAssertEqual(services.checkoutType, PXCheckoutType.DEFAULT_REGULAR.getString())
    }
}

final class CustomPaymentProcessorTestImpl: NSObject, PXPaymentProcessor {
    var checkoutStore: PXCheckoutStore?

    func startPayment(checkoutStore: PXCheckoutStore, errorHandler: PXPaymentProcessorErrorHandler, successWithBusinessResult: @escaping ((PXBusinessResult) -> Void), successWithPaymentResult: @escaping ((PXGenericPayment) -> Void)) {
        print("Start payment")

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
             successWithPaymentResult(PXGenericPayment(paymentStatus: .APPROVED, statusDetail: "Pago aprobado desde procesadora custom!"))
        })
    }

    func paymentProcessorViewController() -> UIViewController? {
        return nil
    }

    func support() -> Bool {
        return true
    }

    func didReceive(checkoutStore: PXCheckoutStore) {
        print("Receiving checkout store")
        self.checkoutStore = checkoutStore
    }

    func didReceive(navigationHandler: PXPaymentProcessorNavigationHandler) {
        print("Receiving navigation Handler")
    }
}

final class ScheduledPaymentProcessorTestImpl: NSObject, PXPaymentProcessor {
    public func startPayment(checkoutStore: PXCheckoutStore, errorHandler: PXPaymentProcessorErrorHandler, successWithBusinessResult: @escaping ((PXBusinessResult) -> Void), successWithPaymentResult: @escaping  ((PXGenericPayment) -> Void)) {
        print("Start payment")

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            successWithPaymentResult(PXGenericPayment(paymentStatus: .APPROVED, statusDetail: "Pago aprobado desde procesadora custom!"))
        })
    }

    public func paymentProcessorViewController() -> UIViewController? {
        return nil
    }

    public func support() -> Bool {
        return true
    }

    public func supportSplitPaymentMethodPayment(checkoutStore: PXCheckoutStore) -> Bool {
        return false
    }
}

final class SplitPaymentProcessorTestImpl: NSObject, PXSplitPaymentProcessor {
    public func startPayment(checkoutStore: PXCheckoutStore, errorHandler: PXPaymentProcessorErrorHandler, successWithBusinessResult: @escaping ((PXBusinessResult) -> Void), successWithPaymentResult: @escaping  ((PXGenericPayment) -> Void)) {
        print("Start payment")

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            successWithPaymentResult(PXGenericPayment(paymentStatus: .APPROVED, statusDetail: "Pago aprobado desde procesadora custom!"))
        })
    }

    public func paymentProcessorViewController() -> UIViewController? {
        return nil
    }

    public func support() -> Bool {
        return true
    }

    public func supportSplitPaymentMethodPayment(checkoutStore: PXCheckoutStore) -> Bool {
        return true
    }
}
