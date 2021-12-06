import UIKit

// payment_option
open class PXAmountConfiguration: NSObject, Codable {
    open var selectedPayerCostIndex: Int?
    open var selectedPayerCost: PXPayerCost? {
        get {
            if let remotePayerCosts = payerCosts, let selectedIndex = selectedPayerCostIndex, remotePayerCosts.indices.contains(selectedIndex) {
                return remotePayerCosts[selectedIndex]
            }
            return nil
        }
    }
    open var payerCosts: [PXPayerCost]?
    open var splitConfiguration: PXSplitConfiguration?
    open var discountToken: Int64?
    open var amount: Double?
    open var taxFreeAmount: Double?
    open var noDiscountAmount: Double?

    public init(selectedPayerCostIndex: Int?, payerCosts: [PXPayerCost]?, splitConfiguration: PXSplitConfiguration?, discountToken: Int64?, amount: Double?, taxFreeAmount: Double?, noDiscountAmount: Double?) {
        self.selectedPayerCostIndex = selectedPayerCostIndex
        self.payerCosts = payerCosts
        self.splitConfiguration = splitConfiguration
        self.discountToken = discountToken
        self.amount = amount
        self.taxFreeAmount = taxFreeAmount
        self.noDiscountAmount = noDiscountAmount
    }

    public enum PXPayerCostConfiguration: String, CodingKey {
        case selectedPayerCostIndex = "selected_payer_cost_index"
        case payerCost = "payer_costs"
        case split
        case discountToken = "discount_token"
        case amount
        case taxFreeAmount = "tax_free_amount"
        case noDiscountAmount = "no_discount_amount"
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PXPayerCostConfiguration.self)
        let payerCosts: [PXPayerCost]? = try container.decodeIfPresent([PXPayerCost].self, forKey: .payerCost)
        let selectedPayerCostIndex: Int? = try container.decodeIfPresent(Int.self, forKey: .selectedPayerCostIndex)
        let splitConfiguration: PXSplitConfiguration? = try container.decodeIfPresent(PXSplitConfiguration.self, forKey: .split)
        let discountToken: Int64? = try container.decodeIfPresent(Int64.self, forKey: .discountToken)
        let amount: Double? = try container.decodeIfPresent(Double.self, forKey: .amount)
        let taxFreeAmount: Double? = try container.decodeIfPresent(Double.self, forKey: .taxFreeAmount)
        let noDiscountAmount: Double? = try container.decodeIfPresent(Double.self, forKey: .noDiscountAmount)
        self.init(selectedPayerCostIndex: selectedPayerCostIndex, payerCosts: payerCosts, splitConfiguration: splitConfiguration, discountToken: discountToken, amount: amount, taxFreeAmount: taxFreeAmount, noDiscountAmount: noDiscountAmount)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PXPayerCostConfiguration.self)
        try container.encodeIfPresent(self.payerCosts, forKey: .payerCost)
        try container.encodeIfPresent(self.selectedPayerCostIndex, forKey: .selectedPayerCostIndex)
        try container.encodeIfPresent(self.splitConfiguration, forKey: .split)
        try container.encodeIfPresent(self.discountToken, forKey: .discountToken)
        try container.encodeIfPresent(self.amount, forKey: .amount)
        try container.encodeIfPresent(self.taxFreeAmount, forKey: .taxFreeAmount)
        try container.encodeIfPresent(self.noDiscountAmount, forKey: .noDiscountAmount)
    }

    open func toJSONString() throws -> String? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    open func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}
