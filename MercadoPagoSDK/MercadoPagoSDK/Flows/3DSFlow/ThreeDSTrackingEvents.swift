enum ThreeDSTrackingEvents: TrackingEvents {
    case didGetProgramValidation([String: Any])

    var name: String {
        switch self {
        case .didGetProgramValidation: return "/px_checkout/program_validation"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .didGetProgramValidation(let properties): return properties
        }
    }

    var needsExternalData: Bool {
        switch self {
        case .didGetProgramValidation: return false
        }
    }
}
