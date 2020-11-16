import Foundation

public struct RemoteSiteDesign: Codable {
    public let slug: String
    public let title: String
    public let demoURL: String
    public let screenshot: String?
    public let themeSlug: String?
    public let segmentID: Int64?

    enum CodingKeys: String, CodingKey {
        case slug
        case title
        case demoURL = "demo_url"
        case screenshot
        case themeSlug = "theme"
        case segmentID = "segment_id"
    }

    public init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        slug = try map.decode(String.self, forKey: .slug)
        title = try map.decode(String.self, forKey: .title)
        demoURL = try map.decode(String.self, forKey: .demoURL)
        screenshot = try? map.decode(String.self, forKey: .screenshot)
        themeSlug = try? map.decode(String.self, forKey: .themeSlug)
        segmentID = try? map.decode(Int64.self, forKey: .segmentID)
    }
}
