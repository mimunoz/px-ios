import Foundation
import MLUI

class PXAnimatedButton: UIButton {
    private enum Constants {
        static let defaultAnimationDuration = 0.5
        static let defaultTimeOut = 15.0
        static let explosionAnimationDuration = 0.3
        static let showIconAnimationDuration = 0.6
        static let hideIconAnimationDuration = 0.4
        static let scaleFactorForIconAnimation = CGFloat(0.40)
        static let xScaleForIconAnimation = CGFloat(1.0)
        static let xScaleForExpandAnimation = CGFloat(50)
    }

    weak var animationDelegate: PXAnimatedButtonDelegate?
    var progressView: ProgressView?
    var status: Status = .normal
    private(set) var animatedView: UIView?

    let normalText: String
    let loadingText: String
    let retryText: String
    var snackbar: MLSnackbar?

    private var buttonColor: UIColor?
    private let disabledButtonColor = ThemeManager.shared.greyColor()

    init(normalText: String, loadingText: String, retryText: String) {
        self.normalText = normalText
        self.loadingText = loadingText
        self.retryText = retryText
        super.init(frame: .zero)
        setTitle(normalText, for: .normal)
        titleLabel?.font = UIFont.ml_regularSystemFont(ofSize: PXLayout.S_FONT)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func anchorView() -> UIView? {
        return self.superview
    }

    enum Status {
        case normal
        case loading
        case expanding
        // MARK: Uncomment for Shake button
        //        case shaking
    }
}

// MARK: Animations
extension PXAnimatedButton: ProgressViewDelegate, CAAnimationDelegate {
    func startLoading(timeOut: TimeInterval = Constants.defaultTimeOut) {
        progressView = ProgressView(forView: self, loadingColor: #colorLiteral(red: 0.2666666667, green: 0.2666876018, blue: 0.2666300237, alpha: 0.4), timeOut: timeOut)
        progressView?.progressDelegate = self
        setTitle(loadingText, for: .normal)
        status = .loading
    }

    func finishAnimatingButton(color: UIColor, image: UIImage?, interrupt: Bool) {
        status = .expanding

        progressView?.doComplete(completion: { [weak self] _ in
            guard let self = self,
                let anchorView = self.anchorView() else { return }

            if interrupt {
                self.setTitle("", for: .normal)
                PXNotificationManager.Post.didFinishButtonAnimation()
                return
            }

            let animatedViewOriginInAnchorViewCoordinates = self.convert(CGPoint.zero, to: anchorView)
            let animatedViewFrameInAnchorViewCoordinates = CGRect(origin: animatedViewOriginInAnchorViewCoordinates, size: self.frame.size)

            let animatedView = UIView(frame: animatedViewFrameInAnchorViewCoordinates)
            animatedView.backgroundColor = self.backgroundColor
            animatedView.layer.cornerRadius = self.layer.cornerRadius
            animatedView.isAccessibilityElement = true

            anchorView.addSubview(animatedView)

            self.animatedView = animatedView
            self.alpha = 0

            let toCircleFrame = CGRect(
                x: animatedViewFrameInAnchorViewCoordinates.midX - animatedViewFrameInAnchorViewCoordinates.height / 2,
                y: animatedViewFrameInAnchorViewCoordinates.minY,
                width: animatedViewFrameInAnchorViewCoordinates.height,
                height: animatedViewFrameInAnchorViewCoordinates.height
            )
            let transitionAnimator = UIViewPropertyAnimator(
                duration: Constants.defaultAnimationDuration,
                dampingRatio: 1
            ) {
                animatedView.frame = toCircleFrame
                animatedView.layer.cornerRadius = toCircleFrame.height / 2
            }

            transitionAnimator.addCompletion { [weak self] _ in
                self?.explosion(color: color, newFrame: toCircleFrame, image: image)
            }

            transitionAnimator.startAnimation()
        })
    }

    private func explosion(color: UIColor, newFrame: CGRect, image: UIImage?) {
        guard let animatedView = self.animatedView else { return }

        UIView.animate(
            withDuration: Constants.explosionAnimationDuration,
            animations: { [weak self] in
                self?.progressView?.alpha = 0
                animatedView.backgroundColor = color
            }, completion: { _ in
                PXFeedbackGenerator.successNotificationFeedback()
                self.iconAnimation(newFrame: newFrame, image: image) {
                    self.animationDelegate?.expandAnimationInProgress()
                    self.expandAnimation {
                        self.animationDelegate?.didFinishAnimation()
                    }
                }
            }
        )
    }

    private func iconAnimation(newFrame: CGRect, image: UIImage?, completion: @escaping () -> Void) {
        guard let animatedView = self.animatedView else { return }
        let scaleFactor: CGFloat = Constants.scaleFactorForIconAnimation
        let iconImage = UIImageView(
            frame: CGRect(
                x: newFrame.width / 2 - (newFrame.width * scaleFactor) / 2,
                y: newFrame.width / 2 - (newFrame.width * scaleFactor) / 2,
                width: newFrame.width * scaleFactor,
                height: newFrame.height * scaleFactor
            )
        )

        iconImage.image = image
        iconImage.contentMode = .scaleAspectFit
        iconImage.alpha = 0
        animatedView.addSubview(iconImage)

        UIView.animate(
            withDuration: Constants.showIconAnimationDuration,
            animations: {
                iconImage.alpha = 1
                iconImage.transform = CGAffineTransform(
                    scaleX: Constants.xScaleForIconAnimation,
                    y: Constants.xScaleForIconAnimation
                )
            }, completion: { _ in
                UIView.animate(
                    withDuration: Constants.hideIconAnimationDuration,
                    animations: {
                        iconImage.alpha = 0
                    }, completion: { _ in completion() }
                )
            }
        )
    }

        private func expandAnimation(completion: @escaping () -> Void) {
            guard let animatedView = self.animatedView else { return }

            self.superview?.layer.masksToBounds = false
            UIView.animate(
                withDuration: Constants.defaultAnimationDuration,
                animations: {
                    animatedView.transform = CGAffineTransform(
                        scaleX: Constants.xScaleForExpandAnimation,
                        y: Constants.xScaleForExpandAnimation
                    )
                },
                completion: { _ in completion() }
            )
        }

    func didFinishProgress() {
        progressView?.doReset()
    }

    func showErrorToast(title: String, actionTitle: String?, type: MLSnackbarType, duration: MLSnackbarDuration, action: (() -> Void)?) {
        status = .normal
        resetButton()
        isUserInteractionEnabled = false
        if action == nil {
            PXComponentFactory.SnackBar.showShortDurationMessage(message: title, type: type) {
                self.completeSnackbarDismiss()
            }
        } else {
            snackbar = PXComponentFactory.SnackBar.showSnackbar(title: title, actionTitle: actionTitle, type: type, duration: duration, action: action) {
                self.completeSnackbarDismiss()
            }
        }
    }

    func completeSnackbarDismiss() {
        isUserInteractionEnabled = true
        animationDelegate?.shakeDidFinish()
    }

    // MARK: Uncomment for Shake button
    //    func shake() {
    //        status = .shaking
    //        resetButton()
    //        setTitle(retryText, for: .normal)
    //        UIView.animate(withDuration: 0.1, animations: {
    //            self.backgroundColor = ThemeManager.shared.rejectedColor()
    //        }, completion: { _ in
    //            let animation = CABasicAnimation(keyPath: "position")
    //            animation.duration = 0.1
    //            animation.repeatCount = 4
    //            animation.autoreverses = true
    //            animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 3, y: self.center.y))
    //            animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 3, y: self.center.y))
    //
    //            CATransaction.setCompletionBlock {
    //                self.isUserInteractionEnabled = true
    //                self.animationDelegate?.shakeDidFinish()
    //                self.status = .normal
    //                UIView.animate(withDuration: 0.3, animations: {
    //                    self.backgroundColor = ThemeManager.shared.getAccentColor()
    //                })
    //            }
    //            self.layer.add(animation, forKey: "position")
    //
    //            CATransaction.commit()
    //        })
    //    }

    func progressTimeOut() {
        progressView?.doReset()
        animationDelegate?.progressButtonAnimationTimeOut()
    }

    func resetButton() {
        setTitle(normalText, for: .normal)
        progressView?.stopTimer()
        progressView?.doReset()
    }

    func isAnimated() -> Bool {
        return status != .normal
    }

    func show(duration: Double = 0.5) {
        UIView.animate(withDuration: duration) { [weak self] in
            self?.alpha = 1
        }
    }

    func hide(duration: Double = 0.5) {
        UIView.animate(withDuration: duration) { [weak self] in
            self?.alpha = 0
        }
    }

    func dismissSnackbar() {
        snackbar?.dismiss()
    }
}

// MARK: Business Logic
extension PXAnimatedButton {
    @objc func animateFinish(_ sender: NSNotification) {
        if let notificationObject = sender.object as? PXAnimatedButtonNotificationObject {
            let image = ResourceManager.shared.getBadgeImageWith(status: notificationObject.status, statusDetail: notificationObject.statusDetail, clearBackground: true)
            let color = ResourceManager.shared.getResultColorWith(status: notificationObject.status, statusDetail: notificationObject.statusDetail)
            finishAnimatingButton(color: color, image: image, interrupt: notificationObject.interrupt)
        }
    }
}

extension PXAnimatedButton {
    func setEnabled(animated: Bool = true) {
        isUserInteractionEnabled = true
        if backgroundColor == disabledButtonColor {
            let duration = animated ? 0.3 : 0
            UIView.animate(withDuration: duration) { [weak self] in
                self?.backgroundColor = self?.buttonColor
            }
        }
    }

    func setDisabled(animated: Bool = true) {
        isUserInteractionEnabled = false
        if backgroundColor != disabledButtonColor {
            buttonColor = backgroundColor
            let duration = animated ? 0.3 : 0
            UIView.animate(withDuration: duration) { [weak self] in
                self?.backgroundColor = self?.disabledButtonColor
            }
        }
    }
}
