import UIKit

@objcMembers
class MPButton: UIButton {
    var actionLink: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        updateFonts()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateFonts()
    }
}

// MARK: - Internals
extension MPButton {
    func updateFonts() {
        if let titleLabel = titleLabel, let titleFont = titleLabel.font {
            self.titleLabel?.font = Utils.getFont(size: titleFont.pointSize)
        }
    }
}
