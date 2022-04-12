enum GeneralErrorTrackingEvents: TrackingEvents {
    case error([String: Any])

    var name: String {
        switch self {
        case .error: return "/friction"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .error(let properties): return properties
        }
    }
}
