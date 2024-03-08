import Foundation

public final class RemotePostUpdateParameters: NSObject, Encodable {
    public var ifNotModifiedSince: Date?

    public var status: String??
    public var authorID: String??
    public var date: Date??
    public var title: String??
    public var content: String??
    public var password: String??
    public var excerpt: String??
    public var slug: String??
    public var format: String??
    public var categoryIDs: [String]?
    public var tags: [String]?
    public var parentPostID: String??
    public var featuredImageID: String??
    public var isSticky: Bool?

    // Makes it compatible with Objetive-C.
    @objc public func makeWordPressCOMParameters() -> [String: Any]? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(NSDate.rfc3339DateFormatter())
        guard let data = try? encoder.encode(RemotePostUpdateParametersWordPressComEncoder(parameters: self)),
              let object = try? JSONSerialization.jsonObject(with: data) else {
            return nil // Should never happen
        }
        return object as? [String: Any]
    }
}

private struct RemotePostUpdateParametersWordPressComEncoder: Encodable {
    let parameters: RemotePostUpdateParameters

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)
        try container.encodeIfPresent(parameters.ifNotModifiedSince, forKey: "if_not_modified_since")
        try container.encodeIfPresent(parameters.status, forKey: "status")
        try container.encodeIfPresent(parameters.title, forKey: "title")
        try container.encodeIfPresent(parameters.content, forKey: "content")
        try container.encodeIfPresent(parameters.date, forKey: "date")
        try container.encodeIfPresent(parameters.authorID, forKey: "author")
        try container.encodeIfPresent(parameters.password, forKey: "password")
        try container.encodeIfPresent(parameters.excerpt, forKey: "excerpt")
        try container.encodeIfPresent(parameters.slug, forKey: "slug")
        try container.encodeIfPresent(parameters.categoryIDs, forKey: "categories_by_id")
        if let tags = parameters.tags {
            try container.encode([
                "terms": [
                    "post_tag": tags
                ]
            ], forKey: "terms")
        }
        try container.encodeIfPresent(parameters.format, forKey: "format")
        if let parentPostID = parameters.parentPostID {
            try container.encodeIfPresent(parentPostID ?? "false", forKey: "parent")
        }
        try container.encodeIfPresent(parameters.featuredImageID, forKey: "featured_image")
        try container.encodeIfPresent(parameters.isSticky, forKey: "sticky")
    }
}
