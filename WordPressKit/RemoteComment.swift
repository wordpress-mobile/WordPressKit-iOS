import Foundation

@objcMembers public class RemoteComment: NSObject {

    public var commentID: NSNumber?
    public var authorID: NSNumber?
    public var author: String?
    public var authorEmail: String?
    public var authorUrl: String?
    public var authorAvatarURL: String?
    public var authorIP: String?
    public var content: String?
    public var rawContent: String?
    public var date: Date?
    public var link: String?
    public var parentID: NSNumber?
    public var postID: NSNumber?
    public var postTitle: String?
    public var status: String?
    public var type: String?
    public var isLiked: Bool = false
    public var likeCount: NSNumber?
    public var canModerate: Bool = false

}
