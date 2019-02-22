import Foundation

// This name isn't great! After finishing the work on StatsRefresh we'll get rid of the "old"
// one and rename this to not have "V2" in it, but we want to keep the old one around
// for a while still.

public class StatsServiceRemoteV2: ServiceRemoteWordPressComREST {

    public enum ResponseError: Error {
        case decodingFailure
    }

    private let siteID: Int
    private let siteTimezone: TimeZone

    private lazy var periodDataQueryDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    public init(wordPressComRestApi api: WordPressComRestApi, siteID: Int, siteTimezone: TimeZone) {
        self.siteID = siteID
        self.siteTimezone = siteTimezone
        super.init(wordPressComRestApi: api)
    }

    /// Responsible for fetching Stats data for Insights — latest data about a site,
    /// in general — not considering a specific slice of time.
    /// For a possible set of returned types, see objects that conform to `InsightProtocol`.
    public func getInsight<InsightType: InsightProtocol>(completion: @escaping ((InsightType?, Error?) -> Void)) {
        let properties = InsightType.queryProperties as [String: AnyObject]
        let pathComponent = InsightType.pathComponent

        let path = self.path(forEndpoint: "sites/\(siteID)/\(pathComponent)/", withVersion: ._1_1)

        wordPressComRestApi.GET(path, parameters: properties, success: { (response, _) in
            guard
                let jsonResponse = response as? [String: AnyObject],
                let insight = InsightType(jsonDictionary: jsonResponse)
            else {
                completion(nil, ResponseError.decodingFailure)
                return
            }

            completion(insight, nil)
        }, failure: { (error, _) in
            completion(nil, error)
        })
    }


    /// Used to fetch data about site over a specific timeframe.
    /// - parameters:
    ///   - period: An enum representing whether either a day, a week, a month or a year worth's of data.
    ///   - endingOn: Date on which the `period` for which data you're interested in **is ending**.
    ///    e.g. if you want data spanning 11-17 Feb 2019, you should pass in a period of `.week` and an
    ///    ending date of `Feb 17 2019`.
    ///   - limit: Limit of how many objects you want returned for your query. Default is `10`. `0` means no limit.
    public func getData<TimeStatsType: TimeStatsProtocol>(for period: StatsPeriodUnit,
                                                          endingOn: Date,
                                                          limit: Int = 10,
                                                          completion: @escaping ((TimeStatsType?, Error?) -> Void)) {
        let pathComponent = TimeStatsType.pathComponent
        let path = self.path(forEndpoint: "sites/\(siteID)/\(pathComponent)/", withVersion: ._1_1)

        let staticProperties = ["period": period.stringValue,
                                "date": periodDataQueryDateFormatter.string(from: endingOn),
                                "max": limit as AnyObject] as [String: AnyObject]

        let classProperties = TimeStatsType.queryProperties(with: endingOn, period: period) as [String: AnyObject]

        let properties = staticProperties.merging(classProperties) { val1, _ in
            return val1
        }

        wordPressComRestApi.GET(path, parameters: properties, success: { (response, _) in
            guard
                let jsonResponse = response as? [String: AnyObject],
                let dateString = jsonResponse["date"] as? String,
                let date = self.periodDataQueryDateFormatter.date(from: dateString)
                else {
                    completion(nil, ResponseError.decodingFailure)
                    return
            }

            let periodString = jsonResponse["period"] as? String
            let parsedPeriod = periodString.flatMap { StatsPeriodUnit(string: $0) } ?? period
            // some responses omit this field!  not a reason to fail a whole request parsing though.

            guard
                let timestats = TimeStatsType(date: date,
                                              period: parsedPeriod,
                                              jsonDictionary: jsonResponse)
                else {
                    completion(nil, ResponseError.decodingFailure)
                    return
            }

            completion(timestats, nil)
        }, failure: { (error, _) in
            completion(nil, error)
        })
    }
}

// MARK: - StatsLastPostInsight-specific hack
extension StatsServiceRemoteV2 {
    // "Last Post" Insights are "fun" in the way that they require multiple requests to actually create them,
    // so we do this "fun" dance in a separate method.
    public func getInsight(completion: @escaping ((StatsLastPostInsight?, Error?) -> Void)) {
         getLastPostInsight(completion: completion)
    }

    private func getLastPostInsight(completion: @escaping ((StatsLastPostInsight?, Error?) -> Void)) {
        let properties = StatsLastPostInsight.queryProperties as [String: AnyObject]
        let pathComponent = StatsLastPostInsight.pathComponent

        let path = self.path(forEndpoint: "sites/\(siteID)/\(pathComponent)", withVersion: ._1_1)

        wordPressComRestApi.GET(path, parameters: properties, success: { (response, _) in
            guard
                let jsonResponse = response as? [String: AnyObject],
                let posts = jsonResponse["posts"] as? [[String: AnyObject]],
                let post = posts.first,
                let postID = post["ID"] as? Int else {
                    completion(nil, ResponseError.decodingFailure)
                    return
            }

            self.getPostViews(for: postID) { (views, error) in
                guard
                    let views = views,
                    let insight = StatsLastPostInsight(jsonDictionary: post, views: views) else {
                        completion(nil, ResponseError.decodingFailure)
                        return

                }

                completion(insight, nil)
            }
        }, failure: {(error, _) in
            completion(nil, error)
        })
    }

    private func getPostViews(`for` postID: Int, completion: @escaping ((Int?, Error?) -> Void)) {
        let parameters = ["fields": "views" as AnyObject]

        let path = self.path(forEndpoint: "sites/\(siteID)/stats/post/\(postID)", withVersion: ._1_1)

        wordPressComRestApi.GET(path,
                                parameters: parameters,
                                success: { (response, _) in
                                    guard
                                        let jsonResponse = response as? [String: AnyObject],
                                        let views = jsonResponse["views"] as? Int else {
                                            completion(nil, ResponseError.decodingFailure)
                                            return
                                    }
                                    completion(views, nil)
                                }, failure:  { (error, _) in
                                    completion(nil, error)
                                }
        )
    }
}

// MARK - PublishedPostsStatsType-specific hack
extension StatsServiceRemoteV2 {

    // PublishedPostsStatsType hit a different endpoint and with different parameters
    // then the rest of the time-based types — we need to handle them separately here.
    public func getData(for period: StatsPeriodUnit,
                        endingOn: Date,
                        limit: Int = 10,
                        completion: @escaping ((PublishedPostsStatsType?, Error?) -> Void)) {

        let pathComponent = StatsLastPostInsight.pathComponent

        let path = self.path(forEndpoint: "sites/\(siteID)/\(pathComponent)", withVersion: ._1_1)

        let properties = ["number": limit,
                          "fields": "ID, title, URL",
                          "after": ISO8601DateFormatter().string(from: startDate(for: period, endDate: endingOn)),
                          "before": ISO8601DateFormatter().string(from: endingOn)] as [String: AnyObject]

        wordPressComRestApi.GET(path,
                                parameters: properties,
                                success: { (response, _) in
                                    guard
                                        let jsonResponse = response as? [String: AnyObject],
                                        let response = PublishedPostsStatsType(date: endingOn, period: period, jsonDictionary: jsonResponse) else {
                                            completion(nil, ResponseError.decodingFailure)
                                            return
                                    }
                                    completion(response, nil)
                                }, failure: { (error, _) in
                                    completion(nil, error)
                                }
            )
    }

    private func startDate(for period: StatsPeriodUnit, endDate: Date) -> Date {
        switch  period {
        case .day:
            return Calendar.autoupdatingCurrent.startOfDay(for: endDate)
        case .week:
            let weekAgo = Calendar.autoupdatingCurrent.date(byAdding: .day, value: -6, to: endDate)!
            return Calendar.autoupdatingCurrent.startOfDay(for: weekAgo)
        case .month:
            let monthAgo = Calendar.autoupdatingCurrent.date(byAdding: .month, value: -1, to: endDate)!
            let firstOfMonth = Calendar.autoupdatingCurrent.date(bySetting: .day, value: 1, of: monthAgo)!

            return Calendar.autoupdatingCurrent.startOfDay(for: firstOfMonth)
        case .year:
            let yearAgo = Calendar.autoupdatingCurrent.date(byAdding: .year, value: -1, to: endDate)!
            let january = Calendar.autoupdatingCurrent.date(bySetting: .month, value: 1, of: yearAgo)!
            let jan1 = Calendar.autoupdatingCurrent.date(bySetting: .day, value: 1, of: january)!

            return Calendar.autoupdatingCurrent.startOfDay(for: jan1)
        }
    }

}

// This serves both as a way to get the query properties in a "nice" way,
// but also as a way to narrow down the generic type in `getInsight(completion:)` method.
public protocol InsightProtocol {
    static var queryProperties: [String: String] { get }
    static var pathComponent: String { get }

    init?(jsonDictionary: [String: AnyObject])
}

// naming is hard.
public protocol TimeStatsProtocol {
    static var pathComponent: String { get }

    var period: StatsPeriodUnit { get }
    var periodEndDate: Date { get }

    init?(date: Date, period: StatsPeriodUnit, jsonDictionary: [String: AnyObject])

    static func queryProperties(with date: Date, period: StatsPeriodUnit) -> [String: String]
}

extension TimeStatsProtocol {

    public static func queryProperties(with date: Date, period: StatsPeriodUnit) -> [String: String] {
        return [:]
    }

    // Most of the responses for time data come in a unwieldy format, that requires awkwkard unwrapping
    // at the call-site — unfortunately not _all of them_, which means we can't just do it at the request level.
    static func unwrapDaysDictionary(jsonDictionary: [String: AnyObject]) -> [String: AnyObject]? {
        guard
            let days = jsonDictionary["days"] as? [String: AnyObject],
            let firstKey = days.keys.first,
            let firstDay = days[firstKey] as? [String: AnyObject]
            else {
                return nil
        }
        return firstDay
    }

}

// We'll bring `StatsPeriodUnit` into this file when the "old" `WPStatsServiceRemote` gets removed.
// For now we can piggy-back off the old type and add this as an extension.
extension StatsPeriodUnit {
    var stringValue: String {
        switch self {
        case .day:
            return "day"
        case .week:
            return "week"
        case .month:
            return "month"
        case .year:
            return "year"
        }
    }

    init?(string: String) {
        switch string {
        case "day":
            self = .day
        case "week":
            self = .week
        case "month":
            self = .month
        case "year":
            self = .year
        default:
            return nil
        }
    }
}

extension InsightProtocol {

    // A big chunk of those use the same endpoint and queryProperties.. Let's simplify the protocol conformance in those cases.

    public static var queryProperties: [String: String] {
        return [:]
    }

    public static var pathComponent: String {
        return "stats/"
    }
}
