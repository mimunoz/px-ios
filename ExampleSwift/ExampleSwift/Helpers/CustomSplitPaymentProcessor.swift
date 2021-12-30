//
//  CustomSplitPaymentProcessor.swift
//  ExampleSwift
//
//  Created by Jonathan Scaramal on 04/05/2021.
//  Copyright © 2021 Juan Sebastian Sanzone. All rights reserved.
//

import MercadoPagoSDKV4

final class CustomSplitPaymentProcessor: NSObject, PXSplitPaymentProcessor {
    func startPayment(
        checkoutStore: PXCheckoutStore,
        errorHandler: PXPaymentProcessorErrorHandler,
        successWithBasePayment: @escaping ((PXBasePayment) -> Void)
    ) {
        print("Start payment")

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            successWithBasePayment(self.approvedGenericPayment())
        }
    }

    func paymentProcessorViewController() -> UIViewController? {
        nil
    }

    func support() -> Bool {
        true
    }

    func supportSplitPaymentMethodPayment(checkoutStore: PXCheckoutStore) -> Bool {
        true
    }

    func approvedGenericPayment() -> PXGenericPayment {
        PXGenericPayment(paymentStatus: .APPROVED, statusDetail: "Pago aprobado desde procesadora custom!")
    }

    func rejectedCCAmountRateLimit() -> PXBasePayment {
        PXGenericPayment(paymentStatus: .REJECTED, statusDetail: "cc_amount_rate_limit_exceeded")
    }
}
