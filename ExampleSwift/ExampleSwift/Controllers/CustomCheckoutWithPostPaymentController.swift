import UIKit
import MercadoPagoSDKV4

enum CustomCheckoutTestCase: String, CaseIterable {
    case approved
    case rejected
    case error

    var genericPayment: PXGenericPayment {
        switch self {
        case .approved:
            return PXGenericPayment(
                status: "approved",
                statusDetail: "Pago aprobado desde procesadora custom!",
                paymentId: "1234",
                paymentMethodId: nil,
                paymentMethodTypeId: nil
            )
        case .rejected:
            return PXGenericPayment(
                paymentStatus: .REJECTED,
                statusDetail: "cc_amount_rate_limit_exceeded"
            )
        case .error:
            fatalError("genericPayment no debe ser invocado para este caso")
        }
    }
}

final class CustomCheckoutWithPostPaymentController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private var localeTextField: UITextField!
    @IBOutlet private var publicKeyTextField: UITextField!
    @IBOutlet private var preferenceIdTextField: UITextField!
    @IBOutlet private var accessTokenTextField: UITextField!
    @IBOutlet private var oneTapSwitch: UISwitch!
    @IBOutlet private var testCasePicker: UIPickerView!
    @IBOutlet private var customProcessorSwitch: UISwitch!

    // MARK: - Variables
    private var checkout: MercadoPagoCheckout?

    // Collector Public Key
    private var publicKey: String = "TEST-a463d259-b561-45fe-9dcc-0ce320d1a42f"

    // Preference ID
    private var preferenceId: String = "737302974-34e65c90-62ad-4b06-9f81-0aa08528ec53"

    // Payer private key - Access Token
    private var privateKey: String = "TEST-982391008451128-040514-b988271bf377ab11b0ace4f1ef338fe6-737303098"

    // MARK: - Actions
    @IBAction private func initCheckout(_ sender: Any) {
        guard localeTextField.text?.count ?? 0 > 0,
              publicKeyTextField.text?.count ?? 0 > 0,
              preferenceIdTextField.text?.count ?? 0 > 0 else {
            let alert = UIAlertController(
                title: "Error",
                message: "Complete los campos requeridos para continuar",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }

        if customProcessorSwitch.isOn {
            runMercadoPagoCheckoutWithLifecycleAndCustomProcessor()
        } else {
            runMercadoPagoCheckoutWithLifecycle()
        }
    }

    @IBAction private func resetData(_ sender: Any) {
        localeTextField.text = ""
        publicKeyTextField.text = ""
        preferenceIdTextField.text = ""
        accessTokenTextField.text = ""
        oneTapSwitch.setOn(true, animated: true)
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        let col1 = UIColor(red: 34.0 / 255.0, green: 211 / 255.0, blue: 198 / 255.0, alpha: 1)
        let col2 = UIColor(red: 145 / 255.0, green: 72.0 / 255.0, blue: 203 / 255.0, alpha: 1)
        gradient.colors = [col1.cgColor, col2.cgColor]
        view.layer.insertSublayer(gradient, at: 0)

        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
           let infoPlist = NSDictionary(contentsOfFile: path) {
            // Initialize values from config
            publicKeyTextField.text = infoPlist["PX_COLLECTOR_PUBLIC_KEY"] as? String
            accessTokenTextField.text = infoPlist["PX_PAYER_PRIVATE_KEY"] as? String
        }

        localeTextField.text = "es-AR"
        preferenceIdTextField.text = preferenceId
        publicKeyTextField.text = publicKey
        accessTokenTextField.text = privateKey

        self.testCasePicker.delegate = self
        self.testCasePicker.dataSource = self
    }

    // MARK: - Checkout Setup
    private func runMercadoPagoCheckoutWithLifecycle() {
        guard let publicKey = publicKeyTextField.text,
            let preferenceId = preferenceIdTextField.text,
            let language = localeTextField.text else {
            return
        }

        let builder = MercadoPagoCheckoutBuilder(publicKey: publicKey, preferenceId: preferenceId).setLanguage(language)
        if let privateKey = accessTokenTextField.text {
            builder.setPrivateKey(key: privateKey)
        }
        if oneTapSwitch.isOn {
            let advancedConfiguration = PXAdvancedConfiguration()
            builder.setAdvancedConfiguration(config: advancedConfiguration)
        }

        let postPaymentConfig = PXPostPaymentConfiguration()
        postPaymentConfig.postPaymentNotificationName = .init("example postpayment")
        builder.setPostPaymentConfiguration(config: postPaymentConfig)
        suscribeToPostPaymentNotification(postPaymentConfig: postPaymentConfig)

        let checkout = MercadoPagoCheckout(builder: builder)
        if let myNavigationController = navigationController {
            checkout.start(navigationController: myNavigationController, lifeCycleProtocol: self)
        }
    }

    private func runMercadoPagoCheckoutWithLifecycleAndCustomProcessor() {
        // Create charge rules
        let pxPaymentTypeChargeRules = [
            PXPaymentTypeChargeRule.init(
                paymentTypeId: PXPaymentTypes.CREDIT_CARD.rawValue,
                amountCharge: 10.00
            )
        ]

        // Create an instance of your custom payment processor
        let row = testCasePicker.selectedRow(inComponent: 0)
        let testCase = CustomCheckoutTestCase.allCases[row]
        let paymentProcessor: PXPaymentProcessor = CustomPostPaymentProcessor(with: testCase)

        // Create a payment configuration instance using the recently created payment processor
        let paymentConfiguration = PXPaymentConfiguration(paymentProcessor: paymentProcessor)

        // Add charge rules
        _ = paymentConfiguration.addChargeRules(charges: pxPaymentTypeChargeRules)

        let checkoutPreference = PXCheckoutPreference(
            siteId: "MLA",
            payerEmail: "1234@gmail.com",
            items: [
                PXItem(
                    title: "iPhone 12",
                    quantity: 1,
                    unitPrice: 150.0
                )
            ]
        )

        // Add excluded methods
        checkoutPreference.addExcludedPaymentMethod("master")

        guard let publicKey = publicKeyTextField.text,
              let privateKey = accessTokenTextField.text,
              let language = localeTextField.text else {
            return
        }

        let builder = MercadoPagoCheckoutBuilder(
            publicKey: publicKey,
            checkoutPreference: checkoutPreference,
            paymentConfiguration: paymentConfiguration
        )
        builder.setLanguage(language)
        builder.setPrivateKey(key: privateKey)

        // Adding a post payment notification and suscribed it
        let postPaymentConfig = PXPostPaymentConfiguration()
        postPaymentConfig.postPaymentNotificationName = .init("example postpayment")
        builder.setPostPaymentConfiguration(config: postPaymentConfig)
        suscribeToPostPaymentNotification(postPaymentConfig: postPaymentConfig)

        // Instantiate a configuration object
        let configuration = PXAdvancedConfiguration()

        // Add custom PXDynamicViewController component
        configuration.dynamicViewControllersConfiguration = [CustomPXDynamicComponent()]

        // Configure the builder object
        builder.setAdvancedConfiguration(config: configuration)

        // Set the payer private key
        builder.setPrivateKey(key: privateKey)

        // Create Checkout reference
        checkout = MercadoPagoCheckout(builder: builder)

        // Start with your navigation controller.
        if let myNavigationController = navigationController {
            checkout?.start(navigationController: myNavigationController, lifeCycleProtocol: self)
        }
    }

    func suscribeToPostPaymentNotification(postPaymentConfig: PXPostPaymentConfiguration) {
        _ = MercadoPagoCheckout.NotificationCenter.SubscribeTo.postPaymentAction(
            forName: postPaymentConfig.postPaymentNotificationName ?? .init("")
        ) { [weak self] _, resultBlock  in
            let postPayment = PostPaymentViewController(with: resultBlock)

            self?.present(
                UINavigationController(rootViewController: postPayment),
                animated: true,
                completion: nil
            )
        }
    }
}

// MARK: Optional Lifecycle protocol implementation example.
extension CustomCheckoutWithPostPaymentController: PXLifeCycleProtocol {
    func finishCheckout() -> ((PXResult?) -> Void)? {
        return nil
    }

    func cancelCheckout() -> (() -> Void)? {
        return nil
    }

    func changePaymentMethodTapped() -> (() -> Void)? {
        return { () in
            print("px - changePaymentMethodTapped")
        }
    }
}

extension CustomCheckoutWithPostPaymentController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        return string != " "
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension CustomCheckoutWithPostPaymentController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CustomCheckoutTestCase.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CustomCheckoutTestCase.allCases[row].rawValue
    }
}
