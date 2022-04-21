enum CustomRequestInfos {
    case resetESCCap(cardId: String, privateKey: String?, headers: [String: String]?)
    case getCongrats(data: Data?, congratsModel: CustomParametersModel, headers: [String: String]?)
    case createPayment(privateKey: String?, publicKey: String, data: Data?, headers: [String: String]?)
}

extension CustomRequestInfos: RequestInfos {
    var endpoint: String {
        switch self {
        case .resetESCCap(let cardId, _, _): return "px_mobile/v1/esc_cap/\(cardId)"
        case .getCongrats: return "v1/px_mobile/congrats"
        case .createPayment: return "v1/px_mobile/payments"
        }
    }

    var method: HTTPMethodType {
        switch self {
        case .resetESCCap: return .delete
        case .getCongrats: return .get
        case .createPayment: return .post
        }
    }

    var shouldSetEnvironment: Bool {
        switch self {
        case .resetESCCap: return true
        case .createPayment, .getCongrats: return false
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .resetESCCap: return nil
        case .getCongrats(_, let parameters, _): return organizeParameters(parameters: parameters)
        case .createPayment(_, let publicKey, _, _):
            return [
                "public_key": publicKey,
                "api_version": "2.0"
            ]
        }
    }

    var headers: [String: String]? {
        switch self {
        case .createPayment(_, _, _, let headers), .resetESCCap(_, _, let headers), .getCongrats(_, _, let headers):
            return headers
        }
    }

    var body: Data? {
        switch self {
        case .resetESCCap: return nil
        case .getCongrats(let data, _, _): return data
        case .createPayment(_, _, let data, _): return data
        }
    }

    var accessToken: String? {
        switch self {
        case .resetESCCap(_, let privateKey, _): return privateKey
        case .getCongrats(_, let parameters, _): return parameters.privateKey
        case .createPayment(let privateKey, _, _, _): return privateKey
        }
    }
}

extension CustomRequestInfos {
    func organizeParameters(parameters: CustomParametersModel) -> [String: Any] {
        var filteredParameters: [String: Any] = [:]

        if parameters.publicKey != "" {
            filteredParameters.updateValue(parameters.publicKey, forKey: "public_key")
        }

        if parameters.paymentMethodIds != "" {
            filteredParameters.updateValue(parameters.paymentMethodIds, forKey: "payment_methods_ids")
        }

        if parameters.paymentId != "" {
            filteredParameters.updateValue(parameters.paymentId, forKey: "payment_ids")
        }

        if let prefId = parameters.prefId {
            filteredParameters.updateValue(prefId, forKey: "pref_id")
        }

        if let campaignId = parameters.campaignId {
            filteredParameters.updateValue(campaignId, forKey: "campaign_id")
        }

        if let flowName = parameters.flowName {
            filteredParameters.updateValue(flowName, forKey: "flow_name")
        }

        if let merchantOrderId = parameters.merchantOrderId {
            filteredParameters.updateValue(merchantOrderId, forKey: "merchant_order_id")
        }

        if let paymentTypeId = parameters.paymentTypeId {
            filteredParameters.updateValue(paymentTypeId, forKey: "payment_type_id ")
        }

        filteredParameters.updateValue("2.0", forKey: "api_version")
        filteredParameters.updateValue(parameters.ifpe, forKey: "ifpe")
        filteredParameters.updateValue("MP", forKey: "platform")

        return filteredParameters
    }
}
