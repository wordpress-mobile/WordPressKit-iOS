import Foundation

/// Encapsulates the autosave attributes of a post.
@objc
@objcMembers
open class RemotePostAutosave: NSObject {
    open var title: String?
    open var excerpt: String?
    open var content: String?
    open var modifiedDate: Date?
    open var identifier: NSNumber?
    open var authorID: String?
    open var postID: NSNumber?
    open var previewURL: String?
}
