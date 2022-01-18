import Foundation

/**
 Post payment configuration provides you support for being called in your own flow
 before showing the congrats screen and then go back to the PX flow.
 */
@objcMembers
open class PXPostPaymentConfiguration: NSObject {
    /**
     The notification name that you will be using for post payment capability
     */
    open var postPaymentNotificationName: Notification.Name?
}
