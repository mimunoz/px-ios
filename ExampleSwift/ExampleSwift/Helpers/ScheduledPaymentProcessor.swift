import MercadoPagoSDKV4

final class ScheduledPaymentProcessor: NSObject, PXPaymentProcessor {
    public func startPayment(checkoutStore: PXCheckoutStore, errorHandler: PXPaymentProcessorErrorHandler, successWithBusinessResult: @escaping ((PXBusinessResult) -> Void), successWithPaymentResult: @escaping  ((PXGenericPayment) -> Void)) {
        print("Start payment")

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            successWithPaymentResult(PXGenericPayment(paymentStatus: .APPROVED, statusDetail: "Pago aprobado desde procesadora custom!"))
            // successWithPaymentResult(PXGenericPayment(paymentStatus: .REJECTED, statusDetail: "cc_amount_rate_limit_exceeded"))
//            successWithBusinessResult(PXBusinessResult(receiptId: "Random ID", status: .APPROVED, title: "Business title", subtitle: "Business subtitle", icon: nil, mainAction: PXAction(label: "Business action", action: { print("Action business") }), secondaryAction: nil, helpMessage: "Business help message", showPaymentMethod: true, statementDescription: "Business statement description", imageUrl: nil, topCustomView: nil, bottomCustomView: nil, paymentStatus: "Aprobado business", paymentStatusDetail: "Detalle status business", paymentMethodId: "paymentMethodId", paymentTypeId: "paymentTypeId", importantView: nil))
        })
    }

    public func paymentProcessorViewController() -> UIViewController? {
        return nil
    }

    public func support() -> Bool {
        return true
    }

    public func supportSplitPaymentMethodPayment(checkoutStore: PXCheckoutStore) -> Bool {
        return false
    }

    public func approvedGenericPayment () -> PXBasePayment {
        return PXGenericPayment(paymentStatus: .APPROVED, statusDetail: "Pago aprobado desde procesadora custom!")
    }

    public func rejectedCCAmountRateLimit () -> PXBasePayment {
        return PXGenericPayment(paymentStatus: .REJECTED, statusDetail: "cc_amount_rate_limit_exceeded")
    }
}
