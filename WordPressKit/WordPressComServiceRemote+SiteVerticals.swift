import Foundation

// MARK: - SiteVerticalsRequest

/// Allows the construction of a request for site verticals.
///
/// NB: The default limit (5) applies to the number of results returned by the service. If a search with limit n evinces no exact match, (n - 1) server-unique results are returned.
///
public struct SiteVerticalsRequest: Encodable {
    public let search: String
    public let limit: Int

    public init(search: String, limit: Int = 5) {
        self.search = search
        self.limit = limit
    }
}

// MARK: - SiteVertical(s) : Response

/// Models a Site Vertical
///
public struct SiteVertical: Decodable, Equatable {
    public let identifier: String   // vertical IDs mix parent/child taxonomy (String)
    public let title: String
    public let isNew: Bool

    public init(identifier: String,
                title: String,
                isNew: Bool) {

        self.identifier = identifier
        self.title = title
        self.isNew = isNew
    }

    private enum CodingKeys: String, CodingKey {
        case identifier = "vertical_id"
        case title      = "vertical_name"
        case isNew      = "is_user_input_vertical"
    }
}
