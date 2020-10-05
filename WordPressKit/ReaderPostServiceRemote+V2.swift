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
}
