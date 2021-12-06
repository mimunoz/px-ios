import UIKit

extension PXResultViewModel {
    func buildBodyComponent() -> PXComponentizable? {
        let instruction = instructionsInfo
        let props = PXBodyProps(paymentResult: paymentResult, amountHelper: amountHelper, instruction: instruction)
        return PXBodyComponent(props: props)
    }
}
