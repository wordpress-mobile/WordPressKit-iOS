import Foundation

/// A limited representation of the users Jetpack credentials
struct JetpackScanCredentials: Decodable {
    var host: String
    var port: Int
    var user: String
    var path: String
    var type: String
    var role: String
    var stillValid: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        host = try container.decode(String.self, forKey: .host)
        port = try container.decode(Int.self, forKey: .port)
        user = try container.decode(String.self, forKey: .user)
        path = try container.decode(String.self, forKey: .path)
        type = try container.decode(String.self, forKey: .type)
        role = try container.decode(String.self, forKey: .role)
        stillValid = try container.decode(Bool.self, forKey: .stillValid)
    }

     enum CodingKeys: String, CodingKey {
        case host
        case port
        case user
        case path
        case type
        case role
        case stillValid = "still_valid"
    }
}
