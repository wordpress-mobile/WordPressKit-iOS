import Foundation

// This name isn't great! After finishing the work on StatsRefresh we'll get rid of the "old"
// one and rename this to not have "V2" in it, but we want to keep the old one around
// for a while still.

public class StatsServiceRemoteV2: ServiceRemoteWordPressComREST {

    public enum ResponseError: Error {
        case decodingFailure
    }

    private let siteID: Int
    private let siteTimezone: TimeZone

    public init(wordPressComRestApi api: WordPressComRestApi, siteID: Int, siteTimezone: TimeZone) {
        self.siteID = siteID
        self.siteTimezone = siteTimezone
        super.init(wordPressComRestApi: api)
    }


    public func getInsight<InsightType: InsightProtocol>(completion: @escaping ((InsightType?, Error?) -> Void)) {
        let properties = InsightType.queryProperties
        let pathComponent = InsightType.pathComponent

        let path = self.path(forEndpoint: "sites/\(siteID)/\(pathComponent)/", withVersion: ._1_1)

        wordPressComRestApi.GET(path, parameters: properties, success: { (response, _) in
            guard
                let jsonResponse = response as? [String: AnyObject],
                let insight = InsightType(jsonDictionary: jsonResponse)
            else {
                completion(nil, ResponseError.decodingFailure)
                return
            }

            completion(insight, nil)
        }, failure: { (error, _) in
            completion(nil, error)
        })
    }

    // "Last Post" Insights are "fun" in the way that they require multiple requests to actually create them,
    // so we do this "fun" dance in a separate method.
    public func getInsight(completion: @escaping ((StatsLastPostInsight?, Error?) -> Void)) {
         getLastPostInsight(completion: completion)
    }

    private func getLastPostInsight(completion: @escaping ((StatsLastPostInsight?, Error?) -> Void)) {
        let properties = StatsLastPostInsight.queryProperties
        let pathComponent = StatsLastPostInsight.pathComponent

        let path = self.path(forEndpoint: "sites/\(siteID)/\(pathComponent)", withVersion: ._1_1)

        wordPressComRestApi.GET(path, parameters: properties, success: { (response, _) in
            guard
                let jsonResponse = response as? [String: AnyObject],
                let posts = jsonResponse["posts"] as? [[String: AnyObject]],
                let post = posts.first,
                let postID = post["ID"] as? Int else {
                    completion(nil, ResponseError.decodingFailure)
                    return
            }

            self.getPostViews(for: postID) { (views, error) in
                guard
                    let views = views,
                    let insight = StatsLastPostInsight(jsonDictionary: post, views: views) else {
                        completion(nil, ResponseError.decodingFailure)
                        return

                }

                completion(insight, nil)
            }
        }, failure: {(error, _) in
            completion(nil, error)
        })
    }

    public func getPostViews(`for` postID: Int, completion: @escaping ((Int?, Error?) -> Void)) {
        let parameters = ["fields": "views" as AnyObject]

        let path = self.path(forEndpoint: "sites/\(siteID)/stats/post/\(postID)", withVersion: ._1_1)

        wordPressComRestApi.GET(path,
                                parameters: parameters,
                                success: { (response, _) in
                                    guard
                                        let jsonResponse = response as? [String: AnyObject],
                                        let views = jsonResponse["views"] as? Int else {
                                            completion(nil, ResponseError.decodingFailure)
                                            return
                                    }
                                    completion(views, nil)
                                }, failure:  { (error, _) in
                                    completion(nil, error)
                                }
        )
    }

}

// This serves both as a way to get the query properties in a "nice" way,
// but also as a way to narrow down the generic type in `getInisght:` method.
public protocol InsightProtocol {
    static var queryProperties: [String: AnyObject] { get }
    static var pathComponent: String { get }

    init?(jsonDictionary: [String: AnyObject])
}

extension InsightProtocol {

    // A big chunk of those use the same endpoint and queryProperties.. Let's simplify the protocol conformance in those cases.

    public static var queryProperties: [String: AnyObject] {
        return [:]
    }

    public static var pathComponent: String {
        return "stats/"
    }
}

// For some god-forsaken reason Swift compiler freaks out if this is not declared _in this file_,
// and refuses to compile the project.
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
    public static var queryProperties: [String: AnyObject] {
        return ["order_by": "date" as AnyObject,
                "number": "1" as AnyObject,
                "type": "post" as AnyObject,
                "fields": "ID, title, URL, discussion, like_count, date" as AnyObject]
    }

    public static var pathComponent: String {
        return "posts/"
    }

    public init?(jsonDictionary: [String: AnyObject]) {
        fatalError("This shouldn't be ever called, instead init?(jsonDictionary:_ views:_) be called instead.")
    }

    //MARK: -

    private static let dateFormatter: ISO8601DateFormatter = .init()

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
