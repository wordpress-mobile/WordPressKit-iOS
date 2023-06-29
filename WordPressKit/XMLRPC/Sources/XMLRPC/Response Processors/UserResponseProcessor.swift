import Foundation
import wpxmlrpc

public struct WPUser {
    public let id: String
    public let username: String
    public let firstName: String
    public let lastName: String
    public let nickname: String
    public let displayName: String
    public let email: String
    public let bio: String
    public let url: URL
    public let registered: Date
    public let nicename: String
}

public struct UserResponseProcessor {

    public init() {}

    public func process(_ data: Data) throws -> WPUser? {
        guard let decoder = WPXMLRPCDecoder(data: data) else {
            throw CocoaError(.coderInvalidValue)
        }

        try decoder.checkResponse()

        guard let dictionary = decoder.object() as? XMLRPCDictionary else {
            return nil
        }

        return try WPUser(
            id: dictionary.stringValue(for: "user_id"),
            username: dictionary.stringValue(for: "username"),
            firstName: dictionary.stringValue(for: "first_name"),
            lastName: dictionary.stringValue(for: "last_name"),
            nickname: dictionary.stringValue(for: "nickname"),
            displayName: dictionary.stringValue(for: "display_name"),
            email: dictionary.stringValue(for: "email"),
            bio: dictionary.stringValue(for: "bio"),
            url: URL(string: "google.com")!,
            registered: dictionary.dateValue(for: "registered"),
            nicename: dictionary.stringValue(for: "nicename")
        )
    }
}
