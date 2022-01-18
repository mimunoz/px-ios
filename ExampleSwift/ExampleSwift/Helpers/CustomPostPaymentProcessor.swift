//
//  CustomPostPaymentProcessor.swift
//  ExampleSwift
//
//  Created by Ricardo Grajales Duque on 21/12/21.
//  Copyright © 2021 Juan Sebastian Sanzone. All rights reserved.
//

import Foundation
import MercadoPagoSDKV4

final class CustomPostPaymentProcessor: NSObject, PXPaymentProcessor {
    private let testCase: CustomCheckoutTestCase

    init(with testCase: CustomCheckoutTestCase) {
        self.testCase = testCase
    }

    func startPayment(
        checkoutStore: PXCheckoutStore,
        errorHandler: PXPaymentProcessorErrorHandler,
        successWithBusinessResult: @escaping ((PXBusinessResult) -> Void),
        successWithPaymentResult: @escaping ((PXGenericPayment) -> Void)
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [self] in
            successWithPaymentResult(testCase.genericPayment)
        }
    }

    func paymentProcessorViewController() -> UIViewController? {
        return nil
    }

    func support() -> Bool {
        return true
    }
}
