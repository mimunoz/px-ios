import Foundation

// Stored properties
protocol PXPropertyStoring {
    associatedtype CustomT
    func getAssociatedObject(_ key: UnsafeRawPointer, defaultValue: CustomT) -> CustomT
}

extension PXPropertyStoring {
    func getAssociatedObject(_ key: UnsafeRawPointer, defaultValue: CustomT) -> CustomT {
        guard let value = objc_getAssociatedObject(self, key) as? CustomT else {
            return defaultValue
        }
        return value
    }
}
