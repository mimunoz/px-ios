protocol RemedyService {
    func getRemedy(paymentMethodId: String,
                   privateKey: String?,
                   oneTap: Bool,
                   remedy: PXRemedyBody,
                   completion: @escaping (Swift.Result<PXRemedy, PXError>) -> Void)
}

final class RemedyServiceImpl: RemedyService {
    // MARK: - Private properties
    private let service: Request<RemedyRequestInfos>

    // MARK: - Initialization
    init(service: Request<RemedyRequestInfos> = Request<RemedyRequestInfos>()) {
        self.service = service
    }

    // MARK: - Public methods
    func getRemedy(paymentMethodId: String, privateKey: String?, oneTap: Bool, remedy: PXRemedyBody, completion: @escaping (Swift.Result<PXRemedy, PXError>) -> Void) {
        let remedyBody = remedy
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let body = try? encoder.encode(remedyBody)

        service.requestData(target: .getRemedy(paymentMethodId: paymentMethodId, privateKey: privateKey, oneTap: oneTap, body: body)) { [weak self] apiResponse in
            switch apiResponse {
            case .success(let data):
                self?.buildRemedy(data: data, error: nil, completion: { remedy, error in
                    if let remedy = remedy { completion(.success(remedy)) }
                    if let error = error { completion(.failure(error)) }
                })
            case .failure(let error):
                self?.buildRemedy(data: nil, error: error, completion: { remedy, error in
                    if let remedy = remedy { completion(.success(remedy)) }
                    if let error = error { completion(.failure(error)) }
                })
            }
        }
    }

    // MARK: - Private Methods
    private func buildRemedy(data: Data?, error: Error?, completion: @escaping (PXRemedy?, PXError?) -> Void) {
        if let data = data {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let responseObject = try? decoder.decode(PXRemedy.self, from: data)
            completion(responseObject, nil)
        } else if let error = error {
            completion(nil, PXError(domain: ApiDomain.GET_REMEDY,
                                    code: ErrorTypes.NO_INTERNET_ERROR,
                                    userInfo: [
                                        NSLocalizedDescriptionKey: "Hubo un error",
                                        NSLocalizedFailureReasonErrorKey: error.localizedDescription
                                    ]))
        }
    }
}
