//
//  ViewController.swift
//  ExampleSwift
//
//  Created by Juan sebastian Sanzone on 11/9/18.
//  Copyright © 2018 Juan Sebastian Sanzone. All rights reserved.
// Check full documentation: http://mercadopago.github.io/px-ios/v4/
//
import UIKit

import MercadoPagoSDKV4

// Check full documentation: http://mercadopago.github.io/px-ios/v4/
class ViewController: UIViewController {
    private var checkout: MercadoPagoCheckout?

    // Collector Public Key
    private var publicKey: String = ""

    // Payer private key
    private var privateKey: String = ""

    // Preference ID
    private var preferenceId: String = "656525290-89085586-1877-419a-b70f-9153de487900"

    @IBAction func initDefault(_ sender: Any) {
//         runMercadoPagoCheckout()
//         runMercadoPagoCheckoutWithLifecycle()
        runMercadoPagoCheckoutWithLifecycleAndCustomProcessor()
    }

    @IBAction func initPaymentMethodSelector(_ sender: Any) {
        runPXPaymentMethodSelector()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        let col1 = UIColor(red: 34.0 / 255.0, green: 211 / 255.0, blue: 198 / 255.0, alpha: 1)
        let col2 = UIColor(red: 145 / 255.0, green: 72.0 / 255.0, blue: 203 / 255.0, alpha: 1)
        gradient.colors = [col1.cgColor, col2.cgColor]
        view.layer.insertSublayer(gradient, at: 0)

        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"), let infoPlist = NSDictionary(contentsOfFile: path) {
            // Initialize values from config
            publicKey = infoPlist["PX_COLLECTOR_PUBLIC_KEY"] as? String ?? ""
            privateKey = infoPlist["PX_PAYER_PRIVATE_KEY"] as? String ?? ""
        }
    }

    private func runMercadoPagoCheckout() {
        // 1) Create Builder with your publicKey and preferenceId.
        let builder = MercadoPagoCheckoutBuilder(publicKey: publicKey, preferenceId: preferenceId).setLanguage("es")

        // 2) Create Checkout reference
        checkout = MercadoPagoCheckout(builder: builder)

        // 3) Start with your navigation controller.
        if let myNavigationController = navigationController {
            checkout?.start(navigationController: myNavigationController)
        }
    }

    private func generateCustomConfiguration() -> PXPaymentConfiguration {
        // Create an instance of your custom payment processor
        let customProcessor: PXPaymentProcessor = CustomPaymentProcessor()

        // Create a payment configuration instance using the recently created payment processor
        return PXPaymentConfiguration(paymentProcessor: customProcessor)
    }

    private func generateScheduledConfiguration() -> PXPaymentConfiguration {
        // Create an instance of your custom payment processor
        let scheduledProcessor: PXPaymentProcessor = ScheduledPaymentProcessor()

        // Create a payment configuration instance using the recently created payment processor
        return PXPaymentConfiguration(scheduledPaymentProcessor: scheduledProcessor)
    }

    private func generateSplitConfiguration() -> PXPaymentConfiguration {
        // Create an instance of your custom payment processor
        let splitProcessor: PXSplitPaymentProcessor = CustomSplitPaymentProcessor()

        // Create a payment configuration instance using the recently created payment processor
        return PXPaymentConfiguration(splitPaymentProcessor: splitProcessor)
    }

    private func runMercadoPagoCheckoutWithLifecycleAndCustomProcessor() {
        // Create charge rules
        var pxPaymentTypeChargeRules: [PXPaymentTypeChargeRule] = []

        pxPaymentTypeChargeRules.append(PXPaymentTypeChargeRule.init(paymentTypeId: PXPaymentTypes.CREDIT_CARD.rawValue, amountCharge: 10.00 ))

//        // Charge rule with custom dialog
//
//        let alertController : UIAlertController = UIAlertController.init(title: "Detalle del cargo", message: "Este es el detalle del cargo que visualizás", preferredStyle: .alert)
//
//        pxPaymentTypeChargeRules.append(PXPaymentTypeChargeRule.init(paymentTypeId: PXPaymentTypes.ACCOUNT_MONEY.rawValue, amountCharge: 15.00, detailModal: alertController ))
//

//         Free charge rule
    //    pxPaymentTypeChargeRules.append(PXPaymentTypeChargeRule.init(paymentTypeId: PXPaymentTypes.ACCOUNT_MONEY.rawValue, message: "Mensaje de resaltado"))

//       let stringLabel = "Custom label"
//
//       var myChargeRule: PXPaymentTypeChargeRule?
//
//       do {
//        try myChargeRule = PXPaymentTypeChargeRuleBuilder(paymentTypeId: PXPaymentTypes.ACCOUNT_MONEY.rawValue, amount: 10.0)
//           .setLabel(stringLabel)
//           .build()
//       } catch {
//           print("Error: \(error.localizedDescription)")
//       }
//
//       if let myChargeRule = myChargeRule {
//           pxPaymentTypeChargeRules.append(myChargeRule)
//       }
//

        // PAYMENT CONFIGURATION SECTION

        // Custom configuration
        let paymentConfiguration = generateCustomConfiguration()

//        // Scheduled configuration
//        let paymentConfiguration = generateScheduledConfiguration()
//
//        // Split configuration
//        let paymentConfiguration = generateSplitConfiguration()

        // CHARGE RULES SECTION

        // Add charge rules
        paymentConfiguration.addChargeRules(charges: pxPaymentTypeChargeRules)

        // PREFERENCE/BUILDER SECTION

//        // Create a Builder with your publicKey, preferenceId and paymentConfiguration
//        let builder = MercadoPagoCheckoutBuilder(publicKey: publicKey, preferenceId: preferenceId, paymentConfiguration: paymentConfiguration).setLanguage("es")

//        let checkoutPreference = PXCheckoutPreference.init(preferenceId: preferenceId)

        let checkoutPreference = PXCheckoutPreference(siteId: "MLB", payerEmail: "1234@gmail.com", items: [PXItem(title: "Taza de te", quantity: 1, unitPrice: 15.0)])

        // Add excluded methods
//        checkoutPreference.addExcludedPaymentType(PXPaymentTypes.TICKET.rawValue)
//        checkoutPreference.addExcludedPaymentType(PXPaymentTypes.ACCOUNT_MONEY.rawValue)
//        checkoutPreference.addExcludedPaymentMethod("master")

        let builder = MercadoPagoCheckoutBuilder.init(publicKey: publicKey, checkoutPreference: checkoutPreference, paymentConfiguration: paymentConfiguration)

//        let builder = MercadoPagoCheckoutBuilder(publicKey: publicKey, preferenceId: "656525290-8a2b6b01-da06-417f-8f5c-9441a0e7891d")

        // Instantiate a configuration object
        let configuration = PXAdvancedConfiguration()

        // Add custom PXDynamicViewController component
        configuration.dynamicViewControllersConfiguration = [CustomPXDynamicComponent()]

        configuration.setProductId(id: "BJDCVRTMG2N001KTKN6G")

        // Configure the builder object
        builder.setAdvancedConfiguration(config: configuration)

        // Set the payer private key
        builder.setPrivateKey(key: privateKey)

        builder.setLanguage("pt-BR")

        // Create Checkout reference
        checkout = MercadoPagoCheckout(builder: builder)

        // Start with your navigation controller.
        if let myNavigationController = navigationController {
            checkout?.start(navigationController: myNavigationController, lifeCycleProtocol: self)
        }
    }

    private func runMercadoPagoCheckoutWithLifecycle() {
        // Create Builder with your publicKey and preferenceId.
        let builder = MercadoPagoCheckoutBuilder(publicKey: publicKey, preferenceId: preferenceId).setLanguage("es")

        let configuration = PXAdvancedConfiguration()

        configuration.setProductId(id: "BJDCVRTMG2N001KTKN6G")

//        configuration.expressEnabled = true

        builder.setAdvancedConfiguration(config: configuration)

        // Set the payer private key
        builder.setPrivateKey(key: privateKey)

        // Add custom translations (px_custom_texts)
        builder.addCustomTranslation(.pay_button, withTranslation: "Pagar custom")
        builder.addCustomTranslation(.pay_button_progress, withTranslation: "Pagando custom...")
        builder.addCustomTranslation(.total_to_pay_onetap, withTranslation: "Total a pagar custom")

        // Create Checkout reference
        checkout = MercadoPagoCheckout(builder: builder)

        // Start with your navigation controller.
        if let myNavigationController = navigationController {
            checkout?.start(navigationController: myNavigationController, lifeCycleProtocol: self)
        }
    }

    func createPaymentMethodBehaviours() -> [PXPaymentMethodBehaviour] {
        let title = PXText(message: "Algun title", backgroundColor: "#FFFFFF", textColor: "#000000", weight: nil, alignment: nil)

        let description = PXText(message: "Alguna description", backgroundColor: "#FFFFFF", textColor: "#000000", weight: nil, alignment: nil)

        let pmBehaviour = PXPaymentMethodBehaviour(paymentTypeRules: ["account_money"], paymentMethodRules: ["account_money"], sliderTitle: "Custom slider title!", behaviours: [Behaviour(type: "tap_card", modalContent: ModalContent(title: title, description: description, button: Button(label: "Touch me", target: "#target"), imageURL: "https://assets.nintendo.com/image/upload/f_auto,q_auto/ncom/en_US/merchandising/curated%20list/Jump%20for%20joy%20with%20Super%20Mario/515x325_gameStore_mario?v=2022042221"))])

        return [pmBehaviour]
    }

    private func runPXPaymentMethodSelector() {
        let builder = PXPaymentMethodSelector.Builder(publicKey: publicKey, preferenceId: preferenceId)

        builder.setAccessToken(accessToken: privateKey)

        builder.setPaymentMethodBehaviours(paymentMethodBehaviours: createPaymentMethodBehaviours())

        var chargeRules: [PXPaymentTypeChargeRule] = []

        chargeRules.append(PXPaymentTypeChargeRule(paymentTypeId: "credit_card", amountCharge: 20.0))

        chargeRules.append(PXPaymentTypeChargeRule(paymentTypeId: "account_money", message: "Dinero en cuenta, sin cargo"))

        builder.setChargeRules(chargeRules: chargeRules)

        builder.setLanguage(PXLanguages.PORTUGUESE_BRAZIL.rawValue)

        builder.setPaymentMethodRules(paymentMethodRules: [PXPaymentMethodRules.ignoreInsufficientAMBalance.rawValue])

        builder.setTrackingConfiguration(trackingConfiguration: PXTrackingConfiguration(trackListener: self, flowName: "some-flow-id", flowDetails: nil, sessionId: "1234"))

        var paymentMethodSelector: PXPaymentMethodSelector?

        do {
            try paymentMethodSelector = builder.build()
        } catch {
            print(error)
        }

        guard let paymentMethodSelector = paymentMethodSelector else {
            return print("Error building paymentMethodSelector")
        }

        guard let navigationController = navigationController else {
            return print("Error obtaining navigation controller")
        }

        paymentMethodSelector.start(navigationController: navigationController, delegate: self)
    }
}

// MARK: Optional Lifecycle protocol implementation example.
extension ViewController: PXLifeCycleProtocol {
    func finishCheckout() -> ((PXResult?) -> Void)? {
        return nil
    }

    func cancelCheckout() -> (() -> Void)? {
        return nil
    }

    func changePaymentMethodTapped() -> (() -> Void)? {
        return nil
//        return { () in
//            print("px - changePaymentMethodTapped")
//        }
    }
}

extension ViewController: PXPaymentMethodSelectorDelegate {
    func didSelectPaymentMethod() -> ((PXCheckoutStore) -> Void)? {
        return { (_ checkoutStore: PXCheckoutStore) in
            print("PX - didSelectPaymentMethod")
            print(checkoutStore)

            if let navigationController = self.navigationController {
                navigationController.popToRootViewController(animated: false)
            }
        }
    }

    func didCancelPaymentMethodSelection() -> (() -> Void)? {
        return { () in
            print("PX - didCancelPaymentMethodSelection")
            if let navigationController = self.navigationController {
                navigationController.popToRootViewController(animated: false)
            }
        }
    }
}

extension ViewController: PXTrackerListener {
    func trackEvent(screenName: String?, action: String!, result: String?, extraParams: [String: Any]?) {
        print("Track event")
    }

    func trackScreen(screenName: String, extraParams: [String: Any]?) {
        print("Track screen")
    }
}
