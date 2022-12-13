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

}

private let avgWordsPerMinuteRead = 250
private let minutesToReadThreshold = 2
