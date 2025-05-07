import Foundation

public class SubscribersServiceRemote: ServiceRemoteWordPressComREST {

    // MARK: GET Subscribers (Paginated List)

    public struct GetSubscribersParameters: Hashable {
        public var sortField: SortField?
        public var sortOrder: SortOrder?
        public var subscriptionTypeFilter: FilterSubscriptionType?
        public var paymentTypeFilter: FilterPaymentType?

        @frozen public enum SortField: String, CaseIterable {
            case dateSubscribed = "date_subscribed"
            case email = "email"
            case name = "name"
            case plan = "plan"
            case subscriptionStatus = "subscription_status"
        }

        @frozen public enum SortOrder: String, CaseIterable {
            case ascending = "asc"
            case descending = "dsc"
        }

        @frozen public enum FilterSubscriptionType: String, CaseIterable {
            case email = "email_subscriber"
            case reader = "reader_subscriber"
            case unconfirmed = "unconfirmed_subscriber"
            case blocked = "blocked_subscriber"
        }

        @frozen public enum FilterPaymentType: String, CaseIterable {
            case free
            case paid
        }

        var filters: [String] {
            [subscriptionTypeFilter?.rawValue, paymentTypeFilter?.rawValue].compactMap { $0 }
        }

        public init(sortField: SortField? = nil, sortOrder: SortOrder? = nil, subscriptionTypeFilter: FilterSubscriptionType? = nil, paymentTypeFilter: FilterPaymentType? = nil) {
            self.sortField = sortField
            self.sortOrder = sortOrder
            self.subscriptionTypeFilter = subscriptionTypeFilter
            self.paymentTypeFilter = paymentTypeFilter
        }
    }

    public struct GetSubscribersResponse: Decodable {
        public var total: Int
        public var pages: Int
        public var page: Int
        public var subscribers: [Subscriber]

        public struct Subscriber: Decodable {
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
    }

    /// Gets the list of the site subscribers, including WordPress.com users and
    /// email subscribers.
    public func getSubscribers(
        siteID: Int,
        page: Int? = nil,
        perPage: Int? = 25,
        parameters: GetSubscribersParameters = .init(),
        search: String? = nil,
    ) async throws -> GetSubscribersResponse {
        let url = self.path(forEndpoint: "sites/\(siteID)/subscribers", withVersion: ._2_0)
        var query: [String: Any] = [:]
        if let page {
            query["page"] = page
        }
        if let perPage {
            query["per_page"] = perPage
        }
        if let sortField = parameters.sortField {
            query["sort"] = sortField.rawValue
        }
        if let sortOrder = parameters.sortOrder {
            query["sort_order"] = sortOrder.rawValue
        }
        if !parameters.filters.isEmpty {
            query["filters"] = parameters.filters
        }
        if let search, !search.isEmpty {
            query["search"] = search
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.supportMultipleDateFormats

        return try await wordPressComRestApi.perform(
            .get,
            URLString: url,
            parameters: query,
            jsonDecoder: decoder,
            type: GetSubscribersResponse.self
        ).get().body
    }

    // MARK: GET Subscriber (Individual Details)

    public struct GetSubscriberDetailsResponse: Decodable {
        public let subscriberID: Int
        public let dotComUserID: Int
        public let displayName: String?
        public let avatar: String?
        public let emailAddress: String?
        public let dateSubscribed: Date
        public let isEmailSubscriptionEnabled: Bool
        public let subscriptionStatus: String?
        public let country: Country?

        public struct Country: Decodable {
            public var code: String?
            public var name: String?
        }

        private enum CodingKeys: String, CodingKey {
            case subscriberID = "subscription_id"
            case dotComUserID = "user_id"
            case displayName = "display_name"
            case emailAddress = "email_address"
            case avatar
            case dateSubscribed = "date_subscribed"
            case isEmailSubscriptionEnabled = "is_email_subscriber"
            case subscriptionStatus = "subscription_status"
            case country
        }
    }

    /// Gets stats for the given subscriber.
    ///
    /// Example: https://public-api.wordpress.com/wpcom/v2/sites/239619264/subscribers/individual?subscription_id=907116368
    public func getSubsciberDetails(
        siteID: Int,
        subscriberID: Int
    ) async throws -> GetSubscriberDetailsResponse {
        let url = self.path(forEndpoint: "sites/\(siteID)/subscribers/individual", withVersion: ._2_0)
        let query: [String: Any] = [
            "subscription_id": subscriberID
        ]

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.supportMultipleDateFormats

        return try await wordPressComRestApi.perform(
            .get,
            URLString: url,
            parameters: query,
            jsonDecoder: decoder,
            type: GetSubscriberDetailsResponse.self
        ).get().body
    }

    public struct GetSubscriberStatsResponse: Decodable {
        public var emailsSent: Int
        public var uniqueOpens: Int
        public var uniqueClicks: Int
    }

    /// Gets stats for the given subscriber.
    ///
    /// Example: https://public-api.wordpress.com/wpcom/v2/sites/239619264/individual-subscriber-stats?subscription_id=907116368
    public func getSubsciberStats(
        siteID: Int,
        subscriberID: Int
    ) async throws -> GetSubscriberStatsResponse {
        let url = self.path(forEndpoint: "sites/\(siteID)/individual-subscriber-stats", withVersion: ._2_0)
        let query: [String: Any] = [
            "subscription_id": subscriberID
        ]
        return try await wordPressComRestApi.perform(
            .get,
            URLString: url,
            parameters: query,
            jsonDecoder: JSONDecoder.apiDecoder,
            type: GetSubscriberStatsResponse.self
        ).get().body
    }
}
