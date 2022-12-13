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

}

private let postRESTKeyEmail = "email"

// The minimum email length: a@a.aa
private let minimalEmailLength = 6

private let avgWordsPerMinuteRead = 250
private let minutesToReadThreshold = 2
