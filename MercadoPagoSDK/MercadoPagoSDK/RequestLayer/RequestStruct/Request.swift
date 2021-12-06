import Foundation

protocol RequestProtocol {
    associatedtype
        Target: RequestInfos
    func requestObject<Model: Codable>(model: Model.Type, _ target: Target, completionHandler: @escaping (Swift.Result<Model, Error>) -> Void)
    func requestData(target: Target, completionHandler: @escaping (Swift.Result<Data, Error>) -> Void)
}

enum HeaderFields: String {
    case productId = "X-Product-Id"
    case userAgent = "User-Agent"
    case contentType = "Content-Type"
    case sessionId = "X-Session-Id"
    case requestId = "X-Request-Id"
    case idempotencyKey = "X-Idempotency-Key"
    case density = "x-density"
    case language = "Accept-Language"
    case platform = "x-platform"
    case flowId = "x-flow-id"
    case security = "X-Security"
    case locationEnabled = "X-Location-Enabled"
    case accessToken = "Authorization"
    case isPublic = "X-public"
    case profileID = "X-Meli-Session-Id"
}

final class Request<Target: RequestInfos>: RequestProtocol {
    // MARK: - Perivate properties
    private let defaultProductId = "BJEO9TFBF6RG01IIIOU0"
    // MARK: - Public methods
    func requestObject<Model>(model: Model.Type, _ target: Target, completionHandler: @escaping (Swift.Result<Model, Error>) -> Void) where Model: Codable {
        guard let targetURL = URL(string: "\(target.baseURL)\(target.shouldSetEnvironment ?  target.environment.rawValue : "")\(target.endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            completionHandler(.failure(NSError()))
            return
        }

        #if DEBUG
        let url = target.mockURL ?? targetURL
        #else
        let url = targetURL
        #endif

        var request = URLRequest(url: url)

        if let headers = target.headers {
            for header in headers {
                request.setValue(header.key, forHTTPHeaderField: header.value)
            }
        }

        do {
            request = try target.parameterEncoding.encode(request: URLRequest(url: url), parameters: target.parameters)
        } catch {
            completionHandler(.failure(NSError()))
        }

        request.httpBody = target.body
        request.httpMethod = target.method.rawValue
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = 15.0

        request = setupStandardHeaders(baseRequest: request, accessToken: target.accessToken)

        // Product ID Header
        if target.headers?[HeaderFields.productId.rawValue] == nil {
            request.setValue(defaultProductId, forHTTPHeaderField: HeaderFields.productId.rawValue)
        }

        if let headers = target.headers {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completionHandler(.failure(error))
            }

            guard let data = data else {
                completionHandler(.failure(NSError()))
                return
            }

            do {
                let modelList = try JSONDecoder().decode(Model.self, from: data)
                completionHandler(.success(modelList))
            } catch {
                completionHandler(.failure(NSError()))
            }
        }.resume()
    }

    func requestData(target: Target, completionHandler: @escaping (Swift.Result<Data, Error>) -> Void) {
        guard let url = URL(string: "\(target.baseURL)\(target.environment.rawValue)\(target.endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            completionHandler(.failure(NSError()))
            return
        }

        var request = URLRequest(url: url)

        do {
            request = try target.parameterEncoding.encode(request: URLRequest(url: url), parameters: target.headers)
        } catch {
            completionHandler(.failure(NSError()))
        }

        do {
            request = try target.parameterEncoding.encode(request: URLRequest(url: url), parameters: target.parameters)
        } catch {
            completionHandler(.failure(NSError()))
        }

        request.httpBody = target.body
        request.httpMethod = target.method.rawValue
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = 15.0

        request = setupStandardHeaders(baseRequest: request, accessToken: target.accessToken)

        // Product ID Header
        if target.headers?[HeaderFields.productId.rawValue] == nil {
            request.setValue(defaultProductId, forHTTPHeaderField: HeaderFields.productId.rawValue)
        }

        if let headers = target.headers {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completionHandler(.failure(error))
            }

            guard let data = data else {
                completionHandler(.failure(NSError()))
                return
            }

            completionHandler(.success(data))
        }.resume()
    }

    // MARK: - Private merthods
    private func setupStandardHeaders(baseRequest: URLRequest, accessToken: String?) -> URLRequest {
        var request = baseRequest

        if let accessToken = accessToken {
            request.setValue("Bearer " + accessToken, forHTTPHeaderField: HeaderFields.accessToken.rawValue)
        }

        request.setValue("application/json", forHTTPHeaderField: HeaderFields.contentType.rawValue)
        if let sdkVersion = MercadoPagoBundle.bundleShortVersionString() {
            let value = "PX/iOS/" + sdkVersion
            request.setValue(value, forHTTPHeaderField: HeaderFields.userAgent.rawValue)
        }

        // Add session id
        request.setValue(MPXTracker.sharedInstance.getRequestId(), forHTTPHeaderField: HeaderFields.requestId.rawValue)
        request.setValue(MPXTracker.sharedInstance.getSessionID(), forHTTPHeaderField: HeaderFields.sessionId.rawValue)

        // Language
        request.setValue(Localizator.sharedInstance.getLanguage(), forHTTPHeaderField: HeaderFields.language.rawValue)

        // Density Header
        request.setValue("xxxhdpi", forHTTPHeaderField: HeaderFields.density.rawValue)

        // Add platform
        request.setValue(MLBusinessAppDataService().getAppIdentifier().rawValue, forHTTPHeaderField: HeaderFields.platform.rawValue)

        // Add flow id
        request.setValue(MPXTracker.sharedInstance.getFlowName() ?? "unknown", forHTTPHeaderField: HeaderFields.flowId.rawValue)

        return request
    }
}
