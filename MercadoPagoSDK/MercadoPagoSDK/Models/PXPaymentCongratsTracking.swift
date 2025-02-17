import Foundation

@objcMembers
public class PXPaymentCongratsTracking: NSObject {
    let campaingId: String?
    let currencyId: String?
    let paymentStatusDetail: String
    let paymentId: Int64
    let paymentMethodId: String?
    let paymentMethodType: String?
    let totalAmount: NSDecimalNumber
    let trackListener: PXTrackerListener?
    let flowName: String?
    let flowDetails: [String: Any]?
    let sessionId: String?

    public init(campaingId: String?, currencyId: String?, paymentStatusDetail: String, totalAmount: NSDecimalNumber, paymentId: Int64, paymentMethodId: String?, paymentMethodType: String?, trackListener: PXTrackerListener, flowName: String?, flowDetails: [String: Any]?, sessionId: String?) {
        self.campaingId = campaingId
        self.currencyId = currencyId
        self.paymentStatusDetail = paymentStatusDetail
        self.totalAmount = totalAmount
        self.paymentId = paymentId
        self.paymentMethodType = paymentMethodType
        self.paymentMethodId = paymentMethodId
        self.trackListener = trackListener
        self.flowName = flowName
        self.flowDetails = flowDetails
        self.sessionId = sessionId
    }
}
