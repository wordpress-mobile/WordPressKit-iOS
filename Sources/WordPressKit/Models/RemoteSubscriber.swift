import Foundation

public struct RemoteSubscriber: Decodable {
    public let userID: Int
    public let subscriptionID: Int
    public let emailAddress: String?
    public let dateSubscribed: Date
    public let isEmailSubscriber: Bool
    public let subscriptionStatus: String?
    public let displayName: String?
    public let avatar: String?

    private enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case subscriptionID = "subscription_id"
        case emailAddress = "email_address"
        case dateSubscribed = "date_subscribed"
        case isEmailSubscriber = "is_email_subscriber"
        case subscriptionStatus = "subscription_status"
        case displayName = "display_name"
        case avatar
    }
}
