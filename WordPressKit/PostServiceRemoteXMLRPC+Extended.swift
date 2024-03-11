import Foundation
import wpxmlrpc

extension PostServiceRemoteXMLRPC: PostServiceRemoteExtended {
    public func createPost(with parameters: RemotePostCreateParameters) async throws -> RemotePost {
        let dictionary = try makeParameters(from: RemotePostCreateParametersXMLRPCEncoder(parameters: parameters, type: .post))
        let parameters = xmlrpcArguments(withExtra: dictionary) as [AnyObject]
        let response = try await withUnsafeThrowingContinuation { continuation in
            api.callMethod("metaWeblog.newPost", parameters: parameters) { object, _ in
                continuation.resume(returning: object)
            } failure: { error, _ in
                continuation.resume(throwing: error)
            }
        }
        guard let postID = (response as? NSNumber) else {
            throw URLError(.unknown) // Should never happen
        }
        return try await getPost(withID: postID)
    }

    public func patchPost(withID postID: Int, parameters: RemotePostUpdateParameters) async throws -> RemotePost {
        let dictionary = try makeParameters(from: RemotePostUpdateParametersXMLRPCEncoder(parameters: parameters, type: .post))
        var parameters = xmlrpcArguments(withExtra: dictionary) as [AnyObject]
        if parameters.count > 0 {
            parameters[0] = postID as NSNumber
        }
        try await withUnsafeThrowingContinuation { continuation in
            api.callMethod("metaWeblog.editPost", parameters: parameters) { _, _ in
                continuation.resume(returning: ())
            } failure: { error, _ in
                continuation.resume(throwing: error)
            }
        }
        return try await getPost(withID: postID as NSNumber)
    }

    private func getPost(withID postID: NSNumber) async throws -> RemotePost {
        try await withUnsafeThrowingContinuation { continuation in
            getPostWithID(postID) { post in
                guard let post else {
                    return continuation.resume(throwing: URLError(.unknown)) // Should never happen
                }
                continuation.resume(returning: post)
            } failure: { error in
                continuation.resume(throwing: error ?? URLError(.unknown))
            }
        }
    }
}

private func makeParameters<T: Encodable>(from value: T) throws -> [String: AnyObject] {
    let encoder = PropertyListEncoder()
    encoder.outputFormat = .xml
    let data = try encoder.encode(value)
    let object = try PropertyListSerialization.propertyList(from: data, format: nil)
    guard let dictionary = object as? [String: AnyObject] else {
        throw URLError(.unknown) // This should never happen
    }
    return dictionary
}
