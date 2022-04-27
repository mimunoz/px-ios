import XCTest
@testable import MercadoPagoSDKV4

final class CustomServiceMock: CustomService {
    var successResponse = true
    var calledGetPointsAndDiscounts = false
    var calledResetESCCap = false
    var calledCreatePayment = false

    func getPointsAndDiscounts(data: Data?, parameters: CustomParametersModel, headers: [String: String]?, response: @escaping (Swift.Result<PXPointsAndDiscounts, Error>) -> Void) {
        calledGetPointsAndDiscounts = true
        successResponse ? response(.success(PXPointsAndDiscounts(points: nil,
                                                                 discounts: nil,
                                                                 crossSelling: nil,
                                                                 viewReceiptAction: nil,
                                                                 topTextBox: nil,
                                                                 customOrder: nil,
                                                                 expenseSplit: nil,
                                                                 paymentMethodsImages: nil,
                                                                 primaryButton: nil,
                                                                 secondaryButton: nil,
                                                                 redirectUrl: nil,
                                                                 backUrl: nil,
                                                                 autoReturn: nil,
                                                                 instruction: nil,
                                                                 infoOperation: nil))) : response(.failure(NSError()))
    }

    func resetESCCap(cardId: String, privateKey: String?, headers: [String: String]?, response: @escaping (Swift.Result<Void, PXError>) -> Void) {
        calledResetESCCap = true
        successResponse ? response(.success(())) : response(.failure(PXError(domain: "", code: 0)))
    }

    func createPayment(privateKey: String?, publicKey: String, data: Data?, headers: [String: String]?, response: @escaping (Swift.Result<PXPayment, PXError>) -> Void) {
        calledCreatePayment = true
        successResponse ? response(.success(PXPayment(id: 0, status: ""))) : response(.failure(PXError(domain: "", code: 0)))
    }
}

final class RemedyServicesMock: RemedyService {
    var successResponse = true
    var calledGetRemedy = false

    func getRemedy(paymentMethodId: String, privateKey: String?, oneTap: Bool, remedy: PXRemedyBody, completion: @escaping (Swift.Result<PXRemedy, PXError>) -> Void) {
        calledGetRemedy = true
        successResponse ? completion(.success(PXRemedy())) : completion(.failure( PXError(domain: "", code: 0)))
    }
}

final class GatewayServicesMock: TokenService {
    var successResponse = true
    var calledGetToken = false
    var calledCloneToken = false
    var calledValidateToken = false

    func getToken(accessToken: String?, publicKey: String, cardTokenJSON: Data?, completion: @escaping (Swift.Result<PXToken, PXError>) -> Void) {
        calledGetToken = true
        successResponse ? completion(.success(PXToken(id: "", publicKey: nil, cardId: "", luhnValidation: nil, status: nil, usedDate: nil, cardNumberLength: 0, dateCreated: nil, securityCodeLength: 0, expirationMonth: 0, expirationYear: 0, dateLastUpdated: nil, dueDate: nil, firstSixDigits: "", lastFourDigits: "", cardholder: nil, esc: nil))) : completion(.failure(PXError(domain: "", code: 0)))
    }

    func cloneToken(tokenId: String, publicKey: String, securityCode: String, completion: @escaping (Swift.Result<PXToken, PXError>) -> Void) {
        calledCloneToken = true
        successResponse ? completion(.success(PXToken(id: "", publicKey: nil, cardId: "", luhnValidation: nil, status: nil, usedDate: nil, cardNumberLength: 0, dateCreated: nil, securityCodeLength: 0, expirationMonth: 0, expirationYear: 0, dateLastUpdated: nil, dueDate: nil, firstSixDigits: "", lastFourDigits: "", cardholder: nil, esc: nil))) : completion(.failure(PXError(domain: "", code: 0)))
    }

    func validateToken(tokenId: String, publicKey: String, body: Data, completion: @escaping (Swift.Result<PXToken, PXError>) -> Void) {
        calledValidateToken = true
        successResponse ? completion(.success(PXToken(id: "", publicKey: nil, cardId: "", luhnValidation: nil, status: nil, usedDate: nil, cardNumberLength: 0, dateCreated: nil, securityCodeLength: 0, expirationMonth: 0, expirationYear: 0, dateLastUpdated: nil, dueDate: nil, firstSixDigits: "", lastFourDigits: "", cardholder: nil, esc: nil))) : completion(.failure(PXError(domain: "", code: 0)))
    }
}

final class CheckoutServicesMock: CheckoutService {
    var successResponse = true
    var calledGetInit = false

    func getInit(preferenceId: String?, privateKey: String?, body: Data?, headers: [String: String]?, completion: @escaping (Swift.Result<PXInitDTO, PXError>) -> Void) {
        calledGetInit = true
        successResponse ? completion(.success(PXInitDTO(preference: nil, oneTap: nil, currency: PXCurrency(id: "", description: nil, symbol: nil, decimalPlaces: nil, decimalSeparator: nil, thousandSeparator: nil), site: PXSite(id: "", currencyId: nil, termsAndConditionsUrl: "", shouldWarnAboutBankInterests: nil), generalCoupon: "", coupons: [:], payerPaymentMethods: [], availablePaymentMethods: [], experiments: nil, payerCompliance: nil, configurations: nil, modals: [:], customCharges: nil))) : completion(.failure(PXError(domain: "", code: 0)))
    }
}

final class MercadoPagoServicesTest: XCTestCase {
    var sut: MercadoPagoServices!

    var customService: CustomServiceMock!
    var remedyService: RemedyServicesMock!
    var gatewayService: GatewayServicesMock!
    var checkoutService: CheckoutServicesMock!

    override func setUp() {
        super.setUp()
        customService = CustomServiceMock()
        remedyService = RemedyServicesMock()
        gatewayService = GatewayServicesMock()
        checkoutService = CheckoutServicesMock()
        sut = MercadoPagoServices(publicKey: "Test",
                                  privateKey: "Tests",
                                  customService: customService,
                                  remedyService: remedyService,
                                  gatewayService: gatewayService,
                                  checkoutService: checkoutService,
                                  checkoutType: nil)
    }

    // Has same behavior on success and failure
    func testResetESCCap() {
        var hadCallback = false
        XCTAssertTrue(customService.calledResetESCCap == false)
        sut.resetESCCap(cardId: "", headers: [:]) {
            hadCallback = true
        }

        XCTAssertTrue(hadCallback == true)
        XCTAssertTrue(customService.calledResetESCCap == true)
    }

    func testCreatePaymentSuccess() {
        var hasError = true
        XCTAssertTrue(customService.calledCreatePayment == false)
        sut.createPayment(url: "", uri: "", transactionId: "", paymentDataJSON: Data(), query: nil, headers: nil) { _ in
            hasError = false
        } failure: {  _ in
            hasError = true
        }

        XCTAssertTrue(customService.calledCreatePayment == true)
        XCTAssertTrue(hasError == false)
    }

    func testCreatePaymentFailure() {
        customService.successResponse = false
        var hasError = false
        XCTAssertTrue(customService.calledCreatePayment == false)
        sut.createPayment(url: "", uri: "", transactionId: "", paymentDataJSON: Data(), query: nil, headers: nil) { _ in
            hasError = false
        } failure: {  _ in
            hasError = true
        }

        XCTAssertTrue(customService.calledCreatePayment == true)
        XCTAssertTrue(hasError == true)
    }

    func testGetPointsAndDiscountsSuccess() {
        var hasError = true
        XCTAssertTrue(customService.calledGetPointsAndDiscounts == false)
        sut.getPointsAndDiscounts(url: "", uri: "", paymentIds: nil, paymentMethodsIds: nil, campaignId: nil, prefId: nil, platform: "", ifpe: true, merchantOrderId: 0, headers: [:], paymentTypeId: nil) { _ in
            hasError = false
        } failure: {
            hasError = true
        }

        XCTAssertTrue(customService.calledGetPointsAndDiscounts == true)
        XCTAssertTrue(hasError == false)
    }

    func testGetPointsAndDiscountsFailure() {
        customService.successResponse = false
        var hasError = false
        XCTAssertTrue(customService.calledGetPointsAndDiscounts == false)
        sut.getPointsAndDiscounts(url: "", uri: "", paymentIds: nil, paymentMethodsIds: nil, campaignId: nil, prefId: nil, platform: "", ifpe: true, merchantOrderId: 0, headers: [:], paymentTypeId: nil) { _ in
            hasError = false
        } failure: {
            hasError = true
        }

        XCTAssertTrue(customService.calledGetPointsAndDiscounts == true)
        XCTAssertTrue(hasError == true)
    }

    func testGetRemedySuccess() {
        var hasError = true
        XCTAssertTrue(remedyService.calledGetRemedy == false)
        sut.getRemedy(for: "", payerPaymentMethodRejected: PXPayerPaymentMethodRejected(bin: nil, customOptionId: nil, paymentMethodId: nil, paymentTypeId: nil, issuerName: nil, lastFourDigit: nil, securityCodeLocation: nil, securityCodeLength: nil, totalAmount: nil, installments: nil, escStatus: nil, paymentMethodName: nil, bankInfo: nil), alternativePayerPaymentMethods: nil, customStringConfiguration: nil, oneTap: true) { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }

        XCTAssertTrue(remedyService.calledGetRemedy == true)
        XCTAssertTrue(hasError == false)
    }

    func testGetRemedyFailure() {
        remedyService.successResponse = false
        var hasError = false
        XCTAssertTrue(remedyService.calledGetRemedy == false)
        sut.getRemedy(for: "", payerPaymentMethodRejected: PXPayerPaymentMethodRejected(bin: nil, customOptionId: nil, paymentMethodId: nil, paymentTypeId: nil, issuerName: nil, lastFourDigit: nil, securityCodeLocation: nil, securityCodeLength: nil, totalAmount: nil, installments: nil, escStatus: nil, paymentMethodName: nil, bankInfo: nil), alternativePayerPaymentMethods: nil, customStringConfiguration: nil, oneTap: true) { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }

        XCTAssertTrue(remedyService.calledGetRemedy == true)
        XCTAssertTrue(hasError == true)
    }

    func testCreateTokenSuccess() {
        var hasError = true
        XCTAssertTrue(gatewayService.calledGetToken == false)
        sut.createToken(cardToken: PXCardToken(cardNumber: nil, expirationMonth: 0, expirationYear: 0, securityCode: nil, cardholderName: "", docType: "", docNumber: "")) { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }

        XCTAssertTrue(gatewayService.calledGetToken == true)
        XCTAssertTrue(hasError == false)
    }

    func testCreateTokenFailure() {
        gatewayService.successResponse = false
        var hasError = false
        XCTAssertTrue(gatewayService.calledGetToken == false)
        sut.createToken(cardToken: PXCardToken(cardNumber: nil, expirationMonth: 0, expirationYear: 0, securityCode: nil, cardholderName: "", docType: "", docNumber: "")) { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }

        XCTAssertTrue(gatewayService.calledGetToken == true)
        XCTAssertTrue(hasError == true)
    }

    func testCloneTokenSuccess() {
        var hasError = true
        XCTAssertTrue(gatewayService.calledCloneToken == false)
        sut.cloneToken(tokenId: "", securityCode: "") { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }

        XCTAssertTrue(gatewayService.calledCloneToken == true)
        XCTAssertTrue(hasError == false)
    }

    func testCloneTokenFailure() {
        gatewayService.successResponse = false
        var hasError = true
        XCTAssertTrue(gatewayService.calledCloneToken == false)
        sut.cloneToken(tokenId: "", securityCode: "") { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }

        XCTAssertTrue(gatewayService.calledCloneToken == true)
        XCTAssertTrue(hasError == true)
    }

    func testGetOpenPrefInitSearchSuccess() {
        var hasError = true
        XCTAssertTrue(checkoutService.calledGetInit == false)
        sut.getOpenPrefInitSearch(pref: PXCheckoutPreference(preferenceId: ""), cardsWithEsc: [], oneTapEnabled: true, splitEnabled: true, discountParamsConfiguration: nil, flow: nil, charges: [], paymentMethodRuleSet: [], headers: nil, newCardId: nil) { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }

        XCTAssertTrue(checkoutService.calledGetInit == true)
        XCTAssertTrue(hasError == false)
    }

    func testGetOpenPrefInitSearchFailure() {checkoutService.successResponse = false
        var hasError = true
        XCTAssertTrue(checkoutService.calledGetInit == false)
        sut.getOpenPrefInitSearch(pref: PXCheckoutPreference(preferenceId: ""), cardsWithEsc: [], oneTapEnabled: true, splitEnabled: true, discountParamsConfiguration: nil, flow: nil, charges: [], paymentMethodRuleSet: [], headers: nil, newCardId: nil) { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }

        XCTAssertTrue(checkoutService.calledGetInit == true)
        XCTAssertTrue(hasError == true)
    }

    func testGetClosedPrefInitSearchSuccess() {
        var hasError = true
        XCTAssertTrue(checkoutService.calledGetInit == false)
        sut.getClosedPrefInitSearch(preferenceId: "", cardsWithEsc: [], oneTapEnabled: true, splitEnabled: true, discountParamsConfiguration: nil, flow: nil, charges: [], paymentMethodRuleSet: [], headers: nil, newCardId: nil) { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }

        XCTAssertTrue(checkoutService.calledGetInit == true)
        XCTAssertTrue(hasError == false)
    }

    func testGetClosedPrefInitSearchFailure() {
        checkoutService.successResponse = false
        var hasError = true
        XCTAssertTrue(checkoutService.calledGetInit == false)
        sut.getClosedPrefInitSearch(preferenceId: "", cardsWithEsc: [], oneTapEnabled: true, splitEnabled: true, discountParamsConfiguration: nil, flow: nil, charges: [], paymentMethodRuleSet: [], headers: nil, newCardId: nil) { _ in
            hasError = false
        } failure: { _ in
            hasError = true
        }

        XCTAssertTrue(checkoutService.calledGetInit == true)
        XCTAssertTrue(hasError == true)
    }
}
