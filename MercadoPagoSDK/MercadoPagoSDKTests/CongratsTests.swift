import XCTest
@testable import MercadoPagoSDKV4

class CongratsTests: XCTestCase {
    let greenColor = UIColor(red: 0.22, green: 0.71, blue: 0.29, alpha: 1)

    func testCommonCongrats() throws {
        let points: PXPoints = PXPoints(progress: PXPointsProgress(percentage: 0.85, levelColor: "#4063EA", levelNumber: 4), title: "Ud ganó 2.000 puntos", action: PXRemoteAction(label: "Ver mis beneficios", target: "meli://loyalty/webview?url=https%3A%2F%2Fwww.mercadolivre.com.br%2Fmercado-pontos%2Fv2%2Fhub%23origin%3Dcongrats"))
        let discounts: PXDiscounts = PXDiscounts(title: "Descuentos por tu nivel", subtitle: "", discountsAction: PXRemoteAction(label: "Ver todos los descuentos", target: "mercadopago://discount_center_payers/list#from=/px/congrats"), downloadAction: PXDownloadAction(title: "Exclusivo con la app de Mercado Libre", action: PXRemoteAction(label: "Descargar", target: "https://852u.adj.st/discount_center_payers/list?adjust_t=ufj9wxn&adjust_deeplink=mercadopago%3A%2F%2Fdiscount_center_payers%2Flist&adjust_label=px-ml")), items: [PXDiscountsItem(icon: "https://mla-s1-p.mlstatic.com/766266-MLA32568902676_102019-O.jpg", title: "Hasta", subtitle: "20 % OFF", target: "mercadopago://discount_center_payers/detail?campaign_id=1018483&user_level=1&mcc=1091102&distance=1072139&coupon_used=false&status=FULL&store_id=13040071&sections=%5B%7B%22id%22%3A%22header%22%2C%22type%22%3A%22header%22%2C%22content%22%3A%7B%22logo%22%3A%22https%3A%2F%2Fmla-s1-p.mlstatic.com%2F766266-MLA32568902676_102019-O.jpg%22%2C%22title%22%3A%22At%C3%A9%20R%24%2010%22%2C%22subtitle%22%3A%22Nutty%20Bavarian%22%7D%7D%5D#from=/px/congrats", campaingId: "1018483"), PXDiscountsItem(icon: "https://mla-s1-p.mlstatic.com/826105-MLA32568902631_102019-O.jpg", title: "Hasta", subtitle: "20 % OFF", target: "mercadopago://discount_center_payers/detail?campaign_id=1018457&user_level=1&mcc=4771701&distance=543968&coupon_used=false&status=FULL&store_id=30316240&sections=%5B%7B%22id%22%3A%22header%22%2C%22type%22%3A%22header%22%2C%22content%22%3A%7B%22logo%22%3A%22https%3A%2F%2Fmla-s1-p.mlstatic.com%2F826105-MLA32568902631_102019-O.jpg%22%2C%22title%22%3A%22At%C3%A9%20R%24%2015%22%2C%22subtitle%22%3A%22Drogasil%22%7D%7D%5D#from=/px/congrats", campaingId: "1018457"), PXDiscountsItem(icon: "https://mla-s1-p.mlstatic.com/761600-MLA32568902662_102019-O.jpg", title: "Hasta", subtitle: "10 % OFF", target: "mercadopago://discount_center_payers/detail?campaign_id=1018475&user_level=1&mcc=5611201&distance=654418&coupon_used=false&status=FULL&store_id=30108872&sections=%5B%7B%22id%22%3A%22header%22%2C%22type%22%3A%22header%22%2C%22content%22%3A%7B%22logo%22%3A%22https%3A%2F%2Fmla-s1-p.mlstatic.com%2F761600-MLA32568902662_102019-O.jpg%22%2C%22title%22%3A%22At%C3%A9%20R%24%2010%22%2C%22subtitle%22%3A%22McDonald%5Cu0027s%22%7D%7D%5D#from=/px/congrats", campaingId: "1018475") ], touchpoint: nil)
        let crosseling: [PXCrossSellingItem] = [PXCrossSellingItem(title: "Gane 200 pesos por sus pagos diarios", icon: "https://mobile.mercadolibre.com/remote_resources/image/merchengine_mgm_icon_ml?density=xxhdpi&locale=es_AR", contentId: "cross_selling_mgm_ml", action: PXRemoteAction(label: "Invita a más amigos a usar la aplicación", target: "meli://invite/wallet"))]

        let congrats = PXPaymentCongrats()
            .withCongratsType(.approved)
            .withHeader(title: "¡Listo! Ya le pagaste a SuperMarket", imageURL: "https://mla-s2-p.mlstatic.com/600619-MLA32239048138_092019-O.jpg", closeAction: {})
            .withReceipt(shouldShowReceipt: true, receiptId: "123", action: nil)
            .withFooterMainAction(PXAction(label: "Continuar", action: {}))
            .withFooterSecondaryAction(PXAction(label: "Tuve un problema", action: {}))
            .withLoyalty(points)
            .withDiscounts(discounts)
            .withCrossSelling(crosseling)
            .shouldShowPaymentMethod(true)
            .withSplitPaymentInfo(PXCongratsPaymentInfo(paidAmount: "$ 500", rawAmount: "$ 5000", paymentMethodName: "Dinero en cuenta", paymentMethodDescription: nil, paymentMethodIconURL: "https://www.google.com", paymentMethodType: .ACCOUNT_MONEY, installmentsCount: 1, installmentsAmount: "$ 500", installmentsTotalAmount: "$ 500", discountName: nil))

        let viewModel = PXPaymentCongratsViewModel(paymentCongrats: congrats)

        XCTAssertEqual(viewModel.getPoints()?.title, "Ud ganó 2.000 puntos")
        XCTAssertEqual(viewModel.getDiscounts()?.title, "Descuentos por tu nivel")
        XCTAssertEqual(viewModel.getCrossSellingItems()?.first?.title, "Gane 200 pesos por sus pagos diarios")
    }

    func testCongratsWithOutDiscountsAndPoints() throws {
        let congrats = PXPaymentCongrats()
            .withCongratsType(.approved)
            .withHeader(title: "¡Listo! Ya le pagaste a SuperMarket", imageURL: "https://mla-s2-p.mlstatic.com/600619-MLA32239048138_092019-O.jpg", closeAction: {})
            .withReceipt(shouldShowReceipt: true, receiptId: "123", action: nil)
            .withFooterMainAction(PXAction(label: "Continuar", action: {}))
            .withFooterSecondaryAction(PXAction(label: "Tuve un problema", action: {}))
            .withCrossSelling([PXCrossSellingItem(title: "Gane 200 pesos por sus pagos diarios", icon: "https://mobile.mercadolibre.com/remote_resources/image/merchengine_mgm_icon_ml?density=xxhdpi&locale=es_AR", contentId: "cross_selling_mgm_ml", action: PXRemoteAction(label: "Invita a más amigos a usar la aplicación", target: "meli://invite/wallet"))])
            .withSplitPaymentInfo(PXCongratsPaymentInfo(paidAmount: "$ 500", rawAmount: "$ 5000", paymentMethodName: "Dinero en cuenta", paymentMethodLastFourDigits: "", paymentMethodDescription: "", paymentMethodIconURL: "https://mobile.mercadolibre.com/remote_resources/image/px_pm_account_money?density=xhdpi&locale=en_US", paymentMethodType: .ACCOUNT_MONEY, installmentsRate: nil, installmentsCount: 0, installmentsAmount: "", installmentsTotalAmount: "", discountName: nil))

        let viewModel = PXPaymentCongratsViewModel(paymentCongrats: congrats)

        XCTAssertEqual(viewModel.getHeaderTitle(), "¡Listo! Ya le pagaste a SuperMarket")
        XCTAssertEqual(viewModel.getHeaderColor(), greenColor)
        XCTAssertEqual(viewModel.getCrossSellingItems()?.first?.title, "Gane 200 pesos por sus pagos diarios")
        XCTAssertEqual(viewModel.getSplitPaymentViewData()?.firstString?.string, "$ 500")
    }

    func testCongratsWithInstallments() throws {
        let congrats = PXPaymentCongrats()
            .withCongratsType(.approved)
            .withHeader(title: "¡Listo! Ya le pagaste a SuperMarket", imageURL: "https://mla-s2-p.mlstatic.com/600619-MLA32239048138_092019-O.jpg", closeAction: {})
            .withReceipt(shouldShowReceipt: true, receiptId: "123", action: nil)
            .withFooterMainAction(PXAction(label: "Continuar", action: {}))
            .shouldShowPaymentMethod(true)
            .withPaymentMethodInfo(PXCongratsPaymentInfo(paidAmount: "", rawAmount: nil, paymentMethodName: "Mastercard", paymentMethodLastFourDigits: "1234", paymentMethodDescription: nil, paymentMethodIconURL: "https://www.google.com", paymentMethodType: .CREDIT_CARD, installmentsRate: 1, installmentsCount: 18, installmentsAmount: "$ 100", installmentsTotalAmount: "$ 18.000", discountName: nil))

        let viewModel = PXPaymentCongratsViewModel(paymentCongrats: congrats)

        XCTAssertEqual(viewModel.getPaymentViewData()?.firstString?.string, "18x $ 100 ($ 18.000)")
    }

    func testCongratsWithOneInstallments() throws {
        let congrats = PXPaymentCongrats()
            .withCongratsType(.approved)
            .withHeader(title: "¡Listo! Ya le pagaste a SuperMarket", imageURL: "https://mla-s2-p.mlstatic.com/600619-MLA32239048138_092019-O.jpg", closeAction: {})
            .withReceipt(shouldShowReceipt: true, receiptId: "123", action: nil)
            .withFooterMainAction(PXAction(label: "Continuar", action: {}))
            .shouldShowPaymentMethod(true)
            .withSplitPaymentInfo(PXCongratsPaymentInfo(paidAmount: "$ 500", rawAmount: "$ 5000", paymentMethodName: "Dinero en cuenta", paymentMethodDescription: nil, paymentMethodIconURL: "https://mobile.mercadolibre.com/remote_resources/image/px_pm_account_money?density=xhdpi&locale=en_US", paymentMethodType: .ACCOUNT_MONEY, installmentsCount: 1, installmentsAmount: "$ 500", installmentsTotalAmount: "$ 500", discountName: nil))

        let viewModel = PXPaymentCongratsViewModel(paymentCongrats: congrats)

        XCTAssertEqual(viewModel.getSplitPaymentViewData()?.firstString?.string, "$ 500")
    }

    func testCongratsWithConsumerCredits() throws {
        let congrats = PXPaymentCongrats()
            .withCongratsType(.approved)
            .withHeader(title: "¡Listo! Ya le pagaste a SuperMarket", imageURL: "https://mla-s2-p.mlstatic.com/600619-MLA32239048138_092019-O.jpg", closeAction: {})
            .withReceipt(shouldShowReceipt: true, receiptId: "123", action: nil)
            .withFooterMainAction(PXAction(label: "Continuar", action: {}))
            .shouldShowPaymentMethod(true)
            .withPaymentMethodInfo(PXCongratsPaymentInfo(paidAmount: "$ 2.476,22", rawAmount: nil, paymentMethodName: "", paymentMethodLastFourDigits: nil, paymentMethodDescription: nil, paymentMethodIconURL: "https://www.google.com", paymentMethodType: .CONSUMER_CREDITS, installmentsRate: nil, installmentsCount: 0, installmentsAmount: nil, installmentsTotalAmount: nil, discountName: nil))

        let viewModel = PXPaymentCongratsViewModel(paymentCongrats: congrats)

        XCTAssertEqual(viewModel.getPaymentViewData()?.firstString?.string, "$ 2.476,22")
    }

    func testCongratsWithConsumerCreditsInstallments() throws {
        let congrats = PXPaymentCongrats()
            .withCongratsType(.approved)
            .withHeader(title: "¡Listo! Ya le pagaste a SuperMarket", imageURL: "https://mla-s2-p.mlstatic.com/600619-MLA32239048138_092019-O.jpg", closeAction: {})
            .withReceipt(shouldShowReceipt: true, receiptId: "123", action: nil)
            .withFooterMainAction(PXAction(label: "Continuar", action: {}))
            .shouldShowPaymentMethod(true)
            .withPaymentMethodInfo(PXCongratsPaymentInfo(paidAmount: "", rawAmount: nil, paymentMethodName: "cualquiera", paymentMethodLastFourDigits: nil, paymentMethodDescription: nil, paymentMethodIconURL: "https://www.google.com", paymentMethodType: .CONSUMER_CREDITS, installmentsRate: 1.5, installmentsCount: 3, installmentsAmount: "$ 300", installmentsTotalAmount: "$ 900", discountName: nil))

        let viewModel = PXPaymentCongratsViewModel(paymentCongrats: congrats)

        XCTAssertEqual(viewModel.getPaymentViewData()?.firstString?.string, "3x $ 300 ($ 900)")
    }

    func testCongratsWithAccountMoney() throws {
        let congrats = PXPaymentCongrats()
            .withCongratsType(.approved)
            .withHeader(title: "¡Listo! Ya le pagaste a SuperMarket", imageURL: "https://mla-s2-p.mlstatic.com/600619-MLA32239048138_092019-O.jpg", closeAction: {})
            .withReceipt(shouldShowReceipt: true, receiptId: "123", action: nil)
            .withFooterMainAction(PXAction(label: "Continuar", action: {}))
            .shouldShowPaymentMethod(true)
            .withPaymentMethodInfo(PXCongratsPaymentInfo(paidAmount: "$ 25.000", rawAmount: nil, paymentMethodName: "dasdasd", paymentMethodLastFourDigits: nil, paymentMethodDescription: "Disponible en Mercado Pago", paymentMethodIconURL: "https://mobile.mercadolibre.com/remote_resources/image/px_pm_account_money?density=xhdpi&locale=en_US", paymentMethodType: .ACCOUNT_MONEY, installmentsRate: nil, installmentsCount: 0, installmentsAmount: nil, installmentsTotalAmount: nil, discountName: nil))

        let viewModel = PXPaymentCongratsViewModel(paymentCongrats: congrats)

        XCTAssertEqual(viewModel.getPaymentViewData()?.firstString?.string, "$ 25.000")
        XCTAssertEqual(viewModel.getPaymentViewData()?.thirdString?.string, "Disponible en Mercado Pago")
    }

    func testCongratsWithDiscount() throws {
        let congrats = PXPaymentCongrats()
            .withCongratsType(.approved)
            .withHeader(title: "¡Listo! Ya le pagaste a SuperMarket", imageURL: "https://mla-s2-p.mlstatic.com/600619-MLA32239048138_092019-O.jpg", closeAction: {})
            .withReceipt(shouldShowReceipt: true, receiptId: "123", action: nil)
            .withFooterMainAction(PXAction(label: "Continuar", action: {}))
            .shouldShowPaymentMethod(true)
            .withPaymentMethodInfo(PXCongratsPaymentInfo(paidAmount: "$ 1.000", rawAmount: "$ 10.000", paymentMethodName: "dasdasd", paymentMethodLastFourDigits: "9876", paymentMethodDescription: nil, paymentMethodIconURL: "https://www.google.com", paymentMethodType: .CREDIT_CARD, installmentsRate: nil, installmentsCount: 1, installmentsAmount: nil, installmentsTotalAmount: "$ 1.000", discountName: "90% OFF"))

        let viewModel = PXPaymentCongratsViewModel(paymentCongrats: congrats)

        XCTAssertEqual(viewModel.getPaymentViewData()?.firstString?.string, " $ 10.000 90% OFF")
        XCTAssertEqual(viewModel.getPaymentViewData()?.secondString?.string, "Dasdasd completed in 9876")
    }
}
