import Foundation

/// A limited representation of the users Jetpack credentials
public struct JetpackScanCredentials: Decodable {
    public let host: String
    public let port: Int
    public let user: String
    public let path: String
    public let type: String
    public let role: String
    public let stillValid: Bool

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        host = try container.decode(String.self, forKey: .host)
        port = try container.decode(Int.self, forKey: .port)
        user = try container.decode(String.self, forKey: .user)
        path = try container.decode(String.self, forKey: .path)
        type = try container.decode(String.self, forKey: .type)
        role = try container.decode(String.self, forKey: .role)
        stillValid = try container.decode(Bool.self, forKey: .stillValid)
    }

    private enum CodingKeys: String, CodingKey {
        case host
        case port
        case user
        case path
        case type
        case role
        case stillValid = "still_valid"
    }
}
