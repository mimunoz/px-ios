import UIKit

open class FSPagerViewLayoutAttributes: UICollectionViewLayoutAttributes {
    open var position: CGFloat = 0

    override open func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? FSPagerViewLayoutAttributes else {
            return false
        }
        var isEqual = super.isEqual(object)
        isEqual = isEqual && (self.position == object.position)
        return isEqual
    }

    override open func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! FSPagerViewLayoutAttributes
        copy.position = self.position
        return copy
    }
}
