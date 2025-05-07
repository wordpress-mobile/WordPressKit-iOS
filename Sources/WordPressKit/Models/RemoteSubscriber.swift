import Foundation

public struct RemoteSubscriber: Decodable {
    public let subscriberID: Int
    public let dotComUserID: Int
    public let displayName: String?
    public let avatar: String?
    public let emailAddress: String?
    public let dateSubscribed: Date
    public let isEmailSubscriptionEnabled: Bool
    public let subscriptionStatus: String?

    private enum CodingKeys: String, CodingKey {
        case subscriberID = "subscription_id"
        case dotComUserID = "user_id"
        case displayName = "display_name"
        case emailAddress = "email_address"
        case avatar
        case dateSubscribed = "date_subscribed"
        case isEmailSubscriptionEnabled = "is_email_subscriber"
        case subscriptionStatus = "subscription_status"
    }
}
