import Foundation

struct PXCreditsViewModel {
    let displayInfo: PXDisplayInfoDto
    let needsTermsAndConditions: Bool

    init(_ withModel: PXOneTapCreditsDto, needsTermsAndConditions: Bool = true) {
        self.displayInfo = withModel.displayInfo
        self.needsTermsAndConditions = needsTermsAndConditions
    }
}

extension PXCreditsViewModel {
    func getCardColors() -> [CGColor] {
        let defaultColor: CGColor = UIColor.gray.cgColor
        guard let gradients = displayInfo.gradientColors else { return [defaultColor, defaultColor] }
        var arrayColors: [CGColor] = [CGColor]()
        for color in gradients {
            arrayColors.append(color.hexToUIColor().cgColor)
        }
        return arrayColors
    }
}
