import Foundation
import ObjectiveC

@objcMembers public class RemotePost: NSObject {

    public static let statusDraft = "draft"
    public static let statusPending = "pending"
    public static let statusPrivate = "private"
    public static let statusPublish = "publish"
    public static let statusScheduled = "future"
    public static let statusTrash = "trash"
    public static let statusDeleted = "deleted" // Returned by wpcom REST API when a post is permanently deleted.

    public var postID: NSNumber?
    public var siteID: NSNumber?
    public var authorAvatarURL: String?
    public var authorDisplayName: String?
    public var authorEmail: String?
    public var authorURL: String?
    public var authorID: NSNumber?
    public var date: NSDate?
    public var dateModified: NSDate?
    public var title: String?
    public var URL: NSURL?
    public var shortURL: NSURL?
    public var content: String?
    public var excerpt: String?
    public var slug: String?
    public var suggestedSlug: String?
    public var status: String?
    public var password: String?
    public var parentID: NSNumber?
    public var postThumbnailID: NSNumber?
    public var postThumbnailPath: String?
    public var type: String?
    public var format: String?

    /**
     * A snapshot of the post at the last autosave.
     *
     * This is nullable.
     */
    public var autosave: RemotePostAutosave?

    public var commentCount: NSNumber?
    public var likeCount: NSNumber?

    public var categories: NSArray?
    public var revisions: NSArray?
    public var tags: NSArray?
    public var pathForDisplayImage: String?
    public var isStickyPost: NSNumber?
    public var isFeaturedImageChanged: Bool = false

    /**
     Array of custom fields. Each value is a dictionary containing {ID, key, value}
     */
    public var metadata: [[String: Any]]?

    // Featured images?
    // Geolocation?
    // Attachments?
    // Metadata?

    public override init() {
        super.init()
    }

    public init(siteID: NSNumber, status: String, title: String?, content: String?) {
        super.init()
        self.siteID = siteID
        self.status = status
        self.title = title
        self.content = content
    }

    public override var debugDescription: String {
        "\(super.description) (\(allProperties))"
    }

}
