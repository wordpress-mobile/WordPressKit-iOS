import Foundation

enum ParentKind: String {
    case Comment        = "comment"
    case CommentLike    = "comment_like"
    case Follow         = "follow"
    case Like           = "like"
    case Matcher        = "automattcher"
    case NewPost        = "new_post"
    case Post           = "post"
    case User           = "user"
    case Unknown        = "unknown"

    var toTypeValue: String {
        return rawValue
    }
}

protocol FormattableContentParent: AnyObject {
    var metaCommentID: NSNumber? { get }
    var objectID: String? { get }
    var kind: ParentKind { get }
    var metaReplyID: NSNumber? { get }
    var isPingback: Bool { get }
    func didChangeOverrides()
    func isEqual(to other: FormattableContentParent) -> Bool
}


// MARK: - FormattableContent Implementation
//
class FormattableContent: Equatable {
    /// Parsed Media Entities.
    ///
    let media: [FormattableMediaContent]

    /// Parsed Range Entities.
    ///
    let ranges: [FormattableContentRange]

    /// Block Associated Text.
    ///
    let text: String?

    /// Text Override: Local (Ephimeral) Edition.
    ///
    var textOverride: String? {
        didSet {
            parent?.didChangeOverrides()
        }
    }

    /// Available Actions collection.
    ///
    fileprivate let actions: [String: AnyObject]?

    /// Action Override Values
    ///
    fileprivate var actionsOverride = [Action: Bool]() {
        didSet {
            parent?.didChangeOverrides()
        }
    }

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
    init(dictionary: [String: AnyObject], parent note: FormattableContentParent) {
        let rawMedia    = dictionary[Constants.BlockKeys.Media] as? [[String: AnyObject]]
        let rawRanges   = dictionary[Constants.BlockKeys.Ranges] as? [[String: AnyObject]]

        actions = dictionary[Constants.BlockKeys.Actions] as? [String: AnyObject]
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
    init(text: String?, ranges: [FormattableContentRange] = [], media: [FormattableMediaContent] = []) {
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
    var kind: Kind {
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
    var imageUrls: [URL] {
        return media.compactMap {
            guard $0.kind == .Image && $0.mediaURL != nil else {
                return nil
            }

            return $0.mediaURL as URL?
        }
    }

    /// Returns YES if the associated comment (if any) is approved. NO otherwise.
    ///
    var isCommentApproved: Bool {
        return isActionOn(.Approve) || !isActionEnabled(.Approve)
    }

    /// Comment ID, if any.
    ///
    var metaCommentID: NSNumber? {
        return metaIds?[Constants.MetaKeys.Comment] as? NSNumber
    }

    /// Home Site's Link, if any.
    ///
    var metaLinksHome: URL? {
        guard let rawLink = metaLinks?[Constants.MetaKeys.Home] as? String else {
            return nil
        }

        return URL(string: rawLink)
    }

    /// Site ID, if any.
    ///
    var metaSiteID: NSNumber? {
        return metaIds?[Constants.MetaKeys.Site] as? NSNumber
    }

    /// Home Site's Title, if any.
    ///
    var metaTitlesHome: String? {
        return metaTitles?[Constants.MetaKeys.Home] as? String
    }

    /// Parent Notification ID
    ///
    var parentID: String? {
        return parent?.objectID
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
    /// Allows us to set a local override for a remote value. This is used to fake the UI, while
    /// there's a BG call going on.
    ///
    func setOverrideValue(_ value: Bool, forAction action: Action) {
        actionsOverride[action] = value
    }

    /// Removes any local (temporary) value that might have been set by means of *setActionOverrideValue*.
    ///
    func removeOverrideValueForAction(_ action: Action) {
        actionsOverride.removeValue(forKey: action)
    }

    /// Returns the Notification Block status for a given action. Will return any *Override* that might be set, if any.
    ///
    fileprivate func valueForAction(_ action: Action) -> Bool? {
        if let overrideValue = actionsOverride[action] {
            return overrideValue
        }

        let value = actions?[action.rawValue] as? NSNumber
        return value?.boolValue
    }

    /// Returns *true* if a given action is available.
    ///
    func isActionEnabled(_ action: Action) -> Bool {
        return valueForAction(action) != nil
    }

    /// Returns *true* if a given action is toggled on. (I.e.: Approval = On >> the comment is currently approved).
    ///
    func isActionOn(_ action: Action) -> Bool {
        return valueForAction(action) ?? false
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
    func formattableContentRangeWithCommentId(_ commentID: NSNumber) -> FormattableContentRange? {
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
    class func blocksFromArray(_ blocks: [[String: AnyObject]], parent: FormattableContentParent) -> [FormattableContent] {
        return blocks.compactMap {
            return FormattableContent(dictionary: $0, parent: parent)
        }
    }
}


// MARK: - FormattableContent Types
//
extension FormattableContent {
    /// Known kinds of Blocks
    ///
    enum Kind {
        case text
        case image      // Includes Badges and Images
        case user
        case comment
    }

    /// Known kinds of Actions
    ///
    enum Action: String {
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
    static func == (lhs: FormattableContent, rhs: FormattableContent) -> Bool {
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
