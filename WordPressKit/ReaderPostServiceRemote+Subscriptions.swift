import Foundation

extension ReaderPostServiceRemote {

    public enum ResponseError: Error {
        case decodingFailed
    }

    private enum Constants {
        static let isSubscribed = "i_subscribe"
    }

    /// Fetches the subscription status of the specified post for the current user.
    ///
    /// - Parameters:
    ///   - postID: The ID of the post.
    ///   - siteID: The ID of the site.
    ///   - success: Success block called on a successful fetch.
    ///   - failure: Failure block called if there is any error.
    public func fetchSubscriptionStatus(for postID: Int,
                                        from siteID: Int,
                                        success: @escaping (Bool) -> Void,
                                        failure: @escaping (Error?) -> Void) {
        let path = self.path(forEndpoint: "sites/\(siteID)/posts/\(postID)/subscribers/mine", withVersion: ._1_1)
        
        wordPressComRestApi.GET(path, parameters: nil, success: { [weak self] response, _ in
            do {
                let isSubscribed = try self?.isSubscribed(object: response)
                success(isSubscribed ?? false)
            } catch {
                failure(error)
            }
        }) { error, _ in
            DDLogError("Error fetching subscription status: \(error)")
            failure(error)
        }
    }

    /// Mark a post as subscribed by the user.
    ///
    /// - Parameters:
    ///   - postID: The ID of the post.
    ///   - siteID: The ID of the site.
    ///   - success: Success block called on a successful fetch.
    ///   - failure: Failure block called if there is any error.
    public func subscribeToPost(with postID: Int,
                                for siteID: Int,
                                success: @escaping () -> Void,
                                failure: @escaping (Error?) -> Void) {
        let path = self.path(forEndpoint: "sites/\(siteID)/posts/\(postID)/subscribers/new", withVersion: ._1_1)

        wordPressComRestApi.POST(path, parameters: nil, success: { response, _ in
            success()
        }) { error, _ in
            DDLogError("Error subscribing to comments in the post: \(error)")
            failure(error)
        }
    }

    /// Mark a post as unsubscribed by the user.
    ///
    /// - Parameters:
    ///   - postID: The ID of the post.
    ///   - siteID: The ID of the site.
    ///   - success: Success block called on a successful fetch.
    ///   - failure: Failure block called if there is any error.
    public func unsubscribeFromPost(with postID: Int,
                                    for siteID: Int,
                                    success: @escaping () -> Void,
                                    failure: @escaping (Error) -> Void) {
        let path = self.path(forEndpoint: "sites/\(siteID)/posts/\(postID)/subscribers/mine/delete", withVersion: ._1_1)

        wordPressComRestApi.POST(path, parameters: nil, success: { response, _ in
            success()
        }) { error, _ in
            DDLogError("Error unsubscribing from comments in the post: \(error)")
            failure(error)
        }
    }
}

extension ReaderPostServiceRemote {

    private func isSubscribed(object: AnyObject) throws -> Bool {
        guard let response = object as? [String: AnyObject],
            let isSubscribed = response[Constants.isSubscribed] as? Bool else {
                throw ReaderPostServiceRemote.ResponseError.decodingFailed
        }
        return isSubscribed
    }
}
