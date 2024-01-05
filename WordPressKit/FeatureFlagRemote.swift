import UIKit

open class FeatureFlagRemote: ServiceRemoteWordPressComREST {

    public typealias FeatureFlagResponseCallback = (Result<FeatureFlagList, Error>) -> Void

    public enum FeatureFlagRemoteError: Error {
        case InvalidDataError
    }

    open func getRemoteFeatureFlags(forDeviceId deviceId: String, callback: @escaping FeatureFlagResponseCallback) {
        let params = FetchAllEndpointParams(deviceId: deviceId)
        let endpoint = "mobile/feature-flags"
        let path = self.path(forEndpoint: endpoint, withVersion: ._2_0)
        var dictionary: [String: AnyObject]?

        do {
            dictionary = try params.dictionaryRepresentation()
        } catch let error {
            callback(.failure(error))
            return
        }

        wordPressComRestApi.GET(path,
                                parameters: dictionary,
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
                                    WPKitLogError("Error retrieving remote feature flags")
                                    WPKitLogError("\(error)")

                                    if let response = response {
                                        WPKitLogDebug("Response Code: \(response.statusCode)")
                                    }

                                    callback(.failure(error))
                                })
    }

    public struct FetchAllEndpointParams {
        let deviceId: String
        let platform: String
        let buildNumber: String
        let marketingVersion: String
        let identifier: String
    }
}

extension FeatureFlagRemote.FetchAllEndpointParams: Encodable {

    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case platform = "platform"
        case buildNumber = "build_number"
        case marketingVersion = "marketing_version"
        case identifier = "identifier"
    }

    init(deviceId: String, bundle: Bundle = .main) {
        self.deviceId = deviceId
        self.platform = "ios"
        self.buildNumber = bundle.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        self.marketingVersion = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        self.identifier = bundle.bundleIdentifier ?? "Unknown"
    }

    func dictionaryRepresentation() throws -> [String: AnyObject]? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return try JSONSerialization.jsonObject(with: data) as? [String: AnyObject]
    }
}
