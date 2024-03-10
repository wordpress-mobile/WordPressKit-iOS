import Foundation

extension PostServiceRemoteREST: PostServiceRemoteExtended {
    public func createPost(with parameters: RemotePostCreateParameters) async throws -> RemotePost {
        let path = self.path(forEndpoint: "sites/\(siteID)/posts/new?context=edit", withVersion: ._1_2)
        let parameters = try makeParameters(from: RemotePostCreateParametersWordPressComEncoder(parameters: parameters))

        let response = try await withUnsafeThrowingContinuation { continuation in
            wordPressComRestApi.POST(path, parameters: parameters) { object, _ in
                continuation.resume(returning: object)
            } failure: { error, _ in
                continuation.resume(throwing: error)
            }
        }
        return try await decodePost(from: response)
    }

    public func patchPost(withID postID: Int, changes: RemotePostUpdateParameters) async throws -> RemotePost {
        let path = self.path(forEndpoint: "sites/\(siteID)/posts/\(postID)?context=edit", withVersion: ._1_2)
        let parameters = try makeParameters(from: RemotePostUpdateParametersWordPressComEncoder(parameters: changes))

        let response = try await withUnsafeThrowingContinuation { continuation in
            wordPressComRestApi.POST(path, parameters: parameters) { object, _ in
                continuation.resume(returning: object)
            } failure: { error, _ in
                continuation.resume(throwing: error)
            }
        }
        return try await decodePost(from: response)
    }
}

// Decodes the post in the background.
private func decodePost(from object: AnyObject) async throws -> RemotePost {
    guard let dictionary = object as? [AnyHashable: Any],
          let post = PostServiceRemoteREST.remotePost(fromJSONDictionary: dictionary) else {
        throw WordPressAPIError<WordPressComRestApiEndpointError>.unparsableResponse(response: nil, body: nil)
    }
    return post
}

private func makeParameters<T: Encodable>(from value: T) throws -> [String: AnyObject] {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .formatted(NSDate.rfc3339DateFormatter())
    let data = try encoder.encode(value)
    let object = try JSONSerialization.jsonObject(with: data)
    guard let dictionary = object as? [String: AnyObject] else {
        throw URLError(.unknown) // This should never happen
    }
    return dictionary
}
