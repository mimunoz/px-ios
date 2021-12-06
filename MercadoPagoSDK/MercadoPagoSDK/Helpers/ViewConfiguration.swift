import UIKit

protocol ViewConfiguration {
    func buildHierarchy()
    func setupConstraints()
    func viewConfigure()
    func setupViewConfiguration()
}

extension ViewConfiguration {
    func setupViewConfiguration() {
        buildHierarchy()
        setupConstraints()
        viewConfigure()
    }

    func viewConfigure() { }
}
