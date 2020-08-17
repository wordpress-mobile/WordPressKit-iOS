import UIKit

public class FeatureFlagRemote: ServiceRemoteWordPressComREST {

    public typealias FeatureFlagResponseCallback = (Result<FeatureFlagList, Error>) -> Void

    public enum FeatureFlagRemoteError: Error {
        case InvalidDataError
    }

    public func getRemoteFeatureFlags(forDeviceId deviceId: String, callback: @escaping FeatureFlagResponseCallback) {

        let endpoint = "mobile-feature-flags"
        let path = self.path(forEndpoint: endpoint, withVersion: ._2_0)

        let parameters: [String: AnyObject] = [
            "device_id": deviceId as NSString,
            "platform": "apple" as NSString,
            "build_number": NSString(string: Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Unknown"),
            "marketing_version": NSString(string: Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Unknown"),
        ]
        
        wordPressComRestApi.GET(path,
                                parameters: parameters,
                                success: { response, _ in
                                    
                                    if let featureFlagList = response as? NSArray {
                                        callback(.success(featureFlagList.compactMap { row -> FeatureFlag? in
                                            guard let row = row as? NSDictionary,
                                                let key = row.allKeys.first as? String,
                                                let value = row.allValues.first as? Bool,
                                                row.count == 1
                                                else {
                                                    return nil
                                                }

                                            return FeatureFlag(title: key, value: value)
                                        }))
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
