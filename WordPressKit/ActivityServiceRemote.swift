import Foundation
import WordPressShared
import CocoaLumberjack

open class ActivityServiceRemote: ServiceRemoteWordPressComREST {

    public enum ResponseError: Error {
        case decodingFailure
    }

    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = ("yyyy-MM-dd HH:mm:ss")
        return formatter
    }()

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

        if let after = after, let before = before,
           let lastSecondOfBeforeDay = Calendar.current.date(byAdding: .second, value: 86399, to: before) {
            parameters["after"] = formatter.string(from: after) as AnyObject
            parameters["before"] = formatter.string(from: lastSecondOfBeforeDay) as AnyObject
        } else if let on = after ?? before {
            parameters["on"] = formatter.string(from: on) as AnyObject
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

    /// Retrieves activity groups associated with a site.
    ///
    /// - Parameters:
    ///     - siteID: The target site's ID.
    ///     - after: Only activity groups after the given Date will be returned.
    ///     - before: Only activity groups before the given Date will be returned.
    ///     - success: Closure to be executed on success.
    ///     - failure: Closure to be executed on error.
    ///
    /// - Returns: An array of available activity groups for a site.
    ///
    open func getActivityGroupsForSite(_ siteID: Int,
                                       after: Date? = nil,
                                       before: Date? = nil,
                                       success: @escaping (_ groups: [ActivityGroup]) -> Void,
                                       failure: @escaping (Error) -> Void) {
        let endpoint = "sites/\(siteID)/activity/count/group"
        let path = self.path(forEndpoint: endpoint, withVersion: ._2_0)
        var parameters: [String: AnyObject] = [:]

        if let after = after, let before = before,
           let lastSecondOfBeforeDay = Calendar.current.date(byAdding: .second, value: 86399, to: before) {
            parameters["after"] = formatter.string(from: after) as AnyObject
            parameters["before"] = formatter.string(from: lastSecondOfBeforeDay) as AnyObject
        } else if let on = after ?? before {
            parameters["on"] = formatter.string(from: on) as AnyObject
        }

        wordPressComRestApi.GET(path,
                                parameters: parameters,
                                success: { response, _ in
                                    do {
                                        let groups = try self.mapActivityGroupsResponse(response)
                                        success(groups)
                                    } catch {
                                        DDLogError("Error parsing activity groups for site \(siteID)")
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
    
    func mapActivityGroupsResponse(_ response: AnyObject) throws -> ([ActivityGroup]) {
        
        guard let json = response as? [String: AnyObject],
              let rawGroups = json["groups"] as? [String: AnyObject] else {
                throw ActivityServiceRemote.ResponseError.decodingFailure
        }
        
        let groups: [ActivityGroup] = try rawGroups.map { (key, value) -> ActivityGroup in
            guard let group = value as? [String: AnyObject] else {
                throw ActivityServiceRemote.ResponseError.decodingFailure
            }
            return try ActivityGroup(key, dictionary: group)
        }
        
        return groups
    }

}
