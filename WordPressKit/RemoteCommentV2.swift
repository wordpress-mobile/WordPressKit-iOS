/// Captures the JSON structure for Comments returned from API v2 endpoint.
@objc public class RemoteCommentV2: NSObject {
    public var commentID: Int = 0
    public var postID: Int = 0
    public var parentID: Int = 0
    public var authorID: Int = 0
    public var authorEmail: String? // only available on edit context.
    public var authorName: String?
    public var authorURL: String?
    public var authorIP: String? // only available on edit context.
    public var authorUserAgent: String? // only available on edit context.
    public var authorAvatarURL: String?
    public var date: NSDate?
    public var content: String?
    public var rawContent: String?
    public var link: String?
    public var status: String?
    public var type: String?
}
