/// Encapsulates remote service logic related to Jetpack Social.
public class JetpackSocialServiceRemote: ServiceRemoteWordPressComREST {

    /// Retrieves the Publicize information for the given site.
    ///
    /// Note: Sites with disabled share limits will return success with nil value.
    ///
    /// - Parameters:
    ///   - siteID: The target site's dotcom ID.
    ///   - completion: Closure to be called once the request completes.
    public func fetchPublicizeInfo(for siteID: Int,
                                   completion: @escaping (Result<RemotePublicizeInfo?, Error>) -> Void) {
        let path = path(forEndpoint: "sites/\(siteID)/jetpack-social", withVersion: ._2_0)
        wordPressComRestApi.GET(path, parameters: nil) { result, response in
            switch result {
            case .success(let responseObject):
                do {
                    let data = try JSONSerialization.data(withJSONObject: responseObject)
                    let config = try JSONDecoder.apiDecoder.decode(RemoteJetpackSocialConfig.self, from: data)
                    completion(.success(config.publicizeInfo))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

/// MARK: MODELS

/// TODO: Docs
public struct RemoteJetpackSocialConfig: Decodable {
    public let isShareLimitEnabled: Bool
    public let publicizeInfo: RemotePublicizeInfo?
    public let isEnhancedPublishingEnabled: Bool
    public let isSocialImageGeneratorEnabled: Bool

    public enum CodingKeys: CodingKey {
        case isShareLimitEnabled
        case isEnhancedPublishingEnabled
        case isSocialImageGeneratorEnabled
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isShareLimitEnabled = try container.decode(Bool.self, forKey: .isShareLimitEnabled)
        // when share limit is disabled, Publicize info fields are excluded from the response.
        publicizeInfo = try? RemotePublicizeInfo(from: decoder)
        isEnhancedPublishingEnabled = try container.decode(Bool.self, forKey: .isEnhancedPublishingEnabled)
        isSocialImageGeneratorEnabled = try container.decode(Bool.self, forKey: .isSocialImageGeneratorEnabled)
    }
}

/// TODO: Docs
public struct RemotePublicizeInfo: Decodable {
    public let shareLimit: Int
    public let toBePublicizedCount: Int
    public let sharedPostsCount: Int
    public let sharesRemaining: Int

    private enum CodingKeys: CodingKey {
        case shareLimit
        case toBePublicizedCount
        case sharedPostsCount
        case sharesRemaining
    }
}
