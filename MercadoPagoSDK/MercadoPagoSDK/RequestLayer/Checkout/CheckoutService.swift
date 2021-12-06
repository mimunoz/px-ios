protocol CheckoutService {
    func getInit(preferenceId: String?,
                 privateKey: String?,
                 body: Data?,
                 headers: [String: String]?,
                 completion: @escaping (Swift.Result<PXInitDTO, PXError>) -> Void)
}

final class CheckoutServiceImpl: CheckoutService {
    // MARK: - Private properties
    private let service: Request<CheckoutRequestInfos>

    // MARK: - Initialization
    init(service: Request<CheckoutRequestInfos> = Request<CheckoutRequestInfos>()) {
        self.service = service
    }

    // MARK: - Public methods
    func getInit(preferenceId: String?, privateKey: String?, body: Data?, headers: [String: String]?, completion: @escaping (Swift.Result<PXInitDTO, PXError>) -> Void) {
        service.requestObject(model: PXInitDTO.self, .getInit(preferenceId: preferenceId, privateKey: privateKey, body: body, headers: headers)) { apiResponse in
            switch apiResponse {
            case .success(let mobileApiResult): completion(.success(mobileApiResult))
            case .failure: completion(.failure(PXError(domain: ApiDomain.GET_REMEDY,
                                                       code: ErrorTypes.NO_INTERNET_ERROR,
                                                       userInfo: [
                                                        NSLocalizedDescriptionKey: "Hubo un error",
                                                        NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"
                                                       ])
                                                )
                                        )
            }
        }
    }
}
