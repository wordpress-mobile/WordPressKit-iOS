import Foundation

public protocol PostServiceRemoteExtended: PostServiceRemote {
    /// Creates a new post with the given parameters.
    func createPost(with parameters: RemotePostCreateParameters) async throws -> RemotePost

    /// Performs a partial update to the existing post.
    func patchPost(withID postID: Int, parameters: RemotePostUpdateParameters) async throws -> RemotePost
}
