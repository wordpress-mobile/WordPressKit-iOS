public struct StatsTopCountryTimeIntervalData {
    public let period: StatsPeriodUnit
    public let periodEndDate: Date

    public let totalViewsCount: Int
    public let otherViewsCount: Int

    public let countries: [StatsCountry]
}

public struct StatsCountry {
    let name: String
    let code: String
    let viewsCount: Int
}

extension StatsTopCountryTimeIntervalData: StatsTimeIntervalData {
    public static var pathComponent: String {
        return "stats/country-views"
    }

    public init?(date: Date, period: StatsPeriodUnit, jsonDictionary: [String : AnyObject]) {
        guard
            let countryInfo = jsonDictionary["country-info"] as? [String: AnyObject],
            let unwrappedDays = type(of: self).unwrapDaysDictionary(jsonDictionary: jsonDictionary),
            let totalViews = unwrappedDays["total_views"] as? Int,
            let otherViews = unwrappedDays["other_views"] as? Int,
            let countriesViews = unwrappedDays["views"] as? [[String: AnyObject]]
            else {
                return nil
        }

        self.periodEndDate = date
        self.period = period

        self.totalViewsCount = totalViews
        self.otherViewsCount = otherViews
        self.countries = countriesViews.compactMap { StatsCountry(jsonDictionary: $0, countryInfo: countryInfo) }
    }

}

extension StatsCountry {
    init?(jsonDictionary: [String: AnyObject], countryInfo: [String: AnyObject]) {
        guard
            let viewsCount = jsonDictionary["views"] as? Int,
            let countryCode = jsonDictionary["country_code"] as? String
            else {
                return nil
        }

        let name: String

        if
            let countryDict = countryInfo[countryCode] as? [String: AnyObject],
            let countryName = countryDict["country_full"] as? String {
            name = countryName
        } else {
            name = countryCode
        }

        self.viewsCount = viewsCount
        self.code = countryCode
        self.name = name
    }
}
