import Foundation

/// A service that returns the Jetpack Capabilities for a set of blogs
public class JetpackCapabilitiesServiceRemote: ServiceRemoteWordPressComREST {


    /// Returns a Dictionary of capabilities for each given siteID
    /// - Parameters:
    ///   - siteIds: an array of Int representing siteIDs
    ///   - success: a success block that accepts a dictionary as a parameter
    ///   - failure: a failure block
    public func `for`(siteIds: [Int], success: @escaping ([String: AnyObject]) -> Void, failure: @escaping () -> Void) {

        let endpoint = "rewind/batch-capabilities"
        let path = self.path(forEndpoint: endpoint, withVersion: ._2_0)

        wordPressComRestApi.POST(path,
                                 parameters: ["sites": siteIds] as [String: AnyObject],
                                 success: {
                                     response, _  in
                                    guard let capabilities = response as? [String: AnyObject] else {
                                        failure()
                                        return
                                    }

                                    var jetpackCapabilities: [String: AnyObject] = [:]
                                    for (blogId, capabilities) in capabilities {
                                        jetpackCapabilities[blogId] = (capabilities["capabilities"] as? [String] ?? []) as AnyObject
                                    }
                                    success(jetpackCapabilities)
                                 }, failure: {
                                     error, _ in
                                     failure()
                                 })
    }
}
