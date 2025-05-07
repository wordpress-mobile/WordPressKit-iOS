import Foundation

public class SubscribersServiceRemote: ServiceRemoteWordPressComREST {

    // MARK: GET

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
        public var subscribers: [RemoteSubscriber]
    }

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
}
