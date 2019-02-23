public struct StatsPostingStreakInsight {
    public let currentStreakStart: Date
    public let currentStreakEnd: Date
    public let currentStreakLength: Int
    public let longestStreakStart: Date
    public let longestStreakEnd: Date
    public let longestStreakLength: Int

    public let postingEvents: [PostingStreakEvent]
}

public struct PostingStreakEvent {
    public let date: Date
    public let postCount: Int

    public init(date: Date, postCount: Int) {
        self.date = date
        self.postCount = postCount
    }
}

extension StatsPostingStreakInsight: InsightProtocol {

    //MARK: - InsightProtocol Conformance
    public static var pathComponent: String {
        return "stats/streak"
    }

    public init?(jsonDictionary: [String: AnyObject]) {
        guard
            let postsData = jsonDictionary["data"] as? [String: AnyObject],
            let streaks = jsonDictionary["streak"] as? [String: AnyObject],
            let longestData = streaks["long"] as? [String: AnyObject],
            let currentData = streaks["current"] as? [String: AnyObject],
            let longestStart = longestData["start"] as? String,
            let longestStartDate = StatsPostingStreakInsight.dateFormatter.date(from: longestStart),
            let longestEnd = longestData["end"] as? String,
            let longestEndDate = StatsPostingStreakInsight.dateFormatter.date(from: longestEnd),
            let longestLength = longestData["length"] as? Int,
            let currentStart = currentData["start"] as? String,
            let currentStartDate = StatsPostingStreakInsight.dateFormatter.date(from: currentStart),
            let currentEnd = currentData["end"] as? String,
            let currentEndDate = StatsPostingStreakInsight.dateFormatter.date(from: currentEnd),
            let currentLength = currentData["length"] as? Int
            else {
                return nil
        }

        let postingDates = postsData.keys
            .compactMap { Double($0) }
            .map { Date(timeIntervalSince1970: $0) }
            .map { Calendar.autoupdatingCurrent.startOfDay(for: $0) }

        let countedPosts = NSCountedSet(array: postingDates)

        let postingEvents = countedPosts.map {
            PostingStreakEvent(date: $0 as! Date, postCount: countedPosts.count(for: $0))
        }

        self.currentStreakStart = currentStartDate
        self.currentStreakEnd = currentEndDate
        self.currentStreakLength = currentLength
        self.longestStreakStart = longestStartDate
        self.longestStreakEnd = longestEndDate
        self.longestStreakLength = longestLength
        self.postingEvents = postingEvents
    }

    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }


    
}
