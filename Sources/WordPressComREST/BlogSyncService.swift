import Foundation

public class BlogSyncService: ServiceRemoteWordPressComREST {

    let blogID: NSNumber

    // FIXME: This should use WordPressComRESTAPIInterface once all the WordPressComRestApi usages have been migrated.
    @objc(initWithWordPressComRestApi:siteID:)
    public init(wordPressComRESTAPI: WordPressComRestApi, blogID: NSNumber) {
        self.blogID = blogID
        super.init(wordPressComRestApi: wordPressComRESTAPI)
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

    /// Synchronizes a blog's settings.
    @objc public func syncBlogSettings(
        success: ((RemoteBlogSettings) -> Void)?,
        failure: ((Error?) -> Void)?
    ) {
        wordPressComRESTAPI.get(
            path(forEndpoint: "sites/\(blogID)/settings", withVersion: ._1_1),
            parameters: nil,
            success: { response, _ in
                guard let success else { return }

                guard let responseDict = response as? [String: Any] else {
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

    @objc public func updateBlogSettings(
        _ settings: RemoteBlogSettings,
        success: (() -> Void)?,
        failure: ((Error?) -> Void)?
    ) {
        wordPressComRESTAPI.post(
            path(
                forEndpoint: "sites/\(blogID)/settings?context=edit",
                withVersion: ._1_1
            ),
            parameters: settings.dictionaryRepresentation,
            success: { response, _ in
                guard let responseDict = response as? NSDictionary else {
                    failure?(nil)
                    return
                }

                guard responseDict["updated"] != nil else {
                    failure?(nil)
                    return
                }

                success?()
            },
            failure: { error, _ in
                failure?(error)
            }
        )
    }
}
