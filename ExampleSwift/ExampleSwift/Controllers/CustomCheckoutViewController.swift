//
//  CustomCheckoutViewController.swift
//  ExampleSwift
//
//  Created by Eric Ertl on 28/05/2020.
//  Copyright © 2020 Juan Sebastian Sanzone. All rights reserved.
//

import UIKit

import MercadoPagoSDKV4

class CustomCheckoutViewController: UIViewController {
    @IBOutlet private var localeTextField: UITextField!
    @IBOutlet private var publicKeyTextField: UITextField!
    @IBOutlet private var preferenceIdTextField: UITextField!
    @IBOutlet private var accessTokenTextField: UITextField!
    @IBOutlet private var oneTapSwitch: UISwitch!

    @IBAction private func iniciarCheckout(_ sender: Any) {
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
        runMercadoPagoCheckoutWithLifecycle()
    }

    @IBAction private func restablecerDatos(_ sender: Any) {
        localeTextField.text = ""
        publicKeyTextField.text = ""
        preferenceIdTextField.text = ""
        accessTokenTextField.text = ""
        oneTapSwitch.setOn(true, animated: true)
    }

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
        preferenceIdTextField.text = "566676612-3bbb117b-1f3f-49c9-915d-565a785837d0"
    }

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
            advancedConfiguration.expressEnabled = true
            builder.setAdvancedConfiguration(config: advancedConfiguration)
        }

        let checkout = MercadoPagoCheckout(builder: builder)
        if let myNavigationController = navigationController {
            checkout.start(navigationController: myNavigationController, lifeCycleProtocol: self)
        }
    }
}

// MARK: Optional Lifecycle protocol implementation example.
extension CustomCheckoutViewController: PXLifeCycleProtocol {
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

extension CustomCheckoutViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if string == " " {
            return false
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
