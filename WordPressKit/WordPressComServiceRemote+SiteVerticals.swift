import Foundation

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
