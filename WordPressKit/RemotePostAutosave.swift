import Foundation

/// Encapsulates the autosave attributes of a post.
@objcMembers class RemotePostAutosave: NSObject {
    var title: String?
    var excerpt: String?
    var content: String?
    var modifiedDate: Date?
    var identifier: NSNumber?
    var authorID: String?
    var postID: NSNumber?
    var previewURL: String?
}
