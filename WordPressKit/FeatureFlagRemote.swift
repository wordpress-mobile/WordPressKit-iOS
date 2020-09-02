import UIKit

open class FeatureFlagRemote: ServiceRemoteWordPressComREST {

    public typealias FeatureFlagResponseCallback = (Result<FeatureFlagList, Error>) -> Void

    public enum FeatureFlagRemoteError: Error {
        case InvalidDataError
    }

    open func getRemoteFeatureFlags(forDeviceId deviceId: String, callback: @escaping FeatureFlagResponseCallback) {

        let endpoint = "mobile/feature-flags"
        let path = self.path(forEndpoint: endpoint, withVersion: ._2_0)

        let parameters: [String: AnyObject] = [
            "device_id": deviceId as NSString,
            "platform": "apple" as NSString,
            "build_number": NSString(string: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"),
            "marketing_version": NSString(string: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"),
            "bundle_identifier": NSString(string: Bundle.main.bundleIdentifier ?? "Unknown")
        ]

        wordPressComRestApi.GET(path,
                                parameters: parameters,
                                success: { response, _ in
                                    
                                    if let featureFlagList = response as? NSDictionary {

                                        let reconstitutedList = featureFlagList.compactMap { row -> FeatureFlag? in
                                            guard
                                                let title = row.key as? String,
                                                let value = row.value as? Bool
                                                else {
                                                    return nil
                                                }

                                            return FeatureFlag(title: title, value: value)
                                        }.sorted()

                                        callback(.success(reconstitutedList))
                                    } else {
                                        callback(.failure(FeatureFlagRemoteError.InvalidDataError))
                                    }

                                }, failure: { error, response in
                                    DDLogError("Error retrieving remote feature flags")
                                    DDLogError("\(error)")

                                    if let response = response {
                                        DDLogDebug("Response Code: \(response.statusCode)")
                                    }

                                    callback(.failure(error))
                                })
    }
}
