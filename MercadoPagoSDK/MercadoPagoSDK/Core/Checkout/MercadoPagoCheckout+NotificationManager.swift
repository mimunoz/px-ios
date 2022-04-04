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
    ) {
        // swiftlint:disable implicitly_unwrapped_optional
        var cancellable: NSObjectProtocol!
        // swiftlint:enable implicitly_unwrapped_optional
        cancellable = NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) {
            guard let result = $0.object as? (PXBasePayment, MercadoPagoCheckout.PostPayment.ResultBlock) else {
                return
            }
            let resultBlock: MercadoPagoCheckout.PostPayment.ResultBlock = {
                cancellable.flatMap(MercadoPagoCheckout.NotificationCenter.UnsubscribeTo.postPaymentAction)
                result.1($0)
            }
            block(result.0, resultBlock)
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
