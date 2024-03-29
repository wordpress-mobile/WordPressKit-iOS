import Foundation

public protocol PostServiceRemoteExtended: PostServiceRemote {
    /// Creates a new post with the given parameters.
    func createPost(with parameters: RemotePostCreateParameters) async throws -> RemotePost

    /// Performs a partial update to the existing post.
    ///
    /// - throws: ``PostServiceRemoteUpdatePostError`` or oher underlying errors
    /// (see ``WordPressAPIError``)
    func patchPost(withID postID: Int, parameters: RemotePostUpdateParameters) async throws -> RemotePost
}

public enum PostServiceRemoteUpdatePostError: Error {
    /// 409 (Conflict)
    case conflict
    /// 404 (Not Found)
    case notFound
}
