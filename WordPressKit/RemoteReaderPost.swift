import Foundation

public extension RemoteReaderPost {

    @objc(readingTimeForWordCount:)
    class func readingTime(forWordCount wordCount: NSNumber) -> NSNumber {
        let count = wordCount.intValue
        let minutesToRead = count / avgWordsPerMinuteRead;
        if minutesToRead < minutesToReadThreshold {
            return 0
        }
        return minutesToRead as NSNumber
    }

    /// The v1 API result is inconsistent in that it will return a 0 when there is no author email.
    ///
    /// - Parameter dict The author dictionary.
    /// - Returns The author's email address or an empty string.
    @objc(authorEmailFromAuthorDictionary:)
    class func authorEmail(fromAuthorDictionary dict: NSDictionary) -> String {
        if let authorEmail = dict.string(forKey: postRESTKeyEmail),
           authorEmail.count >= minimalEmailLength {
            return authorEmail
        }

        return ""
    }

    /// Parse whether the post belongs to a wpcom blog.
    ///
    /// - Parameter dict A dictionary representing a post object from the REST API
    /// - Returns YES if the post belongs to a wpcom blog, else NO
    @objc(isWPComFromPostDictionary:)
    class func isWPCom(fromPostDictionary dict: NSDictionary) -> Bool {
        let isExternal = dict.number(forKey: postRESTKeyIsExternal)?.boolValue ?? false
        let isJetpack = dict.number(forKey: postRESTKeyIsJetpack)?.boolValue ?? false
        return !isJetpack && !isExternal
    }

    /// Get the tags assigned to a post and return them as a comma separated string.
    ///
    /// - Parameter dict A dictionary representing a post object from the REST API.
    /// - Returns A comma separated list of tags, or an empty string if no tags are found.
    @objc(tagsFromPostDictionary:)
    class func tags(fromPostDictionary dict: NSDictionary) -> String {
        if let tagsDict = dict[postRESTKeyTags] as? [String: Any] {
            return tagsDict.keys.joined(separator: ", ")
        }

        return ""
    }

    /// Get the name of the post's site.
    ///
    /// - Parameter dict A dictionary representing a post object from the REST API.
    /// - Returns The name of the post's site or an empty string.
    @objc(siteNameFromPostDictionary:)
    class func siteName(fromPostDictionary dict: NSDictionary) -> String {
        // Blog Name
        var siteName = dict.string(forKey: postRESTKeySiteName) ?? ""

        // For some endpoints blogname is defined in meta
        if let metaBlogName = dict.string(forKeyPath: "meta.data.site.name") {
            siteName = metaBlogName;
        }

        // Values set in editorial trumps the rest
        if let editorialSiteName = dict.string(forKeyPath: "editorial.blog_name") {
            siteName = editorialSiteName
        }

        return (siteName as NSString).summarized()
    }

    /// Retrives the post site's URL
    ///
    /// - Parameter dict A dictionary representing a post object from the REST API.
    /// - Returns The URL path of the post's site.
    @objc(siteURLFromPostDictionary:)
    class func siteURL(romPostDictionary dict: NSDictionary) -> String {
        dict.string(forKeyPath: "meta.data.site.URL")
            ?? dict.string(forKey: postRESTKeySiteURL)
            ?? ""
    }

    @objc(siteIsAtomicFromPostDictionary:)
    class func siteIsAtomic(fromPostDictionary dict: NSDictionary) -> Bool {
        dict.number(forKey: postRESTKeySiteIsAtomic)?.boolValue ?? false
    }


    /// Retrives the privacy preference for the post's site.
    ///
    /// - Parameter dict A dictionary representing a post object from the REST API.
    /// - Returns YES if the site is private.
    @objc(siteIsPrivateFromPostDictionary:)
    class func siteIsPrivate(fromPostDictionary dict: NSDictionary) -> Bool {
        dict.number(forKeyPath: "meta.data.site.is_private")?.boolValue
            ?? dict.number(forKey: postRESTKeySiteIsPrivate)?.boolValue
            ?? false
    }

}

private let postRESTKeyEmail = "email"
private let postRESTKeyIsExternal = "is_external"
private let postRESTKeyIsJetpack = "is_jetpack"
private let postRESTKeyTags = "tags";
private let postRESTKeySiteName = "site_name";
private let postRESTKeySiteURL = "site_URL";
private let postRESTKeySiteIsAtomic = "site_is_atomic";
private let postRESTKeySiteIsPrivate = "site_is_private";

// The minimum email length: a@a.aa
private let minimalEmailLength = 6

private let avgWordsPerMinuteRead = 250
private let minutesToReadThreshold = 2
