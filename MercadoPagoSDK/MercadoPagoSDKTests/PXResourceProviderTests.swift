import XCTest

@testable import MercadoPagoSDKV4

final class PXResourceProviderTest: XCTestCase {
    override func setUp() {
        super.setUp()

        // Set up SiteManager
        Localizator.sharedInstance.setLanguage(language: .SPANISH)
        SiteManager.shared.setSite(site: PXSite(id: "MLA", currencyId: "ARS", termsAndConditionsUrl: "", shouldWarnAboutBankInterests: false))
        SiteManager.shared.setCurrency(currency: PXCurrency(id: "ARS", description: "", symbol: "$", decimalPlaces: 2, decimalSeparator: ".", thousandSeparator: ","))
    }

    func testGetDescriptionForErrorBodyForREJECTED_CALL_FOR_AUTHORIZE() throws {
        let text = PXResourceProvider.getDescriptionForErrorBodyForREJECTED_CALL_FOR_AUTHORIZE(15.0)

        XCTAssertEqual("1- Llama al teléfono que está al reverso de tu tarjeta para autorizar el pago de $ 15 a Mercado Pago.", text)
    }

    func testGetDescriptionForErrorBodyForREJECTED_CARD_DISABLED() throws {
        let text = PXResourceProvider.getDescriptionForErrorBodyForREJECTED_CARD_DISABLED("VISA")

        XCTAssertEqual("Llama a VISA para activar tu tarjeta o usa otro medio de pago.", text)
    }

    func testGetDescriptionForErrorBodyForREJECTED_INSUFFICIENT_AMOUNT() throws {
        let text = PXResourceProvider.getDescriptionForErrorBodyForREJECTED_INSUFFICIENT_AMOUNT()

        XCTAssertEqual("Tus fondos son insuficientes o superaste el límite de compra.", text)
    }

    func testGetDescriptionForErrorBodyForREJECTED_OTHER_REASON() throws {
        let text = PXResourceProvider.getDescriptionForErrorBodyForREJECTED_OTHER_REASON()

        XCTAssertEqual("Lo sentimos, algo salió mal. Por favor, inténtalo de nuevo con otro medio de pago.", text)
    }

    func testGetDescriptionForErrorBodyForREJECTED_BY_BANK() throws {
        let text = PXResourceProvider.getDescriptionForErrorBodyForREJECTED_BY_BANK()

        XCTAssertEqual("Por favor, intente pagar de otra forma.", text)
    }

    func testGetDescriptionForErrorBodyForREJECTED_INSUFFICIENT_DATA() throws {
        let text = PXResourceProvider.getDescriptionForErrorBodyForREJECTED_INSUFFICIENT_DATA()

        XCTAssertEqual("Por favor, intente pagar de otra forma.", text)
    }

    func testGetDescriptionForErrorBodyForREJECTED_DUPLICATED_PAYMENT() throws {
        let text = PXResourceProvider.getDescriptionForErrorBodyForREJECTED_DUPLICATED_PAYMENT()

        XCTAssertEqual("No te preocupes, tu pago anterior se efectuó con éxito.", text)
    }

    func testGetDescriptionForErrorBodyForREJECTED_MAX_ATTEMPTS() throws {
        let text = PXResourceProvider.getDescriptionForErrorBodyForREJECTED_MAX_ATTEMPTS()

        XCTAssertEqual("Como llegaste al límite de intentos con esta tarjeta, usa otro medio de pago.", text)
    }

    func testGetDescriptionForErrorBodyForREJECTED_HIGH_RISK() throws {
        let text = PXResourceProvider.getDescriptionForErrorBodyForREJECTED_HIGH_RISK()

        XCTAssertEqual("Lo sentimos, la operación no pasó nuestra validación de seguridad.", text)
    }

    func testGetDescriptionForErrorBodyForREJECTED_CARD_HIGH_RISK() throws {
        let text = PXResourceProvider.getDescriptionForErrorBodyForREJECTED_CARD_HIGH_RISK()

        XCTAssertEqual("Intenta pagar con otro medio.", text)
    }

    func testGetDescriptionForErrorBodyForREJECTED_BY_REGULATIONS() throws {
        let text = PXResourceProvider.getDescriptionForErrorBodyForREJECTED_BY_REGULATIONS()

        XCTAssertEqual("Para pagar con dinero en cuenta debes completar los datos faltantes.", text)
    }

    func testGetDescriptionForErrorBodyForREJECTED_INVALID_INSTALLMENTS() throws {
        let text = PXResourceProvider.getDescriptionForErrorBodyForREJECTED_INVALID_INSTALLMENTS()

        XCTAssertEqual("Elige otra cantidad de cuotas o usa otro medio de pago.", text)
    }

    func testGetDescriptionForErrorBodyForREJECTED_RAW_INSUFFICIENT_AMOUNT() throws {
        let text = PXResourceProvider.getDescriptionForErrorBodyForREJECTED_RAW_INSUFFICIENT_AMOUNT()

        XCTAssertEqual("Inténtalo con otro medio de pago.", text)
    }

    func testGetDescriptionForErrorBodyForREJECTED_CAP_EXCEEDED() throws {
        let text = PXResourceProvider.getDescriptionForErrorBodyForREJECTED_CAP_EXCEEDED()

        XCTAssertEqual("Puedes realizar la operación con un medio de pago distinto.", text)
    }

    func testGetDescriptionForErrorBodyForGenericRejected() throws {
        let text = PXResourceProvider.getDescriptionForErrorBodyForGenericRejected()

        XCTAssertEqual("Lo sentimos, algo salió mal. Por favor, inténtalo de nuevo con otro medio de pago.", text)
    }
}
