public struct StatsFileDownloadsTimeIntervalData {
    public let period: StatsPeriodUnit
    public let periodEndDate: Date

    public let totalDownloadsCount: Int
    public let otherDownloadsCount: Int
    public let fileDownloads: [StatsFileDownload]

    public init(period: StatsPeriodUnit,
                periodEndDate: Date,
                fileDownloads: [StatsFileDownload],
                totalDownloadsCount: Int,
                otherDownloadsCount: Int) {
        self.period = period
        self.periodEndDate = periodEndDate
        self.fileDownloads = fileDownloads
        self.totalDownloadsCount = totalDownloadsCount
        self.otherDownloadsCount = otherDownloadsCount
    }
}

public struct StatsFileDownload {
    public let file: String
    public let downloadCount: Int
    public let relativeURL: String
    public let downloadURL: URL

    public init(file: String,
                downloadCount: Int,
                relativeURL: String,
                downloadURL: URL) {
        self.file = file
        self.downloadCount = downloadCount
        self.relativeURL = relativeURL
        self.downloadURL = downloadURL
    }
}

extension StatsFileDownloadsTimeIntervalData: StatsTimeIntervalData {
    public static var pathComponent: String {
        return "stats/file-downloads"
    }

    public static func queryProperties(with date: Date, period: StatsPeriodUnit, maxCount: Int) -> [String: String] {
        // num = number of periods to include in the query. default: 1.
        return ["num": String(maxCount)]
    }

    public init?(date: Date, period: StatsPeriodUnit, jsonDictionary: [String: AnyObject]) {
        guard
            let unwrappedDays = type(of: self).unwrapDaysDictionary(jsonDictionary: jsonDictionary),
            let fileDownloadsDict = unwrappedDays["files"] as? [[String: AnyObject]]
            else {
                return nil
        }

        let fileDownloads: [StatsFileDownload] = fileDownloadsDict.compactMap {
            guard let file = $0["filename"] as? String,
                  let downloads = $0["downloads"] as? Int,
                  let relativeURLString = $0["relative_url"] as? String,
                  let downloadURLString = $0["download_url"] as? String,
                  let downloadURL = URL(string: downloadURLString)
            else {
                return nil
            }

            return StatsFileDownload(
                file: file,
                downloadCount: downloads,
                relativeURL: relativeURLString, 
                downloadURL: downloadURL
            )
        }

        self.periodEndDate = date
        self.period = period
        self.fileDownloads = fileDownloads
        self.totalDownloadsCount = unwrappedDays["total_downloads"] as? Int ?? 0
        self.otherDownloadsCount = unwrappedDays["other_downloads"] as? Int ?? 0
    }
}
