public struct StatsTopReferrersTimeIntervalData {
    public let period: StatsPeriodUnit
    public let periodEndDate: Date

    public let totalReferrerViewsCount: Int
    public let otherReferrerViewsCount: Int

    public let referrers: [StatsReferrer]
}

public struct StatsReferrer {
    public let title: String
    public let viewsCount: Int
    public let url: URL?
    public let iconURL: URL?

    public let children: [StatsReferrer]
}

extension StatsTopReferrersTimeIntervalData: StatsTimeIntervalData {
    public static var pathComponent: String {
        return "stats/referrers"
    }

    public init?(date: Date, period: StatsPeriodUnit, jsonDictionary: [String : AnyObject]) {
        guard
            let unwrappedDays = type(of: self).unwrapDaysDictionary(jsonDictionary: jsonDictionary),
            let totalClicks = unwrappedDays["total_views"] as? Int,
            let otherClicks = unwrappedDays["other_views"] as? Int,
            let referrers = unwrappedDays["groups"] as? [[String: AnyObject]]
            else {
                return nil
        }

        self.period = period
        self.periodEndDate = date
        self.totalReferrerViewsCount = totalClicks
        self.otherReferrerViewsCount = otherClicks
        self.referrers = referrers.compactMap { StatsReferrer(jsonDictionary: $0) }
    }
}

extension StatsReferrer {
    init?(jsonDictionary: [String: AnyObject]) {
        guard
            let title = jsonDictionary["name"] as? String
            else {
                return nil
        }

        // The shape of API reply here is _almost_ a perfectly fractal tree structure.
        // However, sometimes the keys for children/parents representing the same values change, hence this
        // rether ugly hack.
        let viewsCount: Int

        if let views = jsonDictionary["total"] as? Int {
            viewsCount = views
        } else if let views = jsonDictionary["views"] as? Int {
            viewsCount = views
        } else {
            // If neither key is present, this is a malformed response.
            return nil
        }

        let children: [StatsReferrer]

        if let childrenJSON = jsonDictionary["results"] as? [[String: AnyObject]] {
            children = childrenJSON.compactMap { StatsReferrer(jsonDictionary: $0) }
        } else if let childrenJSON = jsonDictionary["children"] as? [[String: AnyObject]]  {
            children = childrenJSON.compactMap { StatsReferrer(jsonDictionary: $0) }
        } else {
            children = []
        }

        let icon = jsonDictionary["icon"] as? String
        let urlString = jsonDictionary["url"] as? String

        self.title = title
        self.viewsCount = viewsCount
        self.url = urlString.flatMap { URL(string: $0) }
        self.iconURL = icon.flatMap { URL(string: $0) }
        self.children = children
    }
}
