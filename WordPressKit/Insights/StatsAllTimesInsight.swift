public struct StatsAllTimesInsight {
    public let postsCount: Int
    public let viewsCount: Int
    public let bestViewsDay: Date
    public let visitorsCount: Int
    public let bestViewsPerDayCount: Int
}


extension StatsAllTimesInsight: InsightProtocol {

    //MARK: - InsightProtocol Conformance
    public static var queryProperties: [String : AnyObject] {
        return [:]
    }

    public init?(jsonDictionary: [String: AnyObject]) {
        guard
            let statsDict = jsonDictionary["stats"] as? [String: AnyObject],
            let postsCount = statsDict["posts"] as? Int,
            let viewsCount = statsDict["views"] as? Int,
            let visitorsCount = statsDict["visitors"] as? Int,
            let bestViewsPerDayCount = statsDict["views_best_day_total"] as? Int,
            let bestViewsDayString = statsDict["views_best_day"] as? String,
            let bestViewsDay = StatsAllTimesInsight.dateFormatter.date(from: bestViewsDayString)
            else {
                return nil
        }

        self.postsCount = postsCount
        self.bestViewsPerDayCount = bestViewsPerDayCount
        self.visitorsCount = visitorsCount
        self.viewsCount = viewsCount
        self.bestViewsDay = bestViewsDay
    }

    //MARK: -
    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd";
        return formatter
    }
}
