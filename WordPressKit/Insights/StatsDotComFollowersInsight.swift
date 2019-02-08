public struct StatsDotComFollowersInsight {
    public let dotComFollowersCount: Int
    public let topDotComFollowers: [StatsFollower]
}

extension StatsDotComFollowersInsight: InsightProtocol {

    //MARK: - InsightProtocol Conformance
    public static var queryProperties: [String: AnyObject] {
        return ["type": "wpcom" as AnyObject,
                "max": "7" as AnyObject]
    }

    public static var pathComponent: String {
        return "stats/followers"
    }

    public init?(jsonDictionary: [String: AnyObject]) {
        guard
            let subscribersCount = jsonDictionary["total_wpcom"] as? Int,
            let subscribers = jsonDictionary["subscribers"] as? [[String: AnyObject]]
            else {
                return nil
        }

        let followers = subscribers.compactMap { StatsFollower(jsonDictionary: $0) }

        self.dotComFollowersCount = subscribersCount
        self.topDotComFollowers = followers
    }

    //MARK: -
    fileprivate static let dateFormatter: ISO8601DateFormatter = .init()
}

public struct StatsFollower {
    public let name: String
    public let subscribedDate: Date
    public let avatarURL: URL?
}

extension StatsFollower {

    init?(jsonDictionary: [String: AnyObject]) {
        guard
            let name = jsonDictionary["label"] as? String,
            let avatar = jsonDictionary["avatar"] as? String,
            let dateString = jsonDictionary["date_subscribed"] as? String
            else {
                return nil
        }

        self.init(name: name, avatar: avatar, date: dateString)
    }


    init?(name: String, avatar: String, date: String) {
        guard let date = StatsDotComFollowersInsight.dateFormatter.date(from: date) else {
            return nil
        }

        let url: URL?

        if var components = URLComponents(string: avatar) {
            components.query = "d=mm&s=60" // to get a properly-sized avatar.
            url = try? components.asURL()
        } else {
            url = nil
        }

        self.name = name
        self.subscribedDate = date
        self.avatarURL = url
    }
}
