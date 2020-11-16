import Foundation
import WordPressShared
import CocoaLumberjack

open class ActivityServiceRemote: ServiceRemoteWordPressComREST {

    public enum ResponseError: Error {
        case decodingFailure
    }

    /// Retrieves activity events associated to a site.
    ///
    /// - Parameters:
    ///     - siteID: The target site's ID.
    ///     - offset: The first N activities to be skipped in the returned array.
    ///     - count: Number of objects to retrieve.
    ///     - after: Only activies after the given Date will be returned
    ///     - before: Only activies before the given Date will be returned
    ///     - group: Array of strings of activity types, eg. post, attachment, user
    ///     - success: Closure to be executed on success
    ///     - failure: Closure to be executed on error.
    ///
    /// - Returns: An array of activities and a boolean indicating if there's more activities to fetch.
    ///
    open func getActivityForSite(_ siteID: Int,
                                   offset: Int = 0,
                                   count: Int,
                                   after: Date? = nil,
                                   before: Date? = nil,
                                   group: [String] = [],
                                   success: @escaping (_ activities: [Activity], _ hasMore: Bool) -> Void,
                                   failure: @escaping (Error) -> Void) {
        let endpoint = "sites/\(siteID)/activity"
        let path = self.path(forEndpoint: endpoint, withVersion: ._2_0)
        let pageNumber = (offset / count + 1)
        var parameters: [String: AnyObject] = [
            "number": count as AnyObject,
            "page": pageNumber as AnyObject
        ]

        if !group.isEmpty {
            parameters["group[]"] = group.joined(separator: ",") as AnyObject
        }

        if let after = after {
            parameters["after"] = format(date: after) as AnyObject
        }

        if let before = before {
            parameters["before"] = format(date: before) as AnyObject
        }

        wordPressComRestApi.GET(path,
                                parameters: parameters,
                                success: { response, _ in
                                    do {
                                        let (activities, totalItems) = try self.mapActivitiesResponse(response)
                                        let hasMore = totalItems > pageNumber * (count + 1)
                                        success(activities, hasMore)
                                    } catch {
                                        DDLogError("Error parsing activity response for site \(siteID)")
                                        DDLogError("\(error)")
                                        DDLogDebug("Full response: \(response)")
                                        failure(error)
                                    }
                                }, failure: { error, _ in
                                    failure(error)
                                })
    }

    /// Retrieves the site current rewind state.
    ///
    /// - Parameters:
    ///     - siteID: The target site's ID.
    ///
    /// - Returns: The current rewind status for the site.
    ///
    open func getRewindStatus(_ siteID: Int,
                                success: @escaping (RewindStatus) -> Void,
                                failure: @escaping (Error) -> Void) {
        let endpoint = "sites/\(siteID)/rewind"
        let path = self.path(forEndpoint: endpoint, withVersion: ._2_0)

        wordPressComRestApi.GET(path,
                                parameters: nil,
                                success: { response, _ in
                                    guard let rewindStatus = response as? [String: AnyObject] else {
                                        failure(ResponseError.decodingFailure)
                                        return
                                    }
                                    do {
                                        let status = try RewindStatus(dictionary: rewindStatus)
                                        success(status)
                                    } catch {
                                        DDLogError("Error parsing rewind response for site \(siteID)")
                                        DDLogError("\(error)")
                                        DDLogDebug("Full response: \(response)")
                                        failure(ResponseError.decodingFailure)
                                    }
                                }, failure: { error, _ in
                                    //FIXME: A hack to support free WPCom sites and Rewind. Should be obsolote as soon as the backend
                                    // stops returning 412's for those sites.
                                    if let error = error as? WordPressComRestApiError, error == WordPressComRestApiError.preconditionFailure {
                                        let status = RewindStatus(state: .unavailable)
                                        success(status)
                                        return
                                    }
                                    failure(error)
                                })
    }

    /// Formats a Date to yyyy-MM-dd
    ///
    /// - Parameters:
    ///     - date: A Date
    ///
    /// - Returns: The given Date in a yyyy-MM-dd String format
    ///
    private func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

}

private extension ActivityServiceRemote {

    func mapActivitiesResponse(_ response: AnyObject) throws -> ([Activity], Int) {

        guard let json = response as? [String: AnyObject],
            let totalItems = json["totalItems"] as? Int else {
                throw ActivityServiceRemote.ResponseError.decodingFailure
        }

        guard totalItems > 0 else {
            return ([], 0)
        }

        guard let current = json["current"] as? [String: AnyObject],
            let orderedItems = current["orderedItems"] as? [[String: AnyObject]] else {
                throw ActivityServiceRemote.ResponseError.decodingFailure
        }

        let activities = try orderedItems.map { activity -> Activity in
            return try Activity(dictionary: activity)
        }

        return (activities, totalItems)
    }

}
