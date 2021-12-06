import Foundation

extension PXAmountHelper {
    func getDiscountForTracking() -> [String: Any]? {
        guard let discount = discount, let campaign = campaign else {
            return nil
        }

        var dic: [String: Any] = [:]
        dic["percent_off"] = discount.percentOff
        dic["amount_off"] = discount.amountOff
        dic["coupon_amount"] = discount.couponAmount
        dic["max_coupon_amount"] = campaign.maxCouponAmount
        dic["max_redeem_per_user"] = campaign.maxRedeemPerUser
        dic["campaign_id"] = campaign.id
        return dic
    }
}
