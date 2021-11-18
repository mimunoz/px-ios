import UIKit

final class PXOneTapInstallmentsSelectorCell: UITableViewCell {

    var data: PXOneTapInstallmentsSelectorData?

    func updateData(_ data: PXOneTapInstallmentsSelectorData) {
        self.data = data
        self.selectionStyle = .default
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.Andes.graySolid070
        self.selectedBackgroundView = selectedView
        
        let selectedIndicatorView = PXCheckbox(selected: data.isSelected)
        selectedIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(selectedIndicatorView)
        
        PXLayout.setWidth(owner: selectedIndicatorView, width: 20).isActive = true
        PXLayout.setHeight(owner: selectedIndicatorView, height: 20).isActive = true
        PXLayout.pinLeft(view: selectedIndicatorView, withMargin: PXLayout.SM_MARGIN).isActive = true
        PXLayout.centerVertically(view: selectedIndicatorView)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.attributedText = data.title
        titleLabel.textAlignment = .left
        contentView.addSubview(titleLabel)
        PXLayout.put(view: titleLabel, rightOf: selectedIndicatorView, withMargin: PXLayout.SM_MARGIN).isActive = true
        PXLayout.centerVertically(view: titleLabel).isActive = true

        let valueLabelsContainer = UIStackView()
        valueLabelsContainer.translatesAutoresizingMaskIntoConstraints = false
        valueLabelsContainer.axis = .vertical

        let topValueLabel = UILabel()
        topValueLabel.translatesAutoresizingMaskIntoConstraints = false
        topValueLabel.numberOfLines = 1
        topValueLabel.attributedText = data.topValue
        topValueLabel.textAlignment = .right
        valueLabelsContainer.addArrangedSubview(topValueLabel)

        let bottomValueLabel = UILabel()
        bottomValueLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomValueLabel.numberOfLines = 1
        bottomValueLabel.attributedText = data.bottomValue
        bottomValueLabel.textAlignment = .right
        valueLabelsContainer.addArrangedSubview(bottomValueLabel)

        //Value labels content view layout
        contentView.addSubview(valueLabelsContainer)
        PXLayout.pinRight(view: valueLabelsContainer, withMargin: PXLayout.M_MARGIN).isActive = true
        PXLayout.centerVertically(view: valueLabelsContainer).isActive = true
        PXLayout.setHeight(owner: valueLabelsContainer, height: 39).isActive = true
        PXLayout.put(view: valueLabelsContainer, rightOf: titleLabel, withMargin: PXLayout.XXS_MARGIN).isActive = true

        setAccessibilityMessage(data.title.string, data.topValue?.string, data.bottomValue?.string)
    }
}

// MARK: Accessibility
private extension PXOneTapInstallmentsSelectorCell {
    func setAccessibilityMessage(_ titleLabel: String, _ topLabel: String?, _ bottomLabel: String?) {
        let title = titleLabel.replacingOccurrences(of: "x", with: "de".localized).replacingOccurrences(of: "$", with: "") + " " + "pesos".localized
        var topText = ""
        var bottomText = ""
        if let text = topLabel, text.isNotEmpty {
            topText = text.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "") + "pesos".localized
        }
        if let text = bottomLabel, text.isNotEmpty {
            bottomText = text.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "") + "pesos".localized
        }
        accessibilityLabel = title + ":" + topText + bottomText
    }
}
