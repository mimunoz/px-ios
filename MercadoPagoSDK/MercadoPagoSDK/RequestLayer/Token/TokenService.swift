protocol TokenService {
    func getToken(accessToken: String?,
                  publicKey: String,
                  cardTokenJSON: Data?,
                  completion: @escaping (Swift.Result<PXToken, PXError>) -> Void)

    func cloneToken(tokenId: String, publicKey: String, securityCode: String, completion: @escaping (Swift.Result<PXToken, PXError>) -> Void)
    func validateToken(tokenId: String, publicKey: String, body: Data, completion: @escaping (Swift.Result<PXToken, PXError>) -> Void)
}

final class TokenServiceImpl: TokenService {
    // MARK: - Private properties
    private let service: Request<TokenRequestInfos>

    // MARK: - Initialization
    init(service: Request<TokenRequestInfos> = Request<TokenRequestInfos>()) {
        self.service = service
    }

    // MARK: - Public methods
    func getToken(accessToken: String?, publicKey: String, cardTokenJSON: Data?, completion: @escaping (Swift.Result<PXToken, PXError>) -> Void) {
        service.requestObject(model: PXToken.self, .getToken(accessToken: accessToken, publicKey: publicKey, cardTokenJSON: cardTokenJSON)) { apiResponse in
            switch apiResponse {
            case .success(let token): completion(.success(token))
            case .failure: completion(.failure(PXError(domain: ApiDomain.GET_TOKEN,
                                                       code: ErrorTypes.NO_INTERNET_ERROR,
                                                       userInfo: [
                                                           NSLocalizedDescriptionKey: "Hubo un error",
                                                           NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"])
            ))
            }
        }
    }

    func cloneToken(tokenId: String, publicKey: String, securityCode: String, completion: @escaping (Swift.Result<PXToken, PXError>) -> Void) {
        service.requestData(target: .cloneToken(tokenId: tokenId, publicKey: publicKey)) { [weak self] apiResponse in
            switch apiResponse {
            case .success(let data):
                if let token = try? JSONDecoder().decode(PXToken.self, from: data) {
                    let secCodeDic: [String: Any] = ["security_code": securityCode]
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: secCodeDic, options: .prettyPrinted) else {
                        completion(.failure(PXError(domain: ApiDomain.CLONE_TOKEN,
                                                    code: ErrorTypes.NO_INTERNET_ERROR,
                                                    userInfo: [
                                                        NSLocalizedDescriptionKey: "Hubo un error",
                                                        NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"])
                        ))
                        return
                    }

                    self?.validateToken(tokenId: token.id, publicKey: publicKey, body: jsonData) { apiResponse in
                        switch apiResponse {
                        case .success(let token): completion(.success(token))
                        case .failure(let error): completion(.failure(error))
                        }
                    }
                }
            case .failure: completion(.failure(PXError(domain: ApiDomain.CLONE_TOKEN,
                                                       code: ErrorTypes.NO_INTERNET_ERROR,
                                                       userInfo: [
                                                           NSLocalizedDescriptionKey: "Hubo un error",
                                                           NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"])
            ))
            }
        }
    }

    func validateToken(tokenId: String, publicKey: String, body: Data, completion: @escaping (Swift.Result<PXToken, PXError>) -> Void) {
        service.requestObject(model: PXToken.self, .validateToken(tokenId: tokenId, publicKey: publicKey, body: body)) { apiResponse in
            switch apiResponse {
            case .success(let token): completion(.success(token))
            case .failure: completion(.failure(PXError(domain: ApiDomain.CLONE_TOKEN,
                                                       code: ErrorTypes.NO_INTERNET_ERROR,
                                                       userInfo: [
                                                           NSLocalizedDescriptionKey: "Hubo un error",
                                                           NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"])
            ))
            }
        }
    }
}
