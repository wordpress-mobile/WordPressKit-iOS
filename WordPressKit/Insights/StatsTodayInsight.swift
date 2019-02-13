public struct StatsTodayInsight {
    public let viewsCount: Int
    public let visitorsCount: Int
    public let likesCount: Int
    public let commentsCount: Int
}

extension StatsTodayInsight: InsightProtocol {

    //MARK: - InsightProtocol Conformance
    public static var pathComponent: String {
        return "stats/summary"
    }

    public init?(jsonDictionary: [String: AnyObject]) {
        guard
            let viewsCount = jsonDictionary["views"] as? Int,
            let visitorsCount = jsonDictionary["visitors"] as? Int,
            let likesCount = jsonDictionary["likes"] as? Int,
            let commentsCount = jsonDictionary["comments"] as? Int
            else {
                return nil
        }

        self.visitorsCount = visitorsCount
        self.viewsCount = viewsCount
        self.likesCount = likesCount
        self.commentsCount = commentsCount
    }
}
