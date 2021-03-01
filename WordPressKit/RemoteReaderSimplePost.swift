import Foundation

struct RemoteReaderSimplePostEnvelope: Decodable {
    let posts: [RemoteReaderSimplePost]
}

public struct RemoteReaderSimplePost: Decodable {
    public let postID: Int
    public let siteID: Int
    public let isFollowing: Bool
    public let title: String
    public let author: RemoteReaderSimplePostAuthor
    public let excerpt: String
    public let siteName: String
    public let featuredImageUrl: String?
    public let featuredMedia: RemoteReaderSimplePostFeaturedMedia?

    private enum CodingKeys: String, CodingKey {
        case postID = "ID"
        case siteID = "site_ID"
        case isFollowing = "is_following"
        case title
        case author
        case excerpt
        case siteName = "site_name"
        case featuredImageUrl = "featured_image"
        case featuredMedia = "featured_media"
    }
}

public struct RemoteReaderSimplePostAuthor: Decodable {
    public let name: String
}

public struct RemoteReaderSimplePostFeaturedMedia: Decodable {
    public let uri: String
}
