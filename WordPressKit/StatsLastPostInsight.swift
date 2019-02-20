import Foundation

// Swift compiler doesn't like if this is not declared _in this file_, and refuses to compile the project.
// I'm guessing this has somethign to do with generic specialisation, but I'm not enough
// of a `swiftc` guru to really know. Leaving this in here to appease Swift gods.
// TODO: see if this is still a problem in Swift 5 mode!
public struct StatsLastPostInsight {
    public let title: String
    public let url: URL
    public let publishedDate: Date
    public let likesCount: Int
    public let commentsCount: Int
    public let viewsCount: Int
    public let postID: Int
}

extension StatsLastPostInsight: InsightProtocol {

    //MARK: - InsightProtocol Conformance
    public static var queryProperties: [String: String] {
        return ["order_by": "date",
                "number": "1",
                "type": "post",
                "fields": "ID, title, URL, discussion, like_count, date"]
    }

    public static var pathComponent: String {
        return "posts/"
    }

    public init?(jsonDictionary: [String: AnyObject]) {
        fatalError("This shouldn't be ever called, instead init?(jsonDictionary:_ views:_) be called instead.")
    }

    //MARK: -

    private static let dateFormatter = ISO8601DateFormatter()

    public init?(jsonDictionary: [String: AnyObject], views: Int) {

        guard
            let title = jsonDictionary["title"] as? String,
            let dateString = jsonDictionary["date"] as? String,
            let urlString = jsonDictionary["URL"] as? String,
            let likesCount = jsonDictionary["like_count"] as? Int,
            let postID = jsonDictionary["ID"] as? Int,
            let discussionDict = jsonDictionary["discussion"] as? [String: Any],
            let commentsCount = discussionDict["comment_count"] as? Int
            else {
                return nil
        }

        guard
            let url = URL(string: urlString),
            let date = StatsLastPostInsight.dateFormatter.date(from: dateString)
            else {
                return nil
        }

        self.title = title.trimmingCharacters(in: CharacterSet.whitespaces).stringByDecodingXMLCharacters()
        self.url = url
        self.publishedDate = date
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.viewsCount = views
        self.postID = postID
    }
}
