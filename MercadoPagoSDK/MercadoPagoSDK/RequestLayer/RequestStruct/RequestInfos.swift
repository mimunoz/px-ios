import Foundation

enum HTTPMethodType: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
}

enum BackendEnvironment: String, CaseIterable {
    case alpha = "alpha/"
    case beta = "beta/"
    case prod = "production/"
    case gamma = "gamma/"
}

protocol RequestInfos {
    var baseURL: URL { get }

    var environment: BackendEnvironment { get }

    var shouldSetEnvironment: Bool { get }

    var endpoint: String { get }

    var method: HTTPMethodType { get }

    var parameters: [String: Any]? { get }

    var headers: [String: String]? { get }

    var body: Data? { get }

    var parameterEncoding: ParameterEncode { get }

    var accessToken: String? { get }

    var mockURL: URL? { get }
}

extension RequestInfos {
    var baseURL: URL {
        return URL(string: "https://api.mercadopago.com/")!
    }

    var parameterEncoding: ParameterEncode {
        return ParameterEncodingImpl()
    }

    var environment: BackendEnvironment {
        // Try to match PX_ENVIRONMENT with BackendEnvironment options
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
           let infoPlist = NSDictionary(contentsOfFile: path),
           let pxEnvironment = infoPlist["PX_ENVIRONMENT"] as? String,
           let environment = BackendEnvironment.init(rawValue: "\(pxEnvironment)/") {
            // If some option match it's returned
            return environment
        }

        // In case there is no match it returns .prod
        return .prod
    }

    var shouldSetEnvironment: Bool {
        return true
    }

    var mockURL: URL? {
        return nil
    }
}
