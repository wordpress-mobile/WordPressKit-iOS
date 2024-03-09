import Foundation

/// Represents a partial update to be applied to a post.
public struct RemotePostUpdateParameters {
    public var ifNotModifiedSince: Date?

    public var status: String?
    public var date: Date?
    public var authorID: Int??
    public var title: String??
    public var content: String??
    public var password: String??
    public var excerpt: String??
    public var slug: String??
    public var featuredImageID: Int??

    // Pages
    public var parentPageID: Int??

    // Posts
    public var format: String??
    public var tags: [String]?
    public var categoryIDs: [Int]?
    public var isSticky: Bool?

    public init() {}
}
