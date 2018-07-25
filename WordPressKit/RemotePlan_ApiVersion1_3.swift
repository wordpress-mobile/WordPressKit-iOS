import Foundation

/// This is for getPlansForSite service in api version v1.3.
/// There are some huge differences between v1.3 and v1.2 so a new
/// class is created for v1.3.
@objc public class RemotePlan_ApiVersion1_3: NSObject, Codable {
    var autoRenew: Bool?
    var freeTrial: Bool?
    var interval: Int?
    var rawDiscount: Int?
    var rawPrice: Int?
    var hasDomainCredit: Bool?
    var currentPlan: Bool?
    var userIsOwner: Bool?
    var isDomainUpgrade: Bool?
    @objc var autoRenewDate: Date?
    @objc var currencyCode: String?
    @objc var discountReason: String?
    @objc var expiry: Date?
    @objc var formattedDiscount: String?
    @objc var formattedOriginalPrice: String?
    @objc var formattedPrice: String?
    @objc var planID: String?
    @objc var productName: String?
    @objc var productSlug: String?
    @objc var subscribedDate: Date?
    @objc var userFacingExpiry: Date?
    
    @objc var isAutoRenew: Bool {
        return autoRenew ?? false
    }
    
    @objc var isCurrentPlan: Bool {
        return currentPlan ?? false
    }
    
    @objc var isFreeTrial: Bool {
        return freeTrial ?? false
    }
    
    @objc var doesHaveDomainCredit: Bool {
        return hasDomainCredit ?? false
    }
}
