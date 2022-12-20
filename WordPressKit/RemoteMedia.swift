import Foundation

@objcMembers public class RemoteMedia: NSObject {

    public var mediaID: NSNumber?
    public var url: URL?
    public var localURL: URL?
    public var largeURL: URL?
    public var mediumURL: URL?
    public var guid: URL?
    public var date: Date?
    public var postID: NSNumber?
    public var file: String?
    public var mimeType: String?
    public var `extension`: String?
    public var title: String?
    public var caption: String?
    public var descriptionText: String?
    public var alt: String?
    public var height: NSNumber?
    public var width: NSNumber?
    public var shortcode: String?
    public var exif: [String: Any]?
    public var videopressGUID: String?
    public var length: NSNumber?
    public var remoteThumbnailURL: String?

}
