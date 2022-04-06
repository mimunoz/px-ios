import UIKit
import AndesUI

final class HighlightLabel: UIView {
    enum Layout {
        static let componentHeight: CGFloat = 24
    }

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupCornerRadius()
    }

    func setText(_ text: PXText) {
        textLabel.attributedText = text.getAttributedString(fontSize: PXLayout.XXXS_FONT)
    }

    private func setupView() {
        setupViewHierarchy()
        setupConstraints()
        setupLayout()
    }

    private func setupViewHierarchy() {
        addSubview(textLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PXLayout.XXS_MARGIN),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -PXLayout.XXS_MARGIN),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupLayout() {
        backgroundColor = .white
        layer.masksToBounds = true
    }

    private func setupCornerRadius() {
        let path: UIBezierPath = creatBezierPath()

        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    private func creatBezierPath() -> UIBezierPath {
        let minX = bounds.minX
        let minY = bounds.minY
        let maxX = bounds.maxX
        let maxY = bounds.maxY
        let topRightRadius: CGFloat = 8
        let bottomLeftRadius: CGFloat = 12
        let path = UIBezierPath()

        path.move(to: CGPoint(x: minX, y: minY))
        path.addLine(to: CGPoint(x: maxX - topRightRadius, y: minY))
        path.addArc(withCenter: CGPoint(x: maxX - topRightRadius, y: minY + topRightRadius), radius: topRightRadius, startAngle: 3 * M_PI_2, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: maxX, y: maxY))
        path.addLine(to: CGPoint(x: minX + bottomLeftRadius, y: maxY))
        path.addArc(withCenter: CGPoint(x: minX + bottomLeftRadius, y: maxY - bottomLeftRadius), radius: bottomLeftRadius, startAngle: M_PI_2, endAngle: M_PI, clockwise: true)
        path.addLine(to: CGPoint(x: minX, y: minY))

        path.close()

        return path
    }
}
