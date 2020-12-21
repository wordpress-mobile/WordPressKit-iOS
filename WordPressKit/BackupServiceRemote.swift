import Foundation
import WordPressShared
import CocoaLumberjack

open class BackupServiceRemote: ServiceRemoteWordPressComREST {
    
    /// Prepare a downloadable backup snapshot for a site.
    ///
    /// - Parameters:
    ///     - siteID: The target site's ID.
    ///     - rewindID: The rewindID of the snapshot to download.
    ///     - types: The types of items to restore.
    ///     - success: Closure to be executed on success.
    ///     - failure: Closure to be executed on error.
    ///
    /// - Returns: A backup snapshot object.
    ///
    open func prepareBackup(_ siteID: Int,
                            rewindID: Int? = nil,
                            types: RestoreTypes? = nil,
                            success: @escaping (_ backup: Backup) -> Void,
                            failure: @escaping (Error) -> Void) {
        let path = self.backupPath(for: siteID)
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

        wordPressComRestApi.POST(path, parameters: parameters, success: { response, _ in
            do {
                let decoder = JSONDecoder.apiDecoder
                let data = try JSONSerialization.data(withJSONObject: response, options: [])
                let envelope = try decoder.decode(Backup.self, from: data)
                success(envelope)
            } catch {
                failure(error)
            }
        }, failure: { error, _ in
            failure(error)
        })
    }

    /// Get the backup download status for a site.
    /// - Parameters:
    ///     - siteID: The target site's ID.
    ///     - downloadID: The download ID of the snapshot being downloaded. Returns all downloads if omitted.
    ///     - success: Closure to be executed on success.
    ///     - failure: Closure to be executed on error.
    ///
    /// - Returns: A backup snapshot object.
    ///
    open func getBackupStatus(_ siteID: Int,
                              downloadID: Int? = nil,
                              success: @escaping (_ backup: Backup) -> Void,
                              failure: @escaping (Error) -> Void) {
        
        let path: String
        if let downloadID = downloadID {
            path = self.backupPath(for: siteID, with: "\(downloadID)")
        } else {
            path = self.backupPath(for: siteID)
        }

        wordPressComRestApi.GET(path, parameters: nil, success: { response, _ in
            do {
                let decoder = JSONDecoder.apiDecoder
                let data = try JSONSerialization.data(withJSONObject: response, options: [])
                let envelope = try decoder.decode(Backup.self, from: data)
                success(envelope)
            } catch {
                failure(error)
            }
        }, failure: { error, _ in
            failure(error)
        })
    }

    // MARK: - Private

    private func backupPath(for siteID: Int, with path: String? = nil) -> String {
        var endpoint = "sites/\(siteID)/rewind/downloads/"

        if let path = path {
            endpoint = endpoint.appending(path)
        }

        return self.path(forEndpoint: endpoint, withVersion: ._2_0)
    }

}
