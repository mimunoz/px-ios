import UIKit

class ErrorViewController: MercadoPagoUIViewController {
    @IBOutlet var  errorTitle: MPLabel!
    @IBOutlet var errorSubtitle: MPLabel!
    @IBOutlet var errorIcon: UIImageView!
    @IBOutlet var exitButton: UIButton!
    @IBOutlet var retryButton: UIButton!

    var error: MPSDKError!
    var callback: (() -> Void)?
    open var exitErrorCallback: (() -> Void)!
    static var defaultErrorCancel: (() -> Void)?

    public init(error: MPSDKError!, callback: (() -> Void)?, callbackCancel: (() -> Void)? = nil) {
        super.init(nibName: "ErrorViewController", bundle: ResourceManager.shared.getBundle())
        self.error = error
        self.exitErrorCallback = {
            self.dismiss(animated: true, completion: {
                if self.callbackCancel != nil {
                    self.callbackCancel!()
                }
            })
        }
        self.callbackCancel = callbackCancel
        self.callback = callback
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.errorIcon.image = ResourceManager.shared.getImage("error_sign")
        self.errorTitle.text = error.message
        self.errorSubtitle.textColor = UIColor.pxBrownishGray

        let normalAttributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: Utils.getFont(size: 14)]

        self.errorSubtitle.attributedText = NSAttributedString(string: error.errorDetail, attributes: normalAttributes)
        self.exitButton.addTarget(self, action: #selector(ErrorViewController.invokeExitCallback), for: .touchUpInside)

        self.exitButton.setTitle("Salir".localized, for: .normal)
        self.retryButton.setTitle("Reintentar".localized, for: .normal)

        self.exitButton.setTitleColor(ThemeManager.shared.getAccentColor(), for: .normal)
        self.retryButton.setTitleColor(ThemeManager.shared.getAccentColor(), for: .normal)

        if self.error.retry! {
            self.retryButton.addTarget(self, action: #selector(ErrorViewController.invokeCallback), for: .touchUpInside)
            self.retryButton.isHidden = false
        } else {
            self.retryButton.isHidden = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackErrorEvent()
        trackScreenView()
    }

    @objc func invokeCallback() {
        if callback != nil {
            callback!()
        } else {
            if self.navigationController != nil {
                self.navigationController!.dismiss(animated: true, completion: {})
            } else {
                self.dismiss(animated: true, completion: {})
            }
        }
    }

    @objc func invokeExitCallback() {
        if let cancelCallback = ErrorViewController.defaultErrorCancel {
            cancelCallback()
        }
            self.exitErrorCallback()
    }
}

// MARK: Tracking
extension ErrorViewController {
    func trackErrorEvent() {
        var properties: [String: Any] = [:]
        properties["path"] = TrackingPaths.Screens.getErrorPath()
        properties["style"] = Tracking.Style.screen
        properties["id"] = Tracking.Error.Id.genericError
        properties["message"] = "Hubo un error".localized
        properties["attributable_to"] = Tracking.Error.Atrributable.mercadopago

        var extraDic: [String: Any] = [:]
        extraDic["api_error"] = error.getErrorForTracking()
        properties["extra_info"] = extraDic
        trackEvent(event: GeneralErrorTrackingEvents.error(properties))
    }

    func trackScreenView() {
        var properties: [String: Any] = [:]
        properties["api_error"] = error.getErrorForTracking()
        properties["error_message"] = "Hubo un error".localized
        trackScreen(event: GeneralErrorTrackingEvents.error(properties))
    }
}
