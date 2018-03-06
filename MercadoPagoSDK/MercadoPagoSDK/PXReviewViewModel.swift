//
//  PXReviewViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 27/2/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

final class PXReviewViewModel: NSObject {
    
    static let ERROR_DELTA = 0.001
    public static var CUSTOMER_ID = ""
    
    var preference: CheckoutPreference?
    var paymentData: PaymentData!
    var paymentOptionSelected: PaymentMethodOption
    var discount: DiscountCoupon?
    
    var reviewScreenPreference: ReviewScreenPreference!
    
    public init(checkoutPreference: CheckoutPreference, paymentData: PaymentData, paymentOptionSelected: PaymentMethodOption, discount: DiscountCoupon? = nil, reviewScreenPreference: ReviewScreenPreference = ReviewScreenPreference()) {
        PXReviewViewModel.CUSTOMER_ID = ""
        self.preference = checkoutPreference
        self.paymentData = paymentData
        self.discount = discount
        self.paymentOptionSelected = paymentOptionSelected
        self.reviewScreenPreference = reviewScreenPreference
        super.init()
    }
}

// MARK: - Logic.
extension PXReviewViewModel {
    
    // Logic.
    func isPaymentMethodSelectedCard() -> Bool {
        return self.paymentData.hasPaymentMethod() && self.paymentData.getPaymentMethod()!.isCard
    }
    
    func isPaymentMethodSelected() -> Bool {
        return paymentData.hasPaymentMethod()
    }
    
    func isUserLogged() -> Bool {
        return !String.isNullOrEmpty(MercadoPagoContext.payerAccessToken())
    }
    
    func shouldShowTermsAndCondition() -> Bool {
        return !isUserLogged()
    }
    
    func shouldShowInstallmentSummary() -> Bool {
        return isPaymentMethodSelectedCard() && self.paymentData.getPaymentMethod()!.paymentTypeId != "debit_card" && paymentData.hasPayerCost() && paymentData.getPayerCost()!.installments != 1
    }
    
    func shouldDisplayNoRate() -> Bool {
        return self.paymentData.hasPayerCost() && !self.paymentData.getPayerCost()!.hasInstallmentsRate() && self.paymentData.getPayerCost()!.installments != 1
    }
    
    func hasPayerCostAddionalInfo() -> Bool {
        return self.paymentData.hasPayerCost() && self.paymentData.getPayerCost()!.getCFTValue() != nil && self.paymentData.getPayerCost()!.installments != 1
    }
    
    func hasConfirmAdditionalInfo() -> Bool {
        return hasPayerCostAddionalInfo() || needUnlockCardComponent()
    }
    
    func needUnlockCardComponent() -> Bool {
        return getUnlockLink() != nil
    }
}

// MARK: - Getters
extension PXReviewViewModel {
    
    func getTotalAmount() -> Double {
        if let payerCost = paymentData.getPayerCost() {
            return payerCost.totalAmount
        }
        if MercadoPagoCheckoutViewModel.flowPreference.isDiscountEnable(), let discount = paymentData.discount {
            return discount.newAmount()
        }
        return self.preference!.getAmount()
    }
    
    func getUnlockLink() -> URL? {
        let path = MercadoPago.getBundle()!.path(forResource: "UnlockCardLinks", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: path!)
        let site = MercadoPagoContext.getSite()
        guard let issuerID = self.paymentData.getIssuer()?._id else {
            return nil
        }
        let searchString: String = site + "_" + "\(issuerID)"
        
        if let link = dictionary?.value(forKey: searchString) as? String {
            return URL(string:link)
        }
        
        return nil
    }
    
    func getClearPaymentData() -> PaymentData {
        let newPaymentData: PaymentData = paymentData
        newPaymentData.clearCollectedData()
        return newPaymentData
    }
    
    func getFloatingConfirmViewHeight() -> CGFloat {
        return 82 + PXLayout.getSafeAreaBottomInset()/2
    }
    
    func getSummaryViewModel(amount: Double) -> Summary {
        
        var summary: Summary
        
        guard let choPref = self.preference else {
            return Summary(details: [:])
        }
        
        // TODO: Check Double type precision.
        if abs(amount - self.reviewScreenPreference.getSummaryTotalAmount()) <= PXReviewViewModel.ERROR_DELTA {
            summary = Summary(details: self.reviewScreenPreference.details)
            if self.reviewScreenPreference.details[SummaryType.PRODUCT]?.details.count == 0 { //Si solo le cambio el titulo a Productos
                summary.addAmountDetail(detail: SummaryItemDetail(amount: choPref.getAmount()), type: SummaryType.PRODUCT)
            }
        } else {
            summary = getDefaultSummary()
            if self.reviewScreenPreference.details[SummaryType.PRODUCT]?.details.count == 0 { //Si solo le cambio el titulo a Productos
                if let title = self.reviewScreenPreference.details[SummaryType.PRODUCT]?.title {
                    summary.updateTitle(type: SummaryType.PRODUCT, oneWordTitle:title)
                }
            }
        }
        
        if let discount = self.paymentData.discount {
            let discountAmountDetail = SummaryItemDetail(name: discount.description, amount: Double(discount.coupon_amount)!)
            
            if summary.details[SummaryType.DISCOUNT] != nil {
                summary.addAmountDetail(detail: discountAmountDetail, type: SummaryType.DISCOUNT)
            } else {
                let discountSummaryDetail = SummaryDetail(title: self.reviewScreenPreference.summaryTitles[SummaryType.DISCOUNT]!, detail: discountAmountDetail)
                summary.addSummaryDetail(summaryDetail:discountSummaryDetail, type: SummaryType.DISCOUNT)
            }
            summary.details[SummaryType.DISCOUNT]?.titleColor = ThemeManager.shared.getTheme().highlightedLabelTintColor()
            summary.details[SummaryType.DISCOUNT]?.amountColor = ThemeManager.shared.getTheme().highlightedLabelTintColor()
        }
        if let payerCost = self.paymentData.payerCost {
            let interest = payerCost.totalAmount - amount
            if interest > 0 {
                let interestAmountDetail = SummaryItemDetail(amount: interest)
                if summary.details[SummaryType.CHARGE] != nil {
                    summary.addAmountDetail(detail: interestAmountDetail, type: SummaryType.CHARGE)
                } else {
                    let interestSummaryDetail = SummaryDetail(title: self.reviewScreenPreference.summaryTitles[SummaryType.CHARGE]!, detail: interestAmountDetail)
                    summary.addSummaryDetail(summaryDetail:interestSummaryDetail, type: SummaryType.CHARGE)
                }
            }
        }
        if let disclaimer = self.reviewScreenPreference.disclaimer {
            summary.disclaimer = disclaimer
            summary.disclaimerColor = self.reviewScreenPreference.disclaimerColor
        }
        return summary
    }
    
    func getDefaultSummary() -> Summary {
        
        guard let choPref = self.preference else {
            return Summary(details: [:])
        }
        
        let productSummaryDetail = SummaryDetail(title: self.reviewScreenPreference.summaryTitles[SummaryType.PRODUCT]!, detail: SummaryItemDetail(amount: choPref.getAmount()))
        
        return Summary(details:[SummaryType.PRODUCT: productSummaryDetail])
    }
}

// MARK: - Components builders.
extension PXReviewViewModel {
    
    func buildPaymentMethodComponent(withAction:PXComponentAction?) -> PXPaymentMethodComponent {
        
        let pm = paymentData!.paymentMethod!
        
        let image = buildPaymentMethodIcon(paymentMethod: pm)
        var amountTitle = ""
        let paymentMethodName = pm.name ?? ""
        
        if pm.isCard {
            if let lastFourDigits = (paymentData.token?.lastFourDigits) {
                amountTitle = paymentMethodName + " " + "terminada en ".localized + lastFourDigits
            }
        } else {
            amountTitle = paymentMethodName
        }
        
        let amountDetail = "HSBC"
        
        let props = PXPaymentMethodProps(paymentMethodIcon: image, amountTitle: amountTitle, amountDetail: amountDetail, paymentMethodDescription: nil, paymentMethodDetail: nil, disclaimer: nil, action: withAction)
        
        return PXPaymentMethodComponent(props: props)
    }

    
    fileprivate func buildPaymentMethodIcon(paymentMethod: PaymentMethod) -> UIImage? {
        let defaultColor = paymentMethod.paymentTypeId == PaymentTypeId.ACCOUNT_MONEY.rawValue && paymentMethod.paymentTypeId != PaymentTypeId.PAYMENT_METHOD_PLUGIN.rawValue
        var paymentMethodImage: UIImage? =  MercadoPago.getImageForPaymentMethod(withDescription: paymentMethod._id, defaultColor: defaultColor)
        // Retrieve image for payment plugin or any external payment method.
        if paymentMethod.paymentTypeId == PaymentTypeId.PAYMENT_METHOD_PLUGIN.rawValue {
            paymentMethodImage = paymentMethod.getImageForExtenalPaymentMethod()
        }
        return paymentMethodImage
    }
}

// MARK: Item component
extension PXReviewViewModel {

    func buildItemComponents() -> [PXItemComponent] {
        var pxItemComponents = [PXItemComponent]()
        if reviewScreenPreference.isItemsEnable() { // Items can be disable
            for item in self.preference!.items {
                if let itemComponent = buildItemComponent(item: item) {
                    pxItemComponents.append(itemComponent)
                }
            }
        }
        return pxItemComponents
    }

    fileprivate func shouldShowQuantity(item: Item) -> Bool {
        return item.quantity > 1 // Quantity must not be shown if it is 1
    }

    fileprivate func shouldShowPrice(item: Item) -> Bool {
        return preference!.hasMultipleItems() || item.quantity > 1 // Price must not be shown if quantity is 1 and there are no more products
    }

    fileprivate func buildItemComponent(item: Item) -> PXItemComponent? {
        if String.isNullOrEmpty(item._description) && !preference!.hasMultipleItems() { // Item must not be shown if it has no description and it's one
            return nil
        }

        let itemQuantiy = getItemQuantity(item: item)
        let itemPrice = getItemPrice(item: item)
        let itemTitle = getItemTitle(item: item)
        let itemDescription = getItemDescription(item: item)

        let itemProps = PXItemComponentProps(imageURL: item.pictureUrl, title: itemTitle, description: itemDescription, quantity: itemQuantiy, unitAmount: itemPrice)
        return PXItemComponent(props: itemProps)
    }
}

// MARK: Item getters
extension PXReviewViewModel {
    fileprivate func getItemTitle(item: Item) -> String? { // Return item real title if it has multiple items, if not return description
        if preference!.hasMultipleItems() {
            return item.title
        }
        return item._description
    }

    fileprivate func getItemDescription(item: Item) -> String? { // Returns only if it has multiple items
        if preference!.hasMultipleItems() {
            return item._description
        }
        return nil
    }

    fileprivate func getItemQuantity(item: Item) -> Int? {
        if  !shouldShowQuantity(item: item) {
            return nil
        }
        return item.quantity
    }

    fileprivate func getItemPrice(item: Item) -> Double? {
        if  !shouldShowPrice(item: item) {
            return nil
        }
        return item.unitPrice
    }
}
extension PXReviewViewModel {
    func buildSummaryComponent(width: CGFloat) -> PXSummaryComponent {
        
        var customTitle = "Productos".localized
        var totalAmount: Double = 0
        
        if let tAmount = self.preference?.getAmount() {
            totalAmount = tAmount
        }
        
        if let pref = preference, pref.items.count == 1 {
            if let itemTitle = pref.items.first?.title, itemTitle.count > 0 {
                customTitle = itemTitle
            }
        }
        
        let props = PXSummaryComponentProps(summaryViewModel: getSummaryViewModel(amount: totalAmount), paymentData: paymentData, total: totalAmount, width: width, customTitle: customTitle, textColor: ThemeManager.shared.getTheme().boldLabelTintColor(), backgroundColor: ThemeManager.shared.getTheme().highlightBackgroundColor())
        
        return PXSummaryComponent(props: props)
    }
    
    func buildTitleComponent() -> PXReviewTitleComponent {
        let props = PXReviewTitleComponentProps(titleColor: ThemeManager.shared.getTheme().boldLabelTintColor(), backgroundColor: ThemeManager.shared.getTheme().highlightBackgroundColor())
        return PXReviewTitleComponent(props: props)
    }

}

// MARK: - Custom cells.
// TODO: Remove.
extension PXReviewViewModel {
    
    // Custom cells.
    func numberOfCustomAdditionalCells() -> Int {
        if !Array.isNullOrEmpty(reviewScreenPreference.additionalInfoCells) {
            return reviewScreenPreference.additionalInfoCells.count
        }
        return 0
    }
    
    func numberOfCustomItemCells() -> Int {
        if hasCustomItemCells() {
            return reviewScreenPreference.customItemCells.count
        }
        return 0
    }
    
    func hasCustomItemCells() -> Bool {
        return !Array.isNullOrEmpty(reviewScreenPreference.customItemCells)
    }
}
