import Foundation

// MARK: - FormattableContent Implementation
//
open class FormattableContent: Equatable {
    /// Parsed Media Entities.
    ///
    public let media: [FormattableMediaContent]

    /// Parsed Range Entities.
    ///
    let ranges: [FormattableContentRange]

    /// Block Associated Text.
    ///
    public let text: String?

    /// Text Override: Local (Ephimeral) Edition.
    ///
    public var textOverride: String? {
        didSet {
            parent?.didChangeOverrides()
        }
    }

    let actions: [FormattableContentAction]?
//    /// Available Actions collection.
//    ///
//    fileprivate let actions: [String: AnyObject]?
//
//    /// Action Override Values
//    ///
//    fileprivate var actionsOverride = [Action: Bool]() {
//        didSet {
//            parent?.didChangeOverrides()
//        }
//    }

    /// Helper used by the +Interface Extension.
    ///
    fileprivate var dynamicAttributesCache = [String: AnyObject]()

    /// Meta Fields collection.
    ///
    fileprivate let meta: [String: AnyObject]?

    /// Associated Notification
    ///
    fileprivate weak var parent: FormattableContentParent?

    /// Raw Type, expressed as a string.
    ///
    fileprivate let type: String?


    /// Designated Initializer.
    ///
    init(dictionary: [String: AnyObject], actions commandActions: [FormattableContentAction], parent note: FormattableContentParent) {
        let rawMedia    = dictionary[Constants.BlockKeys.Media] as? [[String: AnyObject]]
        let rawRanges   = dictionary[Constants.BlockKeys.Ranges] as? [[String: AnyObject]]

        actions = commandActions
        media   = FormattableMediaContent.mediaFromArray(rawMedia)
        meta    = dictionary[Constants.BlockKeys.Meta] as? [String: AnyObject]
        ranges  = FormattableContentRange.rangesFromArray(rawRanges)
        parent  = note
        type    = dictionary[Constants.BlockKeys.RawType] as? String
        text    = dictionary[Constants.BlockKeys.Text] as? String
    }

    /// AVOID USING This Initializer at all costs.
    ///
    /// The Notifications stack was designed to render the Model entities, retrieved via the Backend's API, for several reasons.
    /// Most important one is: iOS, Android, WordPress.com and the WordPress Desktop App need to look consistent, all over.
    ///
    /// If you're tampering with the Backend Response, just to get a new UI component onscreen, means that you'll break consistency.
    /// Please consider patching the backend first, so that the actual response contains (whatever) you need it to contain!.
    ///
    /// Alternatively, depending on what you need to get done, you may also consider modifying the way the current blocks look like.
    ///
    public init(text: String?, ranges: [FormattableContentRange] = [], media: [FormattableMediaContent] = []) {
        self.text = text
        self.ranges = ranges
        self.media =  media
        self.actions = nil
        self.meta = nil
        self.type = nil
    }
}

// MARK: - FormattableContent Computed Properties
//
extension FormattableContent {
    /// Returns the current Block's Kind. SORRY: Duck Typing code below.
    ///
    public var kind: Kind {
        if let rawType = type, rawType.isEqual(Constants.BlockKeys.UserType) {
            return .user
        }

        if let commentID = metaCommentID, let parentCommentID = parent?.metaCommentID, let _ = metaSiteID, commentID.isEqual(parentCommentID) {
            return .comment
        }

        if let firstMedia = media.first, (firstMedia.kind == .Image || firstMedia.kind == .Badge) {
            return .image
        }

        return .text
    }

    /// Returns all of the Image URL's referenced by the FormattableMediaContent instances.
    ///
    public var imageUrls: [URL] {
        return media.compactMap {
            guard $0.kind == .Image && $0.mediaURL != nil else {
                return nil
            }

            return $0.mediaURL as URL?
        }
    }

    /// Comment ID, if any.
    ///
    public var metaCommentID: NSNumber? {
        return metaIds?[Constants.MetaKeys.Comment] as? NSNumber
    }

    /// Home Site's Link, if any.
    ///
    public var metaLinksHome: URL? {
        guard let rawLink = metaLinks?[Constants.MetaKeys.Home] as? String else {
            return nil
        }

        return URL(string: rawLink)
    }

    /// Site ID, if any.
    ///
    public var metaSiteID: NSNumber? {
        return metaIds?[Constants.MetaKeys.Site] as? NSNumber
    }

    /// Home Site's Title, if any.
    ///
    public var metaTitlesHome: String? {
        return metaTitles?[Constants.MetaKeys.Home] as? String
    }

    /// Parent Notification ID
    ///
    public var parentID: String? {
        return parent?.uniqueID
    }

    /// Returns the Meta ID's collection, if any.
    ///
    fileprivate var metaIds: [String: AnyObject]? {
        return meta?[Constants.MetaKeys.Ids] as? [String: AnyObject]
    }

    /// Returns the Meta Links collection, if any.
    ///
    fileprivate var metaLinks: [String: AnyObject]? {
        return meta?[Constants.MetaKeys.Links] as? [String: AnyObject]
    }

    /// Returns the Meta Titles collection, if any.
    ///
    fileprivate var metaTitles: [String: AnyObject]? {
        return meta?[Constants.MetaKeys.Titles] as? [String: AnyObject]
    }
}

// MARK: - FormattableContent Methods
//
extension FormattableContent {
    /// Gets a command by identifier
    ///
    public func action(id: Identifier) -> FormattableContentAction? {
        return actions?.filter {
            $0.identifier == id
            }.first
    }

    /// Indicated if a command is active
    ///
    public func isActionOn(id: Identifier) -> Bool {
        return action(id: id)?.on ?? false
    }

    /// Indicates if a command is enabled
    ///
    public func isActionEnabled(id: Identifier) -> Bool {
        return action(id: id)?.enabled ?? false
    }

    // Dynamic Attribute Cache: Used internally by the Interface Extension, as an optimization.
    ///
    func cacheValueForKey(_ key: String) -> AnyObject? {
        return dynamicAttributesCache[key]
    }

    /// Stores a specified value within the Dynamic Attributes Cache.
    ///
    func setCacheValue(_ value: AnyObject?, forKey key: String) {
        guard let value = value else {
            dynamicAttributesCache.removeValue(forKey: key)
            return
        }

        dynamicAttributesCache[key] = value
    }

    /// Finds the first FormattableContentRange instance that maps to a given URL.
    ///
    func formattableContentRangeWithUrl(_ url: URL) -> FormattableContentRange? {
        for range in ranges {
            if let rangeURL = range.url, (rangeURL as URL == url) {
                return range
            }
        }

        return nil
    }

    /// Finds the first FormattableContentRange instance that maps to a given CommentID.
    ///
    public func formattableContentRangeWithCommentId(_ commentID: NSNumber) -> FormattableContentRange? {
        for range in ranges {
            if let rangeCommentID = range.commentID, rangeCommentID.isEqual(commentID) {
                return range
            }
        }

        return nil
    }
}


// MARK: - FormattableContent Parsers
//
extension FormattableContent {

    /// Parses a collection of Block Definitions into FormattableContent instances.
    ///
    public class func blocksFromArray(_ blocks: [[String: AnyObject]],  actionsParser parser: FormattableContentActionParser , parent: FormattableContentParent) -> [FormattableContent] {
        return blocks.compactMap {
            let actions = parser.parse($0[Constants.BlockKeys.Actions] as? [String: AnyObject])
            return FormattableContent(dictionary: $0, actions: actions, parent: parent)
        }
    }

    public func buildRangesToImagesMap(_ mediaMap: [URL: UIImage]) -> [NSValue: UIImage]? {
        guard textOverride == nil else {
            return nil
        }

        var ranges = [NSValue: UIImage]()

        for theMedia in media {
            guard let mediaURL = theMedia.mediaURL else {
                continue
            }

            if let image = mediaMap[mediaURL as URL] {
                let rangeValue      = NSValue(range: theMedia.range)
                ranges[rangeValue]  = image
            }
        }

        return ranges
    }
}

// MARK: - FormattableContent Types
//
public extension FormattableContent {
    /// Known kinds of Blocks
    ///
    public enum Kind {
        case text
        case image      // Includes Badges and Images
        case user
        case comment
    }

    /// Known kinds of Actions
    ///
    public enum Action: String {
        case Approve            = "approve-comment"
        case Follow             = "follow"
        case Like               = "like-comment"
        case Reply              = "replyto-comment"
        case Spam               = "spam-comment"
        case Trash              = "trash-comment"
    }
}

private enum Constants {
    /// Parsing Keys
    ///
    fileprivate enum BlockKeys {
        static let Actions      = "actions"
        static let Media        = "media"
        static let Meta         = "meta"
        static let Ranges       = "ranges"
        static let RawType      = "type"
        static let Text         = "text"
        static let UserType     = "user"
    }

    /// Meta Parsing Keys
    ///
    fileprivate enum MetaKeys {
        static let Ids          = "ids"
        static let Links        = "links"
        static let Titles       = "titles"
        static let Site         = "site"
        static let Post         = "post"
        static let Comment      = "comment"
        static let Reply        = "reply_comment"
        static let Home         = "home"
    }
}

//// MARK: - FormattableContent Equatable Implementation

extension FormattableContent {
    public static func == (lhs: FormattableContent, rhs: FormattableContent) -> Bool {
        if lhs.parent == nil && rhs.parent == nil {
            return lhs.isEqual(to: rhs)
        }
        guard let lhsParent = lhs.parent, let rhsParent = rhs.parent else {
            return false
        }
        return lhs.isEqual(to: rhs) && lhsParent.isEqual(to: rhsParent)
    }

    private func isEqual(to other: FormattableContent) -> Bool {
        return kind == other.kind &&
            text == other.text &&
            ranges.count == other.ranges.count &&
            media.count == other.media.count
    }
}
