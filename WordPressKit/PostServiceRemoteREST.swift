import Foundation

@objc protocol PostServiceRemoteUpdatePostWithRevision: AnyObject {
    @objc(updatePost:baseRevisionID:success:failure:) optional func update(_ post: RemotePost, baseRevisionID: NSNumber, success: ((RemotePost) -> Void)?, failure: ((Error?) -> Void)?)
}

extension PostServiceRemoteREST {

    func update(_ post: RemotePost, baseRevisionID: NSNumber, success: ((RemotePost) -> Void)?, failure: ((Error?) -> Void)?) {
        Task {
            let patched = await self.patch(post, baseRevisionID: baseRevisionID)
            if !patched {
                update(post, success: { success?($0!) }, failure: { failure?($0!) })
            }
        }
    }

    private func patch(_ post: RemotePost, baseRevisionID: NSNumber) async -> Bool {
        guard let postID = post.postID, postID.int64Value > 0 else {
            return false
        }

        let latestRevisionID = try? await withCheckedThrowingContinuation { continuation in
            getPostLatestRevisionID(for: postID, success: {
                continuation.resume(returning: $0)
            }, failure: {
                continuation.resume(throwing: $0!)
            })
        }
        guard let latestRevisionID else {
            return false
        }

        // If the post is made on top of the latest revision, then fallback to sending full post content.
        if baseRevisionID == latestRevisionID {
            return false
        }

        let baseRevision = try? await withCheckedThrowingContinuation { continuation in
            getPostWithID(baseRevisionID, success: {
                continuation.resume(returning: $0)
            }, failure: {
                continuation.resume(throwing: $0!)
            })
        }
        guard let baseRevision else {
            return false
        }

        let patch = RemotePost()

        func updateIfModified<V: Equatable>(_ keyPath: ReferenceWritableKeyPath<RemotePost, V>) {
            if baseRevision[keyPath: keyPath] != post[keyPath: keyPath] {
                patch[keyPath: keyPath] = post[keyPath: keyPath]
            }
        }

        patch.date = post.date
        patch.categories = post.categories
        patch.tags = post.tags
        patch.metadata = post.metadata

        updateIfModified(\.title)
        updateIfModified(\.content)
        updateIfModified(\.excerpt)
        updateIfModified(\.slug)
        updateIfModified(\.authorID)
        updateIfModified(\.status)
        updateIfModified(\.isStickyPost)
        updateIfModified(\.password)
        updateIfModified(\.parentID)
        updateIfModified(\.format)
        updateIfModified(\.postThumbnailID)

        // Ignored request parameters:
//        date
//
//        publicize
//
//        publicize_message
//


//        password
//
//        parent
//
//        terms
//
//        categories
//
//        tags
//
//        format
//
//        discussion
//
//        likes_enabled
//
//        menu_order
//
//        page_template
//
//        sharing_enabled
//
//        featured_image
//
//        media
//
//        media_urls
//
//        metadata



        return true
    }
}
