import UIKit

extension Array {
    static func safeAppend(_ array: Array?, _ newElement: Element) -> Array {
        if var array = array {
            array.append(newElement)
            return array
        } else {
            return [newElement]
        }
    }
}

extension Collection {
    subscript(optional index: Index) -> Iterator.Element? {
        return self.indices.contains(index) ? self[index] : nil
    }
}
