public struct StatsEmailFollowersInsight {
    public let emailFollowersCount: Int
    public let topEmailFollowers: [StatsFollower]
}

extension StatsEmailFollowersInsight: InsightProtocol {

    //MARK: - InsightProtocol Conformance
    public static var queryProperties: [String: AnyObject] {
        return ["type": "email" as AnyObject,
                "max": "7" as AnyObject]
    }

    public static var pathComponent: String {
        return "stats/followers"
    }

    public init?(jsonDictionary: [String: AnyObject]) {
        guard
            let subscribersCount = jsonDictionary["total_email"] as? Int,
            let subscribers = jsonDictionary["subscribers"] as? [[String: AnyObject]]
            else {
                return nil
        }

        let followers = subscribers.compactMap { StatsFollower(jsonDictionary: $0) }

        self.emailFollowersCount = subscribersCount
        self.topEmailFollowers = followers
    }

}
