import UIKit

class PXBodyRenderer: NSObject {
    func render(_ body: PXBodyComponent) -> UIView {
        if body.hasBodyError() {
            return body.getBodyErrorComponent().render()
        }
        let bodyView = UIView()
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        return bodyView
    }
}

class PXBodyView: PXComponentView { }
