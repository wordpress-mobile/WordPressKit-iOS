import Foundation

public struct RemoteSiteDesign: Codable {
    public let slug: String
    public let title: String
    public let demoURL: String
    public let thumbnail: String?
    public let themeSlug: String?

    enum CodingKeys: String, CodingKey {
        case slug
        case title
        case demoURL = "demo_url"
        case thumbnail = "screenshot"
        case themeSlug = "theme"
    }

    public init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        slug = try map.decode(String.self, forKey: .slug)
        title = try map.decode(String.self, forKey: .title)
        demoURL = try map.decode(String.self, forKey: .demoURL)
        thumbnail = try? map.decode(String.self, forKey: .thumbnail)
        themeSlug = try? map.decode(String.self, forKey: .themeSlug)
    }
}
