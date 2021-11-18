import UIKit
import AndesUI

protocol PXOneTapHeaderMerchantViewDelegate: NSObjectProtocol {
    func tappedBackButton()
}

class PXOneTapHeaderMerchantView: UIStackView {
    let image: UIImage
    let title: String
    private var subTitle: String?
    private var showHorizontally: Bool
    private var layout: PXOneTapHeaderMerchantLayout
    private var imageView: PXUIImageView?
    private var merchantTitleLabel: UILabel?
    var delegate: PXOneTapHeaderMerchantViewDelegate?

    init(image: UIImage, title: String, subTitle: String? = nil, showHorizontally: Bool) {
        self.image = image
        self.title = title
        self.showHorizontally = showHorizontally
        self.subTitle = subTitle
        self.layout = PXOneTapHeaderMerchantLayout(layoutType: subTitle == nil ? .onlyTitle : .titleSubtitle, showHorizontally: showHorizontally)
        super.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        render()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Borrar
    @objc
    func tappedBackButton() {
        delegate?.tappedBackButton()
    }

    private func render() {
        
        // Setup root StackView
        self.axis = .vertical
        self.alignment = showHorizontally ? .leading : .center
        self.distribution = .fill
        
        // If it shows vertically, then add top separator to center innerContainer
        if !showHorizontally {
            let emptyTopSeparator = UIStackView()
            emptyTopSeparator.axis = .vertical
            self.addArrangedSubview(emptyTopSeparator)
        }
        
        let stackView = createHeaderContainer()
        
        let backButtonContainer = createBackButtonContainer()

        let backButton = createBackButton()
        
        // Create top and bottom filler views
        
        let topFillerView = UIView()
        topFillerView.backgroundColor = UIColor.Andes.white
        topFillerView.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomFillerView = UIView()
        bottomFillerView.backgroundColor = UIColor.Andes.white
        bottomFillerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create inner container
        let innerContainer = createInnerContainer()
                
        self.addArrangedSubview(stackView)

        backButtonContainer.addArrangedSubview(backButton)
        stackView.addArrangedSubview(backButtonContainer)
        
        if !showHorizontally {
            stackView.addArrangedSubview(topFillerView)
        }
        
        stackView.addArrangedSubview(innerContainer)
        
        if !showHorizontally {
            stackView.addArrangedSubview(bottomFillerView)
        }
        
        // If showing horizontally add insets and spacing
        setUpHeaderConstraints(backButtonContainer: backButtonContainer,
                               stackView: stackView,
                               innerContainer: innerContainer,
                               backButton: backButton,
                               topFillerView: topFillerView,
                               bottomFillerView: bottomFillerView)
            
        // Add the image of the merchant
        let imageContainerView = buildImageContainerView(image: image)
        innerContainer.addArrangedSubview(imageContainerView)
        
        let titleContainer = createTitleAndSubtitleContainer()
        
        innerContainer.addArrangedSubview(titleContainer)
        
        let emptyBottomSeparator = UIStackView()
        emptyBottomSeparator.axis = .vertical
        self.addArrangedSubview(emptyBottomSeparator)
        
        if showHorizontally {
            NSLayoutConstraint.activate([
                titleContainer.centerYAnchor.constraint(equalTo: innerContainer.centerYAnchor),
                imageContainerView.centerYAnchor.constraint(equalTo: innerContainer.centerYAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                imageContainerView.bottomAnchor.constraint(equalTo: titleContainer.topAnchor, constant: -4)
            ])
        }
        
        PXLayout.setHeight(owner: backButton, height: 20).isActive = true
        PXLayout.setWidth(owner: backButton, width: 20).isActive = true
        
        self.layoutIfNeeded()

        isUserInteractionEnabled = true
    }
    
    private func createTitleAndSubtitleContainer() -> UIStackView {
        let titleContainer = UIStackView()
        titleContainer.axis = .vertical
        titleContainer.alignment = showHorizontally ? .leading : .center
        
        addTitleLabel(in: titleContainer)
        addSubtitleLabel(in: titleContainer)
    
        return titleContainer
    }
    
    private func addTitleLabel(in container: UIStackView) {
        merchantTitleLabel = buildTitleLabel(text: title)
        if let titleLabel = merchantTitleLabel {
            container.addArrangedSubview(titleLabel)
        }
    }
    
    private func addSubtitleLabel(in container: UIStackView) {
        if layout.getLayoutType() == .titleSubtitle {
            let subTitleLabel = buildSubTitleLabel(text: subTitle)
            container.addArrangedSubview(subTitleLabel)
        }
    }
    
    private func createInnerContainer() -> UIStackView {
        let innerContainer = UIStackView()
        innerContainer.axis = showHorizontally ? .horizontal : .vertical
        innerContainer.alignment = showHorizontally ? .center : .fill
        innerContainer.distribution = .fill
        innerContainer.spacing = 8
        
        return innerContainer
    }
    
    private func createBackButtonContainer() -> UIStackView {
        let backButtonContainer = UIStackView()
        backButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        backButtonContainer.axis = .vertical
        backButtonContainer.alignment = .leading
        
        return backButtonContainer
    }
    
    private func createBackButton() -> UIButton {
        let backButton = UIButton()
        let backButtonImage = ResourceManager.shared.getImage("back")
        
        backButton.setImage(backButtonImage?.mask(color: UIColor.Andes.gray900), for: .normal)
        backButton.addTarget(self, action: #selector(tappedBackButton), for: .touchUpInside)
        backButton.accessibilityLabel = "atrás".localized
        
        return backButton
    }
    
    private func createHeaderContainer() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = showHorizontally ? .horizontal : .vertical
        stackView.alignment = showHorizontally ? .leading : .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addBackground(color: UIColor.Andes.white)
        
        return stackView
    }
    
    private func setUpHeaderConstraints(backButtonContainer: UIStackView, stackView: UIStackView, innerContainer: UIStackView, backButton: UIButton, topFillerView: UIView, bottomFillerView: UIView) {
        if showHorizontally {
            innerContainer.spacing = 16
            innerContainer.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            innerContainer.isLayoutMarginsRelativeArrangement = true
            NSLayoutConstraint.activate([
                backButtonContainer.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: PXLayout.S_MARGIN),
                backButtonContainer.trailingAnchor.constraint(equalTo: innerContainer.leadingAnchor),
                backButtonContainer.centerYAnchor.constraint(equalTo: innerContainer.centerYAnchor),
                backButtonContainer.heightAnchor.constraint(equalToConstant: PXLayout.S_MARGIN),
                
                stackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                stackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                stackView.heightAnchor.constraint(equalToConstant: layout.IMAGE_SIZE + 10),
                stackView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: PXLayout.XXXS_MARGIN),
                
                innerContainer.topAnchor.constraint(equalTo: stackView.topAnchor),
                innerContainer.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
                
                backButton.trailingAnchor.constraint(equalTo: backButtonContainer.trailingAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                topFillerView.topAnchor.constraint(equalTo: backButtonContainer.bottomAnchor),
                topFillerView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                topFillerView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                topFillerView.bottomAnchor.constraint(equalTo: innerContainer.topAnchor),
                topFillerView.heightAnchor.constraint(equalTo: bottomFillerView.heightAnchor),
                
                bottomFillerView.topAnchor.constraint(equalTo: innerContainer.bottomAnchor),
                bottomFillerView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
                bottomFillerView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                bottomFillerView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                bottomFillerView.heightAnchor.constraint(equalTo: topFillerView.heightAnchor),
                
                backButtonContainer.heightAnchor.constraint(equalToConstant: PXLayout.S_MARGIN),
                backButtonContainer.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: PXLayout.S_MARGIN),
                backButtonContainer.topAnchor.constraint(equalTo: stackView.topAnchor),
                backButtonContainer.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                
                backButton.leadingAnchor.constraint(equalTo: backButtonContainer.leadingAnchor),

                stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: PXLayout.XS_MARGIN),
                stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }
    }

    private func buildImageContainerView(image: UIImage) -> UIView {
        let imageContainerView = UIStackView()
        imageContainerView.axis = .vertical
        imageContainerView.alignment = .center
        imageContainerView.distribution = .equalSpacing
        
        PXLayout.setHeight(owner: imageContainerView, height: layout.IMAGE_SIZE).isActive = true
        
        imageContainerView.dropShadow(radius: 2, opacity: 0.15)
        
        let imageView = PXUIImageView()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = layout.IMAGE_SIZE / 2
        
        PXLayout.setWidth(owner: imageView, width: layout.IMAGE_SIZE).isActive = true
        PXLayout.setHeight(owner: imageView, height: layout.IMAGE_SIZE).isActive = true
        imageView.enableFadeIn()
        imageView.backgroundColor = .white
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.Andes.gray070.cgColor
        imageView.image = image
        imageContainerView.addArrangedSubview(imageView)
        
        if showHorizontally {
            PXLayout.pinLeft(view: imageView).isActive = true
        }
        
        self.imageView = imageView
        return imageContainerView
    }

    private func buildTitleLabel(text: String) -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = text
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.font = UIFont.ml_semiboldSystemFont(ofSize: PXLayout.S_FONT)
        titleLabel.textColor = UIColor.Andes.gray900
        titleLabel.textAlignment = showHorizontally ? .left : .center

        return titleLabel
    }

    private func buildSubTitleLabel(text: String?) -> UILabel {
        let subTitleLabel = UILabel()
        subTitleLabel.text = text ?? ""
        subTitleLabel.numberOfLines = 1
        subTitleLabel.lineBreakMode = .byTruncatingTail
        subTitleLabel.font = UIFont.ml_regularSystemFont(ofSize: PXLayout.XXS_FONT)
        subTitleLabel.textColor = UIColor.Andes.gray900
        subTitleLabel.textAlignment = .center
        return subTitleLabel
    }
}

// MARK: Publics
extension PXOneTapHeaderMerchantView {
    func updateContentViewLayout(margin: CGFloat = PXLayout.M_MARGIN) {
        layoutIfNeeded()
    }

    func animateHeaderLayout(direction: OneTapHeaderAnimationDirection, duration: Double = 0) {
        layoutIfNeeded()
        var pxAnimator = PXAnimator(duration: duration, dampingRatio: 1)
        pxAnimator.addAnimation(animation: { [weak self] in
            guard let self = self else { return }
            self.layoutIfNeeded()
        })

        pxAnimator.animate()
    }

    func getMerchantTitleLabel() -> UILabel? {
        return merchantTitleLabel
    }
}
