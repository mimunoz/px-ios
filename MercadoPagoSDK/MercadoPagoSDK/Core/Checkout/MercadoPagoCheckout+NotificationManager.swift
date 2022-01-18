import Foundation

extension MercadoPagoCheckout {
    public enum PostPayment {
        public typealias ResultBlock = (PXBasePayment?) -> Void
        public typealias CompletionBlock = (PXBasePayment, @escaping ResultBlock) -> Void
    }

    public enum NotificationCenter {
        static let `default` = Foundation.NotificationCenter()

        public enum SubscribeTo {}
        public enum UnsubscribeTo {}
        enum PublishTo {}
    }
}

public extension MercadoPagoCheckout.NotificationCenter.SubscribeTo {
    static func postPaymentAction
    (
        forName name: NSNotification.Name,
        using block: @escaping MercadoPagoCheckout.PostPayment.CompletionBlock
    ) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) {
            guard let result = $0.object as? (PXBasePayment, MercadoPagoCheckout.PostPayment.ResultBlock) else {
                return
            }
            block(result.0, result.1)
        }
    }
}

extension MercadoPagoCheckout.NotificationCenter.PublishTo {
    static func postPaymentAction(
        withName aName: Notification.Name,
        payment: PXBasePayment,
        result: @escaping MercadoPagoCheckout.PostPayment.ResultBlock
    ) {
        NotificationCenter.default.post(name: aName, object: (payment, result), userInfo: nil)
    }
}

public extension MercadoPagoCheckout.NotificationCenter.UnsubscribeTo {
    static func postPaymentAction(_ observer: Any) {
        NotificationCenter.default.removeObserver(observer)
    }
}
