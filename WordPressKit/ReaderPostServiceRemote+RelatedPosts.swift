import Foundation

extension ReaderPostServiceRemote {

    /// Returns a collection of RemoteReaderSimplePost
    /// This method returns related posts for a source post.
    ///
    /// - Parameter postID: The source post's ID
    /// - Parameter siteID: The source site's ID
    /// - Parameter success: Called when the request succeeds and the data returned is valid
    /// - Parameter failure: Called if the request fails for any reason, or the response data is invalid
    public func fetchRelatedPosts(for postID: Int,
                                  from siteID: Int,
                                  success: @escaping ([RemoteReaderSimplePost]) -> Void,
                                  failure: @escaping (Error?) -> Void) {
        
        let endpoint = "read/site/\(siteID)/post/\(postID)/related"
        let path = self.path(forEndpoint: endpoint, withVersion: ._1_2)
        let parameters = [
            "size_local": Constants.relatedPostsCount,
            "size_global": Constants.relatedPostsCount
        ] as [String: AnyObject]

        wordPressComRestApi.GET(path, parameters: parameters) { (response, _) in
            do {
                let decoder = JSONDecoder()
                let data = try JSONSerialization.data(withJSONObject: response, options: [])
                let envelope = try decoder.decode(RemoteReaderSimplePostEnvelope.self, from: data)

                success(envelope.posts)
            } catch {
                DDLogError("Error parsing the reader related posts response: \(error)")
                failure(error)
            }
        } failure: { (error, response) in
            DDLogError("Error fetching reader related posts: \(error)")
            failure(error)
        }
    }

    private enum Constants {
        static let relatedPostsCount = 2
    }
}
