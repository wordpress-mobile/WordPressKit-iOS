import Foundation

public protocol PostServiceRemoteExtended: PostServiceRemote {
    /// Performs a partial update of the given post.
    func patchPost(withID postID: Int, changes: RemotePostUpdateParameters) async throws -> RemotePost
}
