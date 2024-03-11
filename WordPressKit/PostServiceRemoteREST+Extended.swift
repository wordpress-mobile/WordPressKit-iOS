import Foundation

extension PostServiceRemoteREST: PostServiceRemoteExtended {
    public func createPost(with parameters: RemotePostCreateParameters) async throws -> RemotePost {
        let path = self.path(forEndpoint: "sites/\(siteID)/posts/new?context=edit", withVersion: ._1_2)
        let parameters = try makeParameters(from: RemotePostCreateParametersWordPressComEncoder(parameters: parameters))

        let response = try await wordPressComRestApi.perform(.post, URLString: path, parameters: parameters).get()
        return try await decodePost(from: response.body)
    }

    public func patchPost(withID postID: Int, parameters: RemotePostUpdateParameters) async throws -> RemotePost {
        let path = self.path(forEndpoint: "sites/\(siteID)/posts/\(postID)?context=edit", withVersion: ._1_2)
        let parameters = try makeParameters(from: RemotePostUpdateParametersWordPressComEncoder(parameters: parameters))

        let result = await wordPressComRestApi.perform(.post, URLString: path, parameters: parameters)
        switch result {
        case .success(let response):
            return try await decodePost(from: response.body)
        case .failure(let error):
            guard case .endpointError(let error) = error else {
                throw error
            }
            switch error.apiErrorCode ?? "" {
            case "unknown_post": throw PostServiceRemoteUpdatePostError.notFound
            case "old-revision": throw PostServiceRemoteUpdatePostError.conflict
            default: throw error
            }
        }
    }
}

// Decodes the post in the background.
private func decodePost(from object: AnyObject) async throws -> RemotePost {
    guard let dictionary = object as? [AnyHashable: Any] else {
        throw WordPressAPIError<WordPressComRestApiEndpointError>.unparsableResponse(response: nil, body: nil)
    }
    return PostServiceRemoteREST.remotePost(fromJSONDictionary: dictionary)
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
