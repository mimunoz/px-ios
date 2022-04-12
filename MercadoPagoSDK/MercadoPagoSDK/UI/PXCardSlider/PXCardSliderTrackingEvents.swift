enum PXCardSliderTrackingEvents: TrackingEvents {
    case comboSwitch(String)

    var name: String {
        switch self {
        case .comboSwitch: return "/px_checkout/combo_switch"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .comboSwitch(let state): return ["option_selected": state]
        }
    }
}
