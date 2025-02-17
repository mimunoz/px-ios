import Foundation

@objcMembers
public class PXPointsProgress: NSObject, Codable {
    let percentage: Double
    let levelColor: String
    let levelNumber: Int

    public init(percentage: Double, levelColor: String, levelNumber: Int) {
        self.percentage = percentage
        self.levelColor = levelColor
        self.levelNumber = levelNumber
    }

    enum CodingKeys: String, CodingKey {
        case percentage
        case levelColor = "level_color"
        case levelNumber = "level_number"
    }
}
