public class BlogSyncService: ServiceRemoteWordPressComREST {

    let blogID: NSNumber

    // FIXME: This should use WordPressComRESTAPIInterface once all the WordPressComRestApi usages have been migrated.
    /// - Note: The parameter name `siteID` is for backward compatibility.
    @objc public init(wordPressComRestApi: WordPressComRestApi, siteID: NSNumber) {
        self.blogID = siteID
        super.init(wordPressComRestApi: wordPressComRestApi)
    }

    /// Synchronizes a blog and its top-level details.
    @objc public func syncBlog(success: ((RemoteBlog) -> Void)?, failure: ((Error?) -> Void)?) {
        wordPressComRESTAPI.get(
            path(forEndpoint: "sites/\(blogID)", withVersion: ._1_1),
            parameters: nil,
            success: { response, _ in
                guard let success else { return }
                guard let responseDict = response as? NSDictionary else {
                    failure?(.none)
                    return
                }

                let remoteBlog = RemoteBlog(jsonDictionary: responseDict)
                success(remoteBlog)
            },
            failure: { error, _ in
                failure?(error)
            }
        )
    }

    @objc public func syncBlogSettings(
        success: ((RemoteBlogSettings) -> Void)?,
        failure: ((Error?) -> Void)?
    ) {
        wordPressComRESTAPI.get(
            path(forEndpoint: "sites/\(blogID)/settings", withVersion: ._1_1),
            parameters: nil,
            success: { response, _ in
                guard let success else { return }
                guard let responseDict = response as? NSDictionary else {
                    failure?(.none)
                    return
                }

                let remoteBlogSettings = RemoteBlogSettings(jsonDictionary: responseDict)
                success(remoteBlogSettings)
            },
            failure: { error, _ in
                failure?(error)
            }
        )

    }
}
