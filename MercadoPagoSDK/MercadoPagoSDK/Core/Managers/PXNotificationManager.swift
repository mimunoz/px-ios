import Foundation

struct PXAnimatedButtonNotificationObject {
    var status: String
    var statusDetail: String?
    var postPaymentStatus: PostPaymentStatus?
}

struct PXNotificationManager {
}

extension PXNotificationManager {
    struct SuscribeTo {
        static func attemptToClose(_ observer: Any, selector: Selector) {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(observer, selector: selector, name: .attemptToClose, object: nil)
        }

        static func animateButton(_ observer: Any, selector: Selector) {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(observer, selector: selector, name: .animateButton, object: nil)
        }

        static func cardFormReset(_ observer: Any, selector: Selector) {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(observer, selector: selector, name: .cardFormReset, object: nil)
        }

        static func didFinishButtonAnimation(_ observer: Any, selector: Selector) {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(observer, selector: selector, name: .didFinishButtonAnimation, object: nil)
        }
    }
}

extension PXNotificationManager {
    struct UnsuscribeTo {
        static func attemptToClose(_ observer: Any) {
            let notificationCenter = NotificationCenter.default
            notificationCenter.removeObserver(observer, name: .attemptToClose, object: nil)
        }

        static func animateButton(_ observer: Any?) {
            guard let observer = observer else {
                return
            }
            let notificationCenter = NotificationCenter.default
            notificationCenter.removeObserver(observer, name: .animateButton, object: nil)
        }

        static func didFinishButtonAnimation(_ observer: Any?) {
            guard let observer = observer else {
                return
            }
            let notificationCenter = NotificationCenter.default
            notificationCenter.removeObserver(observer, name: .didFinishButtonAnimation, object: nil)
        }
    }
}

extension PXNotificationManager {
    struct Post {
        static func attemptToClose() {
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: .attemptToClose, object: nil)
        }

        static func animateButton(with object: PXAnimatedButtonNotificationObject) {
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: .animateButton, object: object)
        }

        static func cardFormReset() {
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: .cardFormReset, object: nil)
        }

        static func didFinishButtonAnimation() {
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: .didFinishButtonAnimation, object: nil)
        }
    }
}

extension NSNotification.Name {
    static let attemptToClose = Notification.Name(rawValue: "PXAttemptToClose")
    static let animateButton = Notification.Name(rawValue: "PXAnimateButton")
    static let cardFormReset = Notification.Name(rawValue: "PXCardFormReset")
    static let didFinishButtonAnimation = Notification.Name(rawValue: "PXDidFinishButtonAnimation")
}
