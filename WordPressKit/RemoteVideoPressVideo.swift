import Foundation

/// This enum matches the privacy setting constants defined in Jetpack:
/// https://github.com/Automattic/jetpack/blob/a2ccfb7978184e306211292a66ed49dcf38a517f/projects/packages/videopress/src/utility-functions.php#L13-L17
@objc public enum VideoPressPrivacySetting: Int {
    case isPublic = 0
    case isPrivate = 1
    case siteDefault = 2
}

@objcMembers public class RemoteVideoPressVideo: NSObject {

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
    public var width: NSNumber?
    public var height: NSNumber?
    public var duration: NSNumber?
    public var displayEmbed: Bool?
    public var allowDownload: Bool?
    public var rating: String?
    public var privacySetting: VideoPressPrivacySetting = .siteDefault
    public var posterURL: URL?
    public var originalURL: URL?
    public var watermarkURL: URL?
    public var bgColor: String?
    public var blogId: NSNumber?
    public var postId: NSNumber?
    public var finished: Bool?

    public var token: String?

    public init(dictionary metadataDict: NSDictionary, id: String) {
        self.id = id

        title = metadataDict.string(forKey: "title")
        videoDescription = metadataDict.string(forKey: "descrption")
        width = metadataDict.number(forKey: "width")
        height = metadataDict.number(forKey: "height")
        duration = metadataDict.number(forKey: "duration")
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
        blogId = metadataDict.number(forKey: "blog_id")
        postId = metadataDict.number(forKey: "post_id")
        finished = metadataDict.object(forKey: "finished") as? Bool
    }

    /// Returns the URL that should be used to play the video.
    ///
    /// The URL used is the original but adding the token as a query parameter, which is required to play private videos.
    public func getPlayURL() -> URL? {
        guard var videoPlayURL = self.originalURL else {
            return nil
        }
        if let token = self.token, var urlComponents = URLComponents(url: videoPlayURL, resolvingAgainstBaseURL: true) {
            let metadataTokenParam = URLQueryItem(name: "metadata_token", value: token)
            var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
            queryItems.append(metadataTokenParam)
            urlComponents.queryItems = queryItems
            videoPlayURL = urlComponents.url!
        }
        return videoPlayURL
    }

    public func toDict() -> [String: Any] {
        return [
            "id": self.id,
            "title": self.title ?? "",
            "description": self.videoDescription ?? "",
            "width": self.width ?? 0,
            "height": self.height ?? 0,
            "duration": self.duration ?? 0,
            "displayEmbed": self.displayEmbed!,
            "allowDownload": self.allowDownload!,
            "rating": self.rating ?? "",
            "privacySetting": self.privacySetting,
            "posterURL": self.posterURL?.absoluteString ?? "",
            "originalURL": self.originalURL?.absoluteString ?? "",
            "watermarkURL": self.watermarkURL?.absoluteString ?? "",
            "bgColor": self.bgColor ?? "",
            "blogId": self.blogId ?? -1,
            "postId": self.postId ?? -1,
            "finished": self.finished!,
            "token": self.token ?? "",
            "playURL": self.getPlayURL()?.absoluteString ?? self.originalURL?.absoluteString ?? ""
        ]
    }
}
