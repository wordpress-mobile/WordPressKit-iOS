import Foundation

/// This enum matches the privacy setting constants defined in Jetpack:
/// https://github.com/Automattic/jetpack/blob/a2ccfb7978184e306211292a66ed49dcf38a517f/projects/packages/videopress/src/utility-functions.php#L13-L17
@objc public enum VideoPressPrivacySetting: Int, Encodable {
    case isPublic = 0
    case isPrivate = 1
    case siteDefault = 2
}

@objcMembers public class RemoteVideoPressVideo: NSObject, Encodable {

    /// The following properties match the response parameters from the `videos` endpoint:
    /// https://developer.wordpress.com/docs/api/1.1/get/videos/%24guid/
    ///
    /// However, it's missing the following parameters that could be added in the future if needed:
    /// - files
    /// - file_url_base
    /// - upload_date
    /// - files_status
    /// - subtitles
    public var id: String
    public var title: String?
    public var videoDescription: String?
    public var width: Int?
    public var height: Int?
    public var duration: Int?
    public var displayEmbed: Bool?
    public var allowDownload: Bool?
    public var rating: String?
    public var privacySetting: VideoPressPrivacySetting = .siteDefault
    public var posterURL: URL?
    public var originalURL: URL?
    public var watermarkURL: URL?
    public var bgColor: String?
    public var blogId: Int?
    public var postId: Int?
    public var finished: Bool?

    public var token: String?

    enum CodingKeys: String, CodingKey {
        case id, title, description, width, height, duration, displayEmbed, allowDownload, rating, privacySetting, posterURL, originalURL, watermarkURL, bgColor, blogId, postId, finished, token
    }

    public init(dictionary metadataDict: NSDictionary, id: String) {
        self.id = id

        title = metadataDict.string(forKey: "title")
        videoDescription = metadataDict.string(forKey: "description")
        width = metadataDict.number(forKey: "width")?.intValue
        height = metadataDict.number(forKey: "height")?.intValue
        duration = metadataDict.number(forKey: "duration")?.intValue
        displayEmbed = metadataDict.object(forKey: "display_embed") as? Bool
        allowDownload = metadataDict.object(forKey: "allow_download") as? Bool
        rating = metadataDict.string(forKey: "rating")
        if let privacySettingValue = metadataDict.number(forKey: "privacy_setting")?.intValue, let privacySettingEnum = VideoPressPrivacySetting.init(rawValue: privacySettingValue) {
            privacySetting = privacySettingEnum
        }
        if let poster = metadataDict.string(forKey: "poster") {
            posterURL = URL(string: poster)
        }
        if let original = metadataDict.string(forKey: "original") {
            originalURL = URL(string: original)
        }
        if let watermark = metadataDict.string(forKey: "watermark") {
            watermarkURL = URL(string: watermark)
        }
        bgColor = metadataDict.string(forKey: "bg_color")
        blogId = metadataDict.number(forKey: "blog_id")?.intValue
        postId = metadataDict.number(forKey: "post_id")?.intValue
        finished = metadataDict.object(forKey: "finished") as? Bool
    }

    /// Returns the specified URL adding the token as a query parameter, which is required to play private videos.
    /// - Parameters:
    ///   - url: URL to include the token.
    ///
    /// - Returns: The specified URL with the token as a query parameter.
    @objc(getURLWithToken:)
    public func getURLWithToken(url: URL?) -> URL? {
        guard var urlWithToken = url else {
            return nil
        }
        if let token = self.token, var urlComponents = URLComponents(url: urlWithToken, resolvingAgainstBaseURL: true) {
            let metadataTokenParam = URLQueryItem(name: "metadata_token", value: token)
            var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
            queryItems.append(metadataTokenParam)
            urlComponents.queryItems = queryItems
            urlWithToken = urlComponents.url!
        }
        return urlWithToken
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(videoDescription, forKey: .description)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(duration, forKey: .duration)
        try container.encode(displayEmbed, forKey: .displayEmbed)
        try container.encode(allowDownload, forKey: .allowDownload)
        try container.encode(rating, forKey: .rating)
        try container.encode(privacySetting, forKey: .privacySetting)
        try container.encode(posterURL, forKey: .posterURL)
        try container.encode(originalURL, forKey: .originalURL)
        try container.encode(watermarkURL, forKey: .watermarkURL)
        try container.encode(bgColor, forKey: .bgColor)
        try container.encode(blogId, forKey: .blogId)
        try container.encode(postId, forKey: .postId)
        try container.encode(finished, forKey: .finished)
        try container.encode(token, forKey: .token)
    }

    public func asDictionary() -> [String: Any] {
        guard
            let data = try? JSONEncoder().encode(self),
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        else {
            assertionFailure("Encoding of RemoteVideoPressVideo failed")
            return [String: Any]()
        }
        return dictionary
    }
}
