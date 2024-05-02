import Foundation

struct SubscribersData: Codable {
    let total: Int
    let pages: Int
    let page: Int
    let perPage: Int
    let subscribers: [SiteSubscriber]

    enum CodingKeys: String, CodingKey {
        case total
        case pages
        case page
        case perPage = "per_page"
        case subscribers
    }
}

public struct SiteSubscriber: Codable {
    public let userID: Int
    public let subscriptionID: Int
    public let emailAddress: String
    public let dateSubscribed: Date
    public let avatarUrl: URL?
    public let displayName: String
    public let url: String?

    private enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case subscriptionID = "subscription_id"
        case emailAddress = "email_address"
        case dateSubscribed = "date_subscribed"
        case avatarUrl = "avatar"
        case displayName = "display_name"
        case url
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userID = try container.decode(Int.self, forKey: .userID)
        self.subscriptionID = try container.decode(Int.self, forKey: .subscriptionID)
        self.emailAddress = try container.decode(String.self, forKey: .emailAddress)
        self.avatarUrl = try? container.decodeIfPresent(URL.self, forKey: .avatarUrl)
        self.displayName = try container.decode(String.self, forKey: .displayName)
        self.url = try? container.decodeIfPresent(String.self, forKey: .url)

        let dateString = try container.decode(String.self, forKey: .dateSubscribed)
        if let date = ISO8601DateFormatter().date(from: dateString) {
            self.dateSubscribed = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .dateSubscribed, in: container, debugDescription: "Date string does not match format expected by formatter.")
        }
    }
}
