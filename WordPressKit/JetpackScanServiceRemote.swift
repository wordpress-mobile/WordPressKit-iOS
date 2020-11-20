import Foundation
import WordPressShared
import CocoaLumberjack


public class JetpackScanServiceRemote: ServiceRemoteWordPressComREST {
    public func getScanAvailableForSite(_ siteID: Int, success: @escaping(Bool) -> Void, failure: @escaping(Error) -> Void) {
        getScanForSite(siteID, success: { (scan) in
            success(scan.isEnabled)
        }, failure: failure)
    }

    public func getCurrentScanStatusForSite(_ siteID: Int, success: @escaping(JetpackScanStatus?) -> Void, failure: @escaping(Error) -> Void) {
        getScanForSite(siteID, success: { scan in
            success(scan.current)
        }, failure: failure)
    }

    public func getThreatsForSite(_ siteID: Int, success: @escaping([JetpackScanThreat]?) -> Void, failure: @escaping(Error) -> Void) {
        getScanForSite(siteID, success: { scan in
            success(scan.threats)
        }, failure: failure)
    }

    /// Starts a scan for a site
    public func startScanForSite(_ siteID: Int, success: @escaping(Bool) -> Void, failure: @escaping(Error) -> Void) {
        let path = self.scanPath(for: siteID, with: "enqueue")

        wordPressComRestApi.POST(path, parameters: nil, success: { (response, _) in
            guard let responseValue = response["success"] as? Bool else {
                success(false)
                return
            }

            success(responseValue)
        }, failure: { (error, _) in
            failure(error)
        })
    }

    /// Gets the main scan object
    public func getScanForSite(_ siteID: Int, success: @escaping(JetpackScan) -> Void, failure: @escaping(Error) -> Void) {
        let path = self.scanPath(for: siteID)

        wordPressComRestApi.GET(path, parameters: nil, success: { (response, _) in
            do {
                let decoder = JSONDecoder.apiDecoder
                let data = try JSONSerialization.data(withJSONObject: response, options: [])
                let envelope = try decoder.decode(JetpackScan.self, from: data)

                success(envelope)
            } catch {
                failure(error)
            }

        }, failure: { (error, _) in
            failure(error)
        })
    }

    // MARK: - Private
    private func scanPath(for siteID: Int, with path: String? = nil) -> String {
        var endpoint = "sites/\(siteID)/scan/"

        if let path = path {
            endpoint = endpoint.appending(path)
        }

        return self.path(forEndpoint: endpoint, withVersion: ._2_0)
    }


}
