//
//  CustomSplitPaymentProcessor.swift
//  ExampleSwift
//
//  Created by Jonathan Scaramal on 04/05/2021.
//  Copyright © 2021 Juan Sebastian Sanzone. All rights reserved.
//

import MercadoPagoSDKV4

final class CustomSplitPaymentProcessor: NSObject, PXSplitPaymentProcessor {
    public func startPayment(checkoutStore: PXCheckoutStore, errorHandler: PXPaymentProcessorErrorHandler, successWithBusinessResult: @escaping ((PXBusinessResult) -> Void), successWithPaymentResult: @escaping  ((PXGenericPayment) -> Void)) {
        print("Start payment")

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            successWithPaymentResult(self.approvedGenericPayment())
        })
    }

    public func paymentProcessorViewController() -> UIViewController? {
        return nil
    }

    public func support() -> Bool {
        return true
    }

    public func supportSplitPaymentMethodPayment(checkoutStore: PXCheckoutStore) -> Bool {
        return true
    }

    public func approvedGenericPayment () -> PXGenericPayment {
        return PXGenericPayment(paymentStatus: .APPROVED, statusDetail: "Pago aprobado desde procesadora custom!")
    }

    public func rejectedCCAmountRateLimit () -> PXBasePayment {
        return PXGenericPayment(paymentStatus: .REJECTED, statusDetail: "cc_amount_rate_limit_exceeded")
    }
}
