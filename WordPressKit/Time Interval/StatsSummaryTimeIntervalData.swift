public struct StatsSummaryTimeIntervalData {
    public let period: StatsPeriodUnit
    public let periodEndDate: Date

    public let summaryData: [StatsSummaryData]
}

public struct StatsSummaryData {
    public let period: StatsPeriodUnit
    public let periodStartDate: Date

    public let viewsCount: Int
    public let visitorsCount: Int
    public let likesCount: Int
    public let commentsCount: Int
}

extension StatsSummaryTimeIntervalData: StatsTimeIntervalData {
    public static var pathComponent: String {
        return "stats/visits"
    }

    public static func queryProperties(with date: Date, period: StatsPeriodUnit) -> [String: String] {
        return ["quantity": "10",
                "stat_fields": "views,visitors,likes,comments",
                "unit": period.stringValue]
    }

    public init?(date: Date, period: StatsPeriodUnit, jsonDictionary: [String : AnyObject]) {
        guard
            let fieldsArray = jsonDictionary["fields"] as? [String],
            let data = jsonDictionary["data"] as? [[Any]]
            else {
                return nil
        }

        // The shape of data for this response is somewhat unconventional.
        // (you might want to take a peek at included tests fixtures files `stats-visits-*.json`)
        // There's a `fields` arrray with strings that correspond to requested properties
        // (e.g. something like ["period", "views", "visitors"].
        // The actual data we're after is then contained in the `data`... array of arrays?
        // The "inner" arrays contain multiple entries, whose indexes correspond to
        // the positions of the appropriate keys in the `fields` array, so in our example the array looks something like this:
        // [["2019-01-01", 9001, 1234], ["2019-02-01", 1234, 1234]], where the first object in the "inner" array
        // is the `period`, second is `views`, etc.

        guard
            let periodIndex = fieldsArray.firstIndex(of: "period"),
            let viewsIndex = fieldsArray.firstIndex(of: "views"),
            let visitorsIndex = fieldsArray.firstIndex(of: "visitors"),
            let likesIndex = fieldsArray.firstIndex(of: "likes"),
            let commentsIndex = fieldsArray.firstIndex(of: "comments")
            else {
                return nil
        }

        self.period = period
        self.periodEndDate = date
        self.summaryData = data.compactMap { StatsSummaryData(dataArray: $0,
                                                              period: period,
                                                              periodIndex: periodIndex,
                                                              viewsIndex: viewsIndex,
                                                              visitorsIndex: visitorsIndex,
                                                              likesIndex: likesIndex,
                                                              commentsIndex: commentsIndex) }
    }
}

private extension StatsSummaryData {
    init?(dataArray: [Any],
          period: StatsPeriodUnit,
          periodIndex: Int,
          viewsIndex: Int,
          visitorsIndex: Int,
          likesIndex: Int,
          commentsIndex: Int) {
        guard
            let periodString = dataArray[periodIndex] as? String,
            let periodStart = type(of: self).parsedDate(from: periodString, for: period),
            let viewsCount = dataArray[viewsIndex] as? Int,
            let visitorsCount = dataArray[visitorsIndex] as? Int,
            let likesCount = dataArray[likesIndex] as? Int,
            let commentsCount = dataArray[commentsIndex] as? Int
            else {
                return nil
        }

        self.period = period
        self.periodStartDate = periodStart
        self.viewsCount = viewsCount
        self.visitorsCount = visitorsCount
        self.likesCount = likesCount
        self.commentsCount = commentsCount
    }

    static func parsedDate(from dateString: String, for period: StatsPeriodUnit) -> Date? {
        switch period {
        case .week:
            return self.weeksDateFormatter.date(from: dateString)
        case .day, .month, .year:
            return self.regularDateFormatter.date(from: dateString)
        }
    }

    static var regularDateFormatter: DateFormatter {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POS")
        df.dateFormat = "yyyy-MM-dd"
        return df
    }

    // We have our own handrolled date format for data broken up on week basis.
    // Example dates in this format are `2019W02W18` or `2019W02W11`.
    // The structure is `aaaaWbbWcc`, where:
    // - `aaaa` is four-digit year number,
    // - `bb` is two-digit month number
    // - `cc` is two-digit day number
    // Note that in contrast to almost every other date used in Stats, those dates
    // represent the _beginning_ of the period they're applying to, e.g.
    // data set for `2019W02W18` is containing data for the period of Feb 18 - Feb 24 2019.
    private static var weeksDateFormatter: DateFormatter {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POS")
        df.dateFormat = "yyyy'W'MM'W'dd"
        return df
    }
}
