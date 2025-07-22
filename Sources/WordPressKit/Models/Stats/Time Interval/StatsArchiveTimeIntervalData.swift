import Foundation

public struct StatsArchiveTimeIntervalData {
    public let period: StatsPeriodUnit
    public let unit: StatsPeriodUnit?
    public let periodEndDate: Date
    public let summary: StatsArchiveSummary

    public init(period: StatsPeriodUnit,
                unit: StatsPeriodUnit? = nil,
                periodEndDate: Date,
                summary: StatsArchiveSummary) {
        self.period = period
        self.unit = unit
        self.periodEndDate = periodEndDate
        self.summary = summary
    }
}

public struct StatsArchiveSummary {
    public let other: [StatsArchiveItem]
    public let author: [StatsArchiveItem]

    public init(other: [StatsArchiveItem], author: [StatsArchiveItem]) {
        self.other = other
        self.author = author
    }
}

public struct StatsArchiveItem {
    public let href: String
    public let value: String
    public let views: Int

    public init(href: String, value: String, views: Int) {
        self.href = href
        self.value = value
        self.views = views
    }
}

extension StatsArchiveTimeIntervalData: StatsTimeIntervalData {
    public static var pathComponent: String {
        return "stats/archives"
    }

    public static func queryProperties(with date: Date, period: StatsPeriodUnit, maxCount: Int) -> [String: String] {
        return ["max": String(maxCount)]
    }

    public init?(date: Date, period: StatsPeriodUnit, jsonDictionary: [String: AnyObject]) {
        self.init(date: date, period: period, unit: nil, jsonDictionary: jsonDictionary)
    }

    public init?(date: Date, period: StatsPeriodUnit, unit: StatsPeriodUnit?, jsonDictionary: [String: AnyObject]) {
        guard let summary = jsonDictionary["summary"] as? [String: AnyObject] else {
            return nil
        }

        let otherItems = (summary["other"] as? [[String: AnyObject]] ?? []).compactMap { StatsArchiveItem(jsonDictionary: $0) }
        let authorItems = (summary["author"] as? [[String: AnyObject]] ?? []).compactMap { StatsArchiveItem(jsonDictionary: $0) }

        let archiveSummary = StatsArchiveSummary(other: otherItems, author: authorItems)

        self.period = period
        self.unit = unit
        self.periodEndDate = date
        self.summary = archiveSummary
    }
}

private extension StatsArchiveItem {
    init?(jsonDictionary: [String: AnyObject]) {
        guard
            let href = jsonDictionary["href"] as? String,
            let value = jsonDictionary["value"] as? String,
            let views = jsonDictionary["views"] as? Int
        else {
            return nil
        }

        self.href = href
        self.value = value
        self.views = views
    }
}
