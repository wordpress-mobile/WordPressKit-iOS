public struct StatsEmailFollowersInsight {
    public let emailFollowersCount: Int
    public let topEmailFollowers: [StatsFollower]
}

extension StatsEmailFollowersInsight: StatsInsightData {

    //MARK: - StatsInsightData Conformance
    public static var queryProperties: [String: String] {
        return ["type": "email",
                "max": "7"]
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
