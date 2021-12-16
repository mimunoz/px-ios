import Foundation
// Se importa MLCardForm para reutilizar la clase de Reachability
import MLCardForm

class MercadoPagoServices: NSObject {
    private var processingModes: [String] = PXServicesURLConfigs.MP_DEFAULT_PROCESSING_MODES
    private var branchId: String?
    private var baseURL: String! = PXServicesURLConfigs.MP_API_BASE_URL
    private var gatewayBaseURL: String!
    private var language: String = NSLocale.preferredLanguages[0]

    private let customService: CustomService
    private let remedyService: RemedyService
    private let gatewayService: TokenService
    private let checkoutService: CheckoutService

    // MARK: - Internal properties
    var reachability: Reachability?
    var hasInternet: Bool = true

    // MARK: - Open perperties
    open var publicKey: String
    open var privateKey: String?
    open var checkoutType: String?

    // MARK: - Initialization
    init(
        publicKey: String,
        privateKey: String? = nil,
        customService: CustomService = CustomServiceImpl(),
        remedyService: RemedyService = RemedyServiceImpl(),
        gatewayService: TokenService = TokenServiceImpl(),
        checkoutService: CheckoutService = CheckoutServiceImpl(),
        checkoutType: String?
    ) {
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.customService = customService
        self.remedyService = remedyService
        self.gatewayService = gatewayService
        self.checkoutService = checkoutService
        self.checkoutType = checkoutType ?? PXCheckoutType.DEFAULT_REGULAR.getString()
        super.init()
        addReachabilityObserver()
    }

    deinit {
        removeReachabilityObserver()
    }

    func update(processingModes: [String]?, branchId: String? = nil) {
        self.processingModes = processingModes ?? PXServicesURLConfigs.MP_DEFAULT_PROCESSING_MODES
        self.branchId = branchId
    }

    func getTimeOut() -> TimeInterval {
        return 15.0
    }

    func resetESCCap(cardId: String, onCompletion : @escaping () -> Void) {
        customService.resetESCCap(cardId: cardId, privateKey: privateKey) { _ in
            onCompletion()
        }
    }

    func getOpenPrefInitSearch(pref: PXCheckoutPreference, cardsWithEsc: [String], oneTapEnabled: Bool, splitEnabled: Bool, discountParamsConfiguration: PXDiscountParamsConfiguration?, flow: String?, charges: [PXPaymentTypeChargeRule], headers: [String: String]?, newCardId: String?, callback : @escaping (PXInitDTO) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        let bodyFeatures = PXInitFeatures(oneTap: oneTapEnabled, split: splitEnabled)
        let body = PXInitBody(preference: pref, publicKey: publicKey, flow: flow, cardsWithESC: cardsWithEsc, charges: charges, discountConfiguration: discountParamsConfiguration, features: bodyFeatures, newCardId: newCardId, checkoutType: checkoutType)

        let bodyJSON = try? body.toJSON()

        checkoutService.getInit(preferenceId: nil, privateKey: privateKey, body: bodyJSON, headers: headers) { apiResponse in
            switch apiResponse {
            case .success(let dto): callback(dto)
            case .failure(let error): failure(error)
            }
        }
    }

    func getClosedPrefInitSearch(preferenceId: String, cardsWithEsc: [String], oneTapEnabled: Bool, splitEnabled: Bool, discountParamsConfiguration: PXDiscountParamsConfiguration?, flow: String?, charges: [PXPaymentTypeChargeRule], headers: [String: String]?, newCardId: String?, callback : @escaping (PXInitDTO) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        let bodyFeatures = PXInitFeatures(oneTap: oneTapEnabled, split: splitEnabled)
        let body = PXInitBody(preference: nil, publicKey: publicKey, flow: flow, cardsWithESC: cardsWithEsc, charges: charges, discountConfiguration: discountParamsConfiguration, features: bodyFeatures, newCardId: newCardId, checkoutType: checkoutType)

        let bodyJSON = try? body.toJSON()

        checkoutService.getInit(preferenceId: preferenceId, privateKey: privateKey, body: bodyJSON, headers: headers) { apiResponse in
            switch apiResponse {
            case .success(let dto): callback(dto)
            case .failure(let error): failure(error)
            }
        }
    }

    func createPayment(url: String, uri: String, transactionId: String? = nil, paymentDataJSON: Data, query: [String: String]? = nil, headers: [String: String]? = nil, callback : @escaping (PXPayment) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        customService.createPayment(privateKey: privateKey, publicKey: publicKey, data: paymentDataJSON, header: headers) { apiResponse in
            switch apiResponse {
            case .success(let payment): callback(payment)
            case .failure(let error): failure(error)
            }
        }
    }

    func getPointsAndDiscounts(url: String, uri: String, paymentIds: [String]? = nil, paymentMethodsIds: [String]? = nil, campaignId: String?, prefId: String?, platform: String, ifpe: Bool, merchantOrderId: Int?, headers: [String: String], paymentTypeId: String?, callback : @escaping (PXPointsAndDiscounts) -> Void, failure: @escaping (() -> Void)) {
        let parameters = CustomParametersModel(privateKey: privateKey,
                                               publicKey: publicKey,
                                               paymentMethodIds: getPaymentMethodsIds(paymentMethodsIds),
                                               paymentId: getPaymentIds(paymentIds),
                                               ifpe: String(ifpe),
                                               prefId: prefId,
                                               campaignId: campaignId,
                                               flowName: MPXTracker.sharedInstance.getFlowName(),
                                               merchantOrderId: merchantOrderId != nil ? String(merchantOrderId!) : nil,
                                               paymentTypeId: paymentTypeId)
        customService.getPointsAndDiscounts(data: nil, parameters: parameters) { apiResponse in
            switch apiResponse {
            case .success(let pointsAndDiscounts): callback(pointsAndDiscounts)
            case .failure: failure()
            }
        }
    }

    func createToken(cardToken: PXCardToken, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        createToken(cardToken: try? cardToken.toJSON(), callback: callback, failure: failure)
    }

    func createToken(savedESCCardToken: PXSavedESCCardToken, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        createToken(cardToken: try? savedESCCardToken.toJSON(), callback: callback, failure: failure)
    }

    func createToken(savedCardToken: PXSavedCardToken, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        createToken(cardToken: try? savedCardToken.toJSON(), callback: callback, failure: failure)
    }

    func createToken(cardToken: Data?, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        gatewayService.getToken(accessToken: privateKey, publicKey: publicKey, cardTokenJSON: cardToken) { apiResponse in
            switch apiResponse {
            case .success(let token): callback(token)
            case .failure(let error): failure(error)
            }
        }
    }

    func cloneToken(tokenId: String, securityCode: String, callback : @escaping (PXToken) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        gatewayService.cloneToken(tokenId: tokenId, publicKey: publicKey, securityCode: securityCode) { apiResponse in
            switch apiResponse {
            case .success(let token): callback(token)
            case .failure(let error): failure(error)
            }
        }
    }

    func getRemedy(for paymentMethodId: String,
                   payerPaymentMethodRejected: PXPayerPaymentMethodRejected,
                   alternativePayerPaymentMethods: [PXRemedyPaymentMethod]?,
                   customStringConfiguration: PXCustomStringConfiguration?,
                   oneTap: Bool,
                   success : @escaping (PXRemedy) -> Void, failure: @escaping ((_ error: PXError) -> Void)) {
        let remedy = PXRemedyBody(customStringConfiguration: customStringConfiguration, payerPaymentMethodRejected: payerPaymentMethodRejected, alternativePayerPaymentMethods: alternativePayerPaymentMethods)

        remedyService.getRemedy(paymentMethodId: paymentMethodId, privateKey: privateKey, oneTap: oneTap, remedy: remedy) { apiResponse in
            switch apiResponse {
            case .success(let remedy): success(remedy)
            case .failure(let error): failure(error)
            }
        }
    }

    // SETS
    func setBaseURL(_ baseURL: String) {
        self.baseURL = baseURL
    }

    func setGatewayBaseURL(_ gatewayBaseURL: String) {
        self.gatewayBaseURL = gatewayBaseURL
    }

    func getGatewayURL() -> String {
        if !String.isNullOrEmpty(gatewayBaseURL) {
            return gatewayBaseURL
        }
        return baseURL
    }

    class func getParamsPublicKey(_ merchantPublicKey: String) -> String {
        var params: String = ""
        params.paramsAppend(key: ApiParam.PUBLIC_KEY, value: merchantPublicKey)
        return params
    }

    class func getParamsAccessToken(_ payerAccessToken: String?) -> String {
        var params: String = ""
        params.paramsAppend(key: ApiParam.PAYER_ACCESS_TOKEN, value: payerAccessToken)
        return params
    }

    class func getParamsPublicKeyAndAcessToken(_ merchantPublicKey: String, _ payerAccessToken: String?) -> String {
        var params: String = ""

        if !String.isNullOrEmpty(payerAccessToken) {
            params.paramsAppend(key: ApiParam.PAYER_ACCESS_TOKEN, value: payerAccessToken!)
        }
        params.paramsAppend(key: ApiParam.PUBLIC_KEY, value: merchantPublicKey)

        return params
    }

    class func getParamsAccessTokenAndPaymentIdsAndPlatform(_ payerAccessToken: String?, _ paymentIds: [String]?, _ platform: String?) -> String {
        var params: String = ""

        if let payerAccessToken = payerAccessToken, !payerAccessToken.isEmpty {
            params.paramsAppend(key: ApiParam.PAYER_ACCESS_TOKEN, value: payerAccessToken)
        }

        if let paymentIds = paymentIds, !paymentIds.isEmpty {
            var paymentIdsString = ""
            for (index, paymentId) in paymentIds.enumerated() {
                if index != 0 {
                    paymentIdsString.append(",")
                }
                paymentIdsString.append(paymentId)
            }
            params.paramsAppend(key: ApiParam.PAYMENT_IDS, value: paymentIdsString)
        }

        if let platform = platform {
            params.paramsAppend(key: ApiParam.PLATFORM, value: platform)
        }

        return params
    }

    func getPaymentIds(_ paymentIds: [String]?) -> String {
        var paymentIdsString = ""

        if let paymentIds = paymentIds, !paymentIds.isEmpty {
            for (index, paymentId) in paymentIds.enumerated() {
                if index != 0 {
                    paymentIdsString.append(",")
                }
                paymentIdsString.append(paymentId)
            }
        }

        return paymentIdsString
    }

    func getPaymentMethodsIds(_ paymentMethodsIds: [String]?) -> String {
        var paymentMethodsIdsString = ""
        if let paymentMethodsIds = paymentMethodsIds {
            for (index, paymentMethodId) in paymentMethodsIds.enumerated() {
                if index != 0 {
                    paymentMethodsIdsString.append(",")
                }
                if paymentMethodId.isNotEmpty {
                    paymentMethodsIdsString.append(paymentMethodId)
                }
            }
        }
        return paymentMethodsIdsString
    }

    func setLanguage(language: String) {
        self.language = language
    }
}
