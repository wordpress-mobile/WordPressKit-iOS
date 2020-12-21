
@objc public class ActivityServiceRemote_ApiVersion1_0: ServiceRemoteWordPressComREST {

    public enum ResponseError: Error {
        case decodingFailure
    }
    
    /// Makes a request to Restore a site to a previous state.
    ///
    /// - Parameters:
    ///     - siteID: The target site's ID.
    ///     - rewindID: The rewindID to restore to.
    ///     - types: The types of items to restore.
    ///     - success: Closure to be executed on success
    ///     - failure: Closure to be executed on error.
    ///
    /// - Returns: A restoreID to check the status of the rewind request.
    ///
    @objc public func restoreSite(_ siteID: Int,
                                  rewindID: String,
                                  types: RestoreTypes? = nil,
                                  success: @escaping (_ restoreID: String) -> Void,
                                  failure: @escaping (Error) -> Void) {
        let endpoint = "activity-log/\(siteID)/rewind/to/\(rewindID)"
        let path = self.path(forEndpoint: endpoint, withVersion: ._1_0)
        var parameters: [String: AnyObject] = [:]

        if let types = types {
            var restoreTypes: [String: AnyObject] = [:]
            restoreTypes["themes"] = types.themes as AnyObject
            restoreTypes["plugins"] = types.plugins as AnyObject
            restoreTypes["uploads"] = types.uploads as AnyObject
            restoreTypes["sqls"] = types.sqls as AnyObject
            restoreTypes["roots"] = types.roots as AnyObject
            restoreTypes["contents"] = types.contents as AnyObject
            parameters["types"] = restoreTypes as AnyObject
        }

        wordPressComRestApi.POST(path,
                                 parameters: parameters,
                                 success: { response, _ in
                                    guard let restoreID = response["restore_id"] as? Int else {
                                        failure(ResponseError.decodingFailure)
                                        return
                                    }
                                    success(String(restoreID))
        },
                                 failure: { error, _ in
                                    failure(error)
        })
    }
}
