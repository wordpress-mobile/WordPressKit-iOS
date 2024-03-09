import Foundation

extension PostServiceRemoteREST: PostServiceRemoteExtended {
    public func patchPost(withID postID: Int, changes: RemotePostUpdateParameters) async throws -> RemotePost {
        let path = self.path(forEndpoint: "sites/\(siteID)/posts/\(postID)?context=edit", withVersion: ._1_2)
        let parameters = RemotePostUpdateParametersWordPressComEncoder.makeParameters(for: changes)

        return try await withUnsafeThrowingContinuation { continuation in
            wordPressComRestApi.POST(path, parameters: parameters) { responseObject, _ in
                if let dictionary = responseObject as? [AnyHashable: Any],
                   let post = PostServiceRemoteREST.remotePost(fromJSONDictionary: dictionary) {
                    continuation.resume(returning: post)
                } else {
                    continuation.resume(throwing: URLError(.unknown)) // Should never happen
                }
            } failure: { error, _ in
                continuation.resume(throwing: error)
            }
        }
    }
}

private struct RemotePostUpdateParametersWordPressComEncoder: Encodable {
    let parameters: RemotePostUpdateParameters

    static func makeParameters(for parameters: RemotePostUpdateParameters) -> [String: AnyObject]? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(NSDate.rfc3339DateFormatter())
        guard let data = try? encoder.encode(RemotePostUpdateParametersWordPressComEncoder(parameters: parameters)),
              let object = try? JSONSerialization.jsonObject(with: data) else {
            return nil // Should never happen
        }
        return object as? [String: AnyObject]
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)
        try container.encodeIfPresent(parameters.ifNotModifiedSince, forKey: "if_not_modified_since")
        try container.encodeIfPresent(parameters.status, forKey: "status")
        try container.encodeIfPresent(parameters.date, forKey: "date")
        try container.encodeIfPresent(parameters.authorID, forKey: "author")
        try container.encodeIfPresent(parameters.title, forKey: "title")
        try container.encodeIfPresent(parameters.content, forKey: "content")
        try container.encodeIfPresent(parameters.password, forKey: "password")
        try container.encodeIfPresent(parameters.excerpt, forKey: "excerpt")
        try container.encodeIfPresent(parameters.slug, forKey: "slug")
        try container.encodeIfPresent(parameters.featuredImageID, forKey: "featured_image")

        // Pages
        if let parentPageID = parameters.parentPageID {
            try container.encodeIfPresent(parentPageID, forKey: "parent")
        }

        // Posts
        try container.encodeIfPresent(parameters.format, forKey: "format")
        if let tags = parameters.tags {
            try container.encode([
                "terms": [
                    "post_tag": tags
                ]
            ], forKey: "terms")
        }
        try container.encodeIfPresent(parameters.categoryIDs, forKey: "categories_by_id")
        try container.encodeIfPresent(parameters.isSticky, forKey: "sticky")
    }
}
