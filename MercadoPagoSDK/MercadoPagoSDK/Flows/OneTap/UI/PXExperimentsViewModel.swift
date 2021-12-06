import Foundation

struct PXExperimentsViewModel {
    static let HIGHLIGHT_INSTALLMENTS = "px_nativo/highlight_installments"
    var experiments: [PXExperiment]?

    init(_ withModel: [PXExperiment]?) {
        self.experiments = withModel
    }

    func getExperiment(name: String) -> PXExperiment? {
        if let experiments = experiments {
            for experiment in experiments where experiment.name == name {
                return experiment
            }
        }
        return nil
    }
}

enum HighlightInstallmentsVariant: String {
    case control
    case animationPulse
    case badge

    var getValue: String {
        switch self {
        case .control: return "control"
        case .animationPulse: return "animation_pulse"
        case .badge: return "badge"
        }
    }
}
