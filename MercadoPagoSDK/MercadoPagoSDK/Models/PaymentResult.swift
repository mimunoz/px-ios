import Foundation

class PaymentResult {
    enum CongratsState: Int {
        case EXIT
        case SELECT_OTHER
        case RETRY
        case CALL_FOR_AUTH
        case RETRY_SECURITY_CODE
        case RETRY_SILVER_BULLET
        case DEEPLINK
    }

    private let warningStatusDetails = [PXPayment.StatusDetails.INVALID_ESC,
                                PXPayment.StatusDetails.REJECTED_CALL_FOR_AUTHORIZE,
                                PXPayment.StatusDetails.REJECTED_BAD_FILLED_CARD_NUMBER,
                                PXPayment.StatusDetails.REJECTED_CARD_DISABLED,
                                PXPayment.StatusDetails.REJECTED_INSUFFICIENT_AMOUNT,
                                PXPayment.StatusDetails.REJECTED_INVALID_INSTALLMENTS,
                                PXPayment.StatusDetails.REJECTED_BAD_FILLED_DATE,
                                PXPayment.StatusDetails.REJECTED_BAD_FILLED_SECURITY_CODE,
                                PXPayment.StatusDetails.REJECTED_BAD_FILLED_OTHER,
                                PXPayment.StatusDetails.PENDING_CONTINGENCY,
                                PXPayment.StatusDetails.PENDING_REVIEW_MANUAL]

    private let badFilledStatusDetails = [PXPayment.StatusDetails.REJECTED_BAD_FILLED_CARD_NUMBER,
                                  PXPayment.StatusDetails.REJECTED_BAD_FILLED_DATE,
                                  PXPayment.StatusDetails.REJECTED_BAD_FILLED_SECURITY_CODE,
                                  PXPayment.StatusDetails.REJECTED_BAD_FILLED_OTHER]

    // Rejected with remedies will be shown as warning
    private let rejectedWithRemedyStatusDetails = [PXPayment.StatusDetails.REJECTED_BAD_FILLED_SECURITY_CODE,
                                                   PXPayment.StatusDetails.REJECTED_HIGH_RISK,
                                                   PXPayment.StatusDetails.REJECTED_CARD_HIGH_RISK,
                                                   PXPayment.StatusDetails.REJECTED_INSUFFICIENT_AMOUNT,
                                                   PXPayment.StatusDetails.REJECTED_OTHER_REASON,
                                                   PXPayment.StatusDetails.REJECTED_MAX_ATTEMPTS,
                                                   PXPayment.StatusDetails.REJECTED_BLACKLIST,
                                                   PXPayment.StatusDetails.REJECTED_INVALID_INSTALLMENTS,
                                                   PXPayment.StatusDetails.REJECTED_BAD_FILLED_CARD_NUMBER,
                                                   PXPayment.StatusDetails.REJECTED_BAD_FILLED_OTHER,
                                                   PXPayment.StatusDetails.REJECTED_CALL_FOR_AUTHORIZE,
                                                   PXPayment.StatusDetails.REJECTED_CAP_EXCEEDED,
                                                   PXPayment.StatusDetails.REJECTED_RAW_INSUFFICIENT_AMOUNT,
                                                   PXPayment.StatusDetails.REJECTED_BANK_ERROR,
                                                   PXPayment.StatusDetails.REJECTED_INVALID_ACCOUNT]

    var paymentData: PXPaymentData?
    var splitAccountMoney: PXPaymentData?
    var status: String
    var statusDetail: String
    var payerEmail: String?
    var paymentId: String?
    var statementDescription: String?
    var cardId: String?
    var paymentMethodId: String?
    var paymentMethodTypeId: String?

    init (payment: PXPayment, paymentData: PXPaymentData) {
        self.status = payment.status
        self.statusDetail = payment.statusDetail
        self.paymentData = paymentData
        self.paymentId = payment.id.stringValue
        self.payerEmail = paymentData.payer?.email
        self.statementDescription = payment.statementDescriptor
        self.cardId = payment.card?.id
    }

    init (status: String, statusDetail: String, paymentData: PXPaymentData, splitAccountMoney: PXPaymentData?, payerEmail: String?, paymentId: String?, statementDescription: String?, paymentMethodId: String? = nil, paymentMethodTypeId: String? = nil) {
        self.status = status
        self.statusDetail = statusDetail
        self.paymentData = paymentData
        self.splitAccountMoney = splitAccountMoney
        self.payerEmail = payerEmail
        self.paymentId = paymentId
        self.statementDescription = statementDescription
        self.cardId = paymentData.token?.cardId
        self.paymentMethodTypeId = paymentMethodTypeId
        self.paymentMethodId = paymentMethodId
    }

    func isCallForAuth() -> Bool {
        return self.statusDetail == PXPayment.StatusDetails.REJECTED_CALL_FOR_AUTHORIZE
    }

    func isHighRisk() -> Bool {
        return [PXPayment.StatusDetails.REJECTED_CARD_HIGH_RISK,
                PXPayment.StatusDetails.REJECTED_HIGH_RISK].contains(statusDetail)
    }

    func isInvalidInstallments() -> Bool {
        return self.statusDetail == PXPayment.StatusDetails.REJECTED_INVALID_INSTALLMENTS
    }

    func isDuplicatedPayment() -> Bool {
        return self.statusDetail == PXPayment.StatusDetails.REJECTED_DUPLICATED_PAYMENT
    }

    func isFraudPayment() -> Bool {
        return self.statusDetail == PXPayment.StatusDetails.REJECTED_FRAUD
    }

    func isCardDisabled() -> Bool {
        return self.statusDetail == PXPayment.StatusDetails.REJECTED_CARD_DISABLED
    }

    func isBadFilled() -> Bool {
        return badFilledStatusDetails.contains(statusDetail)
    }

    func hasSecondaryButton() -> Bool {
        return isCallForAuth() ||
            isBadFilled() ||
            isInvalidInstallments() ||
            isCardDisabled()
    }

    func isApproved() -> Bool {
        return self.status == PXPaymentStatus.APPROVED.rawValue
    }

    func isPending() -> Bool {
        return self.status == PXPaymentStatus.PENDING.rawValue
    }

    func isInProcess() -> Bool {
        return self.status == PXPaymentStatus.IN_PROCESS.rawValue
    }

    func isRejected() -> Bool {
        return self.status == PXPaymentStatus.REJECTED.rawValue
    }

    func isRejectedWithRemedy() -> Bool {
        return self.status == PXPaymentStatus.REJECTED.rawValue && rejectedWithRemedyStatusDetails.contains(statusDetail)
    }

    func isInvalidESC() -> Bool {
        return self.statusDetail == PXPayment.StatusDetails.INVALID_ESC
    }

    func isPixOrOfflinePayment() -> Bool {
        return self.statusDetail == PXPayment.StatusDetails.PENDING_WAITING_TRANSFER &&
            self.status == PXPaymentStatus.PENDING.rawValue
    }

    func isReviewManual() -> Bool {
        return self.statusDetail == PXPayment.StatusDetails.PENDING_REVIEW_MANUAL
    }

    func isWaitingForPayment() -> Bool {
        return self.statusDetail == PXPayment.StatusDetails.PENDING_WAITING_PAYMENT
    }

    func isContingency() -> Bool {
        return self.statusDetail == PXPayment.StatusDetails.PENDING_CONTINGENCY
    }

    func isAccountMoney() -> Bool {
        return self.paymentData?.getPaymentMethod()?.isAccountMoney ?? false
    }
}

// MARK: Congrats logic
extension PaymentResult {
    func isAccepted() -> Bool {
        return isApproved() || isInProcess() || isPending()
    }

    func isWarning() -> Bool {
        if !isRejected() {
            return false
        }
        if warningStatusDetails.contains(statusDetail) {
            return true
        }
        return false
    }

    func isError() -> Bool {
        if !isRejected() {
            return false
        }
        return !isWarning()
    }
}
