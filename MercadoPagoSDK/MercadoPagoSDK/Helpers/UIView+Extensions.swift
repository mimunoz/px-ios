import UIKit

extension UIView {
    func addSubviews(views: [UIView]) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }
    }
    
    func clearSubViews(_ currentView: UIView? = nil) {
        let view = currentView != nil ? currentView : self
        if view?.subviews.count ?? 0 > 0 {
            for subView in view?.subviews ?? [] {
                clearSubViews(subView)
            }
        }
        
        view?.removeFromSuperview()
    }
}
