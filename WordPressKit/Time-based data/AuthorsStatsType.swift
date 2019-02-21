public struct AuthorsStatsType {
    public let period: StatsPeriodUnit
    public let periodEndDate: Date

    public let topAuthors: [StatsTopAuthor]
}

public struct StatsTopAuthor {
    public let name: String
    public let iconURL: URL?
    public let viewsCount: Int
    public let posts: [StatsTopPost]
}


public struct StatsTopPost {

    public enum Kind {
        case unknown
        case post
        case page
        case homepage
    }


    public let title: String
    public let postID: Int
    public let postURL: URL?
    public let viewsCount: Int
    public let kind: Kind

}

extension AuthorsStatsType: TimeStatsProtocol {
    public static var pathComponent: String {
        return "stats/top-authors/"
    }

    public init?(date: Date, period: StatsPeriodUnit, jsonDictionary: [String : AnyObject]) {
        guard
            let unwrappedDays = type(of: self).unwrapDaysDictionary(jsonDictionary: jsonDictionary),
            let authors = unwrappedDays["authors"] as? [[String: AnyObject]]
            else {
                return nil
        }

        self.period = period
        self.periodEndDate = date
        self.topAuthors = authors.compactMap { StatsTopAuthor(jsonDictionary: $0) }
    }
}

extension StatsTopAuthor {
    init?(jsonDictionary: [String: AnyObject]) {
        guard
            let name = jsonDictionary["name"] as? String,
            let views = jsonDictionary["views"] as? Int,
            let avatar = jsonDictionary["avatar"] as? String,
            let posts = jsonDictionary["posts"] as? [[String: AnyObject]]
            else {
                return nil
        }

        let url: URL?
        if var components = URLComponents(string: avatar) {
            components.query = "d=mm&s=60"
            url = try? components.asURL()
        } else {
            url = nil
        }

        let mappedPosts = posts.compactMap { StatsTopPost(jsonDictionary: $0) }

        self.name = name
        self.viewsCount = views
        self.iconURL = url
        self.posts = mappedPosts

    }
}

extension StatsTopPost {
    init?(jsonDictionary: [String: AnyObject]) {
        guard
            let title = jsonDictionary["title"] as? String,
            let postID = jsonDictionary["id"] as? Int,
            let viewsCount = jsonDictionary["views"] as? Int,
            let postURL = jsonDictionary["url"] as? String
            else {
                return nil
        }

        self.title = title
        self.postID = postID
        self.viewsCount = viewsCount
        self.postURL = URL(string: postURL)
        self.kind = type(of: self).kind(from: jsonDictionary["type"] as? String)
    }

    static func kind(from kindString: String?) -> Kind {
        switch kindString {
        case "post":
            return .post
        case "homepage":
            return .homepage
        case "page":
            return .page
        default:
            return .unknown
        }
    }
}

