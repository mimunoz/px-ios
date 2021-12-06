enum RemedyRequestInfos {
    case getRemedy(paymentMethodId: String, privateKey: String?, oneTap: Bool, body: Data?)
}

extension RemedyRequestInfos: RequestInfos {
    var endpoint: String {
        switch self {
        case .getRemedy(let paymentId, _, _, _): return "px_mobile/v1/remedies/\(paymentId)"
        }
    }

    var method: HTTPMethodType {
        .post
    }

    var body: Data? {
        switch self {
        case .getRemedy(_, _, _, let body): return body
        }
    }

    var headers: [String: String]? {
        switch self {
        case .getRemedy: return nil
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .getRemedy(_, _, let oneTap, _):
            return [
            "one_tap": oneTap ? "true" : "false"
            ]
        }
    }

    var accessToken: String? {
        switch self {
        case .getRemedy(_, let privateKey, _, _): return privateKey
        }
    }
}
