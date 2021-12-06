import Foundation

/// :nodoc:
extension PXInstructions {
    open func hasSubtitle() -> Bool {
        if instructions.isEmpty {
            return false
        } else {
            return !Array.isNullOrEmpty(instructions.first?.secondaryInfo)
        }
    }

    func getInstruction() -> PXInstruction? {
        if instructions.isEmpty {
            return nil
        } else {
            return instructions[0]
        }
    }
}
