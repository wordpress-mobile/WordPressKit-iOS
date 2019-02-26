public struct StatsTopPostsTimeIntervalData {
    public let period: StatsPeriodUnit
    public let periodEndDate: Date

    public let totalViewsCount: Int
    public let otherViewsCount: Int
    public let topPosts: [StatsTopPost]
}

extension StatsTopPostsTimeIntervalData: StatsTimeIntervalData {
    public static var pathComponent: String {
        return "stats/top-posts"
    }

    public init?(date: Date, period: StatsPeriodUnit, jsonDictionary: [String : AnyObject]) {
        guard
            let unwrappedDays = type(of: self).unwrapDaysDictionary(jsonDictionary: jsonDictionary),
            let posts = unwrappedDays["postviews"] as? [[String: AnyObject]],
            let totalViews = unwrappedDays["total_views"] as? Int,
            let otherViews = unwrappedDays["other_views"] as? Int
            else {
                return nil
        }

        self.periodEndDate = date
        self.period = period
        self.totalViewsCount = totalViews
        self.otherViewsCount = otherViews
        self.topPosts = posts.compactMap { StatsTopPost(topPostsJSONDictionary: $0) }
    }
}

private extension StatsTopPost {

    // the objects returned from this endpoint are _almost_ the same as the ones from `top-posts`,
    // but with keys just subtly different enough that we need a custom init here.
    init?(topPostsJSONDictionary jsonDictionary: [String: AnyObject]) {
        guard
            let url = jsonDictionary["href"] as? String,
            let postID = jsonDictionary["id"] as? Int,
            let title = jsonDictionary["title"] as? String,
            let viewsCount = jsonDictionary["views"] as? Int,
            let typeString = jsonDictionary["type"] as? String
            else {
                return nil
        }

        self.title = title
        self.postID = postID
        self.postURL = URL(string: url)
        self.viewsCount = viewsCount
        self.kind = type(of: self).kind(from: typeString)
    }

}
