import Foundation
import MLUI

class PXSecondaryButton: MLButton {
    override init() {
        let config = MLButtonStylesFactory.config(for: .primaryOption)
        super.init(config: config)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
