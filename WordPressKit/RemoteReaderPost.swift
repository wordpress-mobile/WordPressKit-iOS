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

}

private let postRESTKeyEmail = "email"
private let postRESTKeyIsExternal = "is_external"
private let postRESTKeyIsJetpack = "is_jetpack"
private let postRESTKeyTags = "tags";

// The minimum email length: a@a.aa
private let minimalEmailLength = 6

private let avgWordsPerMinuteRead = 250
private let minutesToReadThreshold = 2
