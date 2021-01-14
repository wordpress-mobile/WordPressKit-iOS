import Foundation

/// A service that returns the Jetpack Capabilities for a set of blogs
open class JetpackCapabilitiesServiceRemote: ServiceRemoteWordPressComREST {

    /// Returns a Dictionary of capabilities for each given siteID
    /// - Parameters:
    ///   - siteIds: an array of Int representing siteIDs
    ///   - success: a success block that accepts a dictionary as a parameter
    open func `for`(siteIds: [Int], success: @escaping ([String: AnyObject]) -> Void) {
        var jetpackCapabilities: [String: AnyObject] = [:]
        let dispatchGroup = DispatchGroup()

        siteIds.forEach { siteID in
            dispatchGroup.enter()

            let endpoint = "sites/\(siteID)/rewind/capabilities"
            let path = self.path(forEndpoint: endpoint, withVersion: ._2_0)

            wordPressComRestApi.GET(path,
                                     parameters: nil,
                                     success: { response, _  in
                                        if let capabilities = (response as? [String: AnyObject])?["capabilities"] as? [String] {
                                            jetpackCapabilities["\(siteID)"] = capabilities as AnyObject
                                        }

                                        dispatchGroup.leave()
                                     }, failure: { error, _ in
                                        dispatchGroup.leave()
                                     })
        }

        dispatchGroup.notify(queue: .main) {
            success(jetpackCapabilities)
        }
    }

}
