import Foundation

enum PXFlowStatus {
    case ready
    case running
    case finished
}

protocol PXFlow {
    // Step logic
    func start()
    func executeNextStep()

    // Exit flow
    func cancelFlow()
    func finishFlow()
    func exitCheckout()
}

protocol PXFlowModel {
    associatedtype Steps
    func nextStep() -> Steps
}
