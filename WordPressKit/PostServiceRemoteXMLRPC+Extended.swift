import Foundation

extension PostServiceRemoteXMLRPC: PostServiceRemoteExtended {
    public func createPost(with parameters: RemotePostCreateParameters) async throws -> RemotePost {
        throw URLError(.unknown, userInfo: [NSLocalizedFailureErrorKey: "Unimplemented"])
    }

    public func patchPost(withID postID: Int, changes: RemotePostUpdateParameters) async throws -> RemotePost {
        throw URLError(.unknown, userInfo: [NSLocalizedFailureErrorKey: "Unimplemented"])
    }
}
