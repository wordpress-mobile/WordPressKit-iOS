extension ReaderPostServiceRemote {
    /// Returns a collection of RemoteReaderPost
    /// This method returns the best available content for the given topics.
    ///
    /// - Parameter topics: an array of String representing the topics
    /// - Parameter page: a String that represents a page handle
    /// - Parameter success: Called when the request succeeds and the data returned is valid
    /// - Parameter failure: Called if the request fails for any reason, or the response data is invalid
    public func fetchPosts(for topics: [String],
                           page: String? = nil,
                           refreshCount: Int? = nil,
                           success: @escaping ([RemoteReaderPost], String?) -> Void,
                           failure: @escaping (Error) -> Void) {
        guard let requestUrl = postsEndpoint(for: topics, page: page) else {
            return
        }

        wordPressComRestApi.GET(requestUrl,
                                parameters: nil,
                                success: { response, _ in
                                    let nextPageHandle = response["next_page_handle"] as? String
                                    let postsDictionary = response["posts"] as? [[String: Any]]
                                    let posts = postsDictionary?.compactMap { RemoteReaderPost(dictionary: $0) } ?? []
                                    success(posts, nextPageHandle)
        }, failure: { error, _ in
            DDLogError("Error fetching reader posts: \(error)")

            failure(error)
        })
    }

    private func postsEndpoint(for topics: [String], page: String? = nil) -> String? {
        var path = URLComponents(string: "read/tags/posts")

        path?.queryItems = topics.map { URLQueryItem(name: "tags[]", value: $0) }

        if let page = page {
            path?.queryItems?.append(URLQueryItem(name: "page_handle", value: page))
        }

        guard let endpoint = path?.string else {
            return nil
        }

        return self.path(forEndpoint: endpoint, withVersion: ._2_0)
    }
    
    
    /// Sets the `is_seen` status for a given post.
    ///
    /// - Parameter seen: the post is to be marked seen or not (unseen)
    /// - Parameter feedID: feedID of the ReaderPost
    /// - Parameter feedItemID: feedItemID of the ReaderPost
    /// - Parameter success: Called when the request succeeds
    /// - Parameter failure: Called when the request fails
    @objc
    public func markPostSeen(seen: Bool,
                             feedID: NSNumber,
                             feedItemID: NSNumber,
                             success: @escaping (() -> Void),
                             failure: @escaping ((Error) -> Void)) {
        
        let endpoint = seen ? SeenEndpoints.seen : SeenEndpoints.unseen
        let path = self.path(forEndpoint: endpoint, withVersion: ._2_0)
        
        let params = [
            "feed_id": feedID,
            "feed_item_ids": [feedItemID],
            "source": "reader-ios"
        ] as [String: AnyObject]
        
        wordPressComRestApi.POST(path, parameters: params, success: { (responseObject, httpResponse) in
            guard let response = responseObject as? [String: AnyObject],
                  let status = response["status"] as? Bool,
                  status == true else {
                failure(MarkSeenError.failed)
                return
            }
            success()
        }, failure: { (error, httpResponse) in
            failure(error)
        })
    }

    private enum MarkSeenError: Error {
        case failed
    }
    
    private struct SeenEndpoints {
        // Creates a new `seen` entry (i.e. mark as seen)
        static let seen = "seen-posts/seen/new"
        // Removes the `seen` entry (i.e. mark as unseen)
        static let unseen = "seen-posts/seen/delete"
    }

}
