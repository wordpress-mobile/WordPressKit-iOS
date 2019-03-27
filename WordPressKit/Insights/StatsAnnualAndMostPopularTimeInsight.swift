public struct StatsAnnualAndMostPopularTimeInsight {

    /// - A `DateComponents` object with one field populated: `weekday`.
    public let mostPopularDayOfWeek: DateComponents
    public let mostPopularDayOfWeekPercentage: Int

    /// - A `DateComponents` object with one field populated: `hour`.
    public let mostPopularHour: DateComponents
    public let mostPopularHourPercentage: Int

    public let annualInsightsYear: Int

    public let annualInsightsTotalPostsCount: Int
    public let annualInsightsTotalWordsCount: Int
    public let annualInsightsAverageWordsCount: Double

    public let annualInsightsTotalLikesCount: Int
    public let annualInsightsAverageLikesCount: Double

    public let annualInsightsTotalCommentsCount: Int
    public let annualInsightsAverageCommentsCount: Double

    public let annualInsightsTotalImagesCount: Int
    public let annualInsightsAverageImagesCount: Double

    public init(mostPopularDayOfWeek: DateComponents,
                mostPopularDayOfWeekPercentage: Int,
                mostPopularHour: DateComponents,
                mostPopularHourPercentage: Int,
                annualInsightsYear: Int,
                annualInsightsTotalPostsCount: Int,
                annualInsightsTotalWordsCount: Int,
                annualInsightsAverageWordsCount: Double,
                annualInsightsTotalLikesCount: Int,
                annualInsightsAverageLikesCount: Double,
                annualInsightsTotalCommentsCount: Int,
                annualInsightsAverageCommentsCount: Double,
                annualInsightsTotalImagesCount: Int,
                annualInsightsAverageImagesCount: Double) {
        self.mostPopularDayOfWeek = mostPopularDayOfWeek
        self.mostPopularDayOfWeekPercentage = mostPopularDayOfWeekPercentage

        self.mostPopularHour = mostPopularHour
        self.mostPopularHourPercentage = mostPopularHourPercentage

        self.annualInsightsYear = annualInsightsYear

        self.annualInsightsTotalPostsCount = annualInsightsTotalPostsCount
        self.annualInsightsTotalWordsCount = annualInsightsTotalWordsCount
        self.annualInsightsAverageWordsCount = annualInsightsAverageWordsCount

        self.annualInsightsTotalLikesCount = annualInsightsTotalLikesCount
        self.annualInsightsAverageLikesCount = annualInsightsAverageLikesCount

        self.annualInsightsTotalCommentsCount = annualInsightsTotalCommentsCount
        self.annualInsightsAverageCommentsCount = annualInsightsAverageCommentsCount

        self.annualInsightsTotalImagesCount = annualInsightsTotalImagesCount
        self.annualInsightsAverageImagesCount = annualInsightsAverageImagesCount
    }
}

extension StatsAnnualAndMostPopularTimeInsight: StatsInsightData {
    public static var pathComponent: String {
        return "stats/insights"
    }

    public init?(jsonDictionary: [String : AnyObject]) {
        guard
            let highestHour = jsonDictionary["highest_hour"] as? Int,
            let highestHourPercentageValue = jsonDictionary["highest_hour_percent"] as? Double,
            let highestDayOfWeek = jsonDictionary["highest_day_of_week"] as? Int,
            let highestDayOfWeekPercentageValue = jsonDictionary["highest_day_percent"] as? Double,
            let yearlyInsights = jsonDictionary["years"] as? [[String: AnyObject]],
            let latestYearlyInsight = yearlyInsights.last,
            let yearString = latestYearlyInsight["year"] as? String,
            let currentYear = Int(yearString),
            let postCount = latestYearlyInsight["total_posts"] as? Int,
            let wordsCount = latestYearlyInsight["total_words"] as? Int,
            let wordsAverage = latestYearlyInsight["avg_words"] as? Double,
            let likesCount = latestYearlyInsight["total_likes"] as? Int,
            let likesAverage = latestYearlyInsight["avg_likes"] as? Double,
            let commentsCount = latestYearlyInsight["total_comments"] as? Int,
            let commentsAverage = latestYearlyInsight["avg_comments"] as? Double,
            let imagesCount = latestYearlyInsight["total_images"] as? Int,
            let imagesAverage = latestYearlyInsight["avg_images"] as? Double
            else {
                return nil
        }

        let mappedWeekday: ((Int) -> Int) = {
            // iOS Calendar system is `1-based` and uses Sunday as the first day of the week.
            // The data returned from WP.com is `0-based` and uses Monday as the first day of the week.
            // This maps the WP.com data to iOS format.
            return $0 == 6 ? 0 : $0 + 2
        }

        let weekDayComponent = DateComponents(weekday: mappedWeekday(highestDayOfWeek))
        let hourComponents = DateComponents(hour: highestHour)

        self.mostPopularDayOfWeek = weekDayComponent
        self.mostPopularDayOfWeekPercentage = Int(highestDayOfWeekPercentageValue)
        self.mostPopularHour = hourComponents
        self.mostPopularHourPercentage = Int(highestHourPercentageValue)

        self.annualInsightsYear = currentYear

        self.annualInsightsTotalPostsCount = postCount
        self.annualInsightsTotalWordsCount = wordsCount
        self.annualInsightsAverageWordsCount = wordsAverage

        self.annualInsightsTotalLikesCount = likesCount
        self.annualInsightsAverageLikesCount = likesAverage

        self.annualInsightsTotalCommentsCount = commentsCount
        self.annualInsightsAverageCommentsCount = commentsAverage

        self.annualInsightsTotalImagesCount = imagesCount
        self.annualInsightsAverageImagesCount = imagesAverage
    }
}
