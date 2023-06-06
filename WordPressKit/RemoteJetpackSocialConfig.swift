import Foundation

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

// MARK: - Publicize Info

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
