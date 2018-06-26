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

protocol FormattableContentParent: AnyObject, Equatable {
    var metaCommentID: NSNumber? { get }
    var objectID: String? { get }
    var kind: ParentKind { get }
    var metaReplyID: NSNumber? { get }
    var isPingback: Bool { get }
    func didChangeOverrides()
}


// MARK: - FormattableContent Implementation
//
class FormattableContent<ParentType: FormattableContentParent>: Equatable {
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
    fileprivate weak var parent: ParentType?

    /// Raw Type, expressed as a string.
    ///
    fileprivate let type: String?


    /// Designated Initializer.
    ///
    init(dictionary: [String: AnyObject], parent note: ParentType) {
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
    class func blocksFromArray(_ blocks: [[String: AnyObject]], parent: ParentType) -> [FormattableContent] {
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
    static func == (lhs: FormattableContent<ParentType>, rhs: FormattableContent<ParentType>) -> Bool {
        return lhs.kind == rhs.kind &&
            lhs.text == rhs.text &&
            lhs.parent == rhs.parent &&
            lhs.ranges.count == rhs.ranges.count &&
            lhs.media.count == rhs.media.count
    }
}

private enum FormatConstants {
    static let headerFontSize            = CGFloat(12)
    static let headerLineSize            = CGFloat(16)
    static let subjectFontSize           = CGFloat(14)
    static let subjectNoticonSize        = CGFloat(14)
    static let subjectLineSize           = CGFloat(18)
    static let snippetLineSize           = subjectLineSize
    static let blockFontSize             = CGFloat(14)
    static let blockLineSize             = CGFloat(20)
    static let contentBlockLineSize      = CGFloat(21)
    static let maximumCellWidth          = CGFloat(600)

    static let sectionHeaderParagraph: NSMutableParagraphStyle = NSMutableParagraphStyle(
        minLineHeight: headerLineSize, lineBreakMode: .byWordWrapping, alignment: .natural
    )
    fileprivate static let subjectParagraph: NSMutableParagraphStyle = NSMutableParagraphStyle(
        minLineHeight: subjectLineSize, lineBreakMode: .byWordWrapping, alignment: .natural
    )
    fileprivate static let snippetParagraph: NSMutableParagraphStyle = NSMutableParagraphStyle(
        minLineHeight: snippetLineSize, lineBreakMode: .byWordWrapping, alignment: .natural
    )
    fileprivate static let blockParagraph: NSMutableParagraphStyle = NSMutableParagraphStyle(
        minLineHeight: blockLineSize, lineBreakMode: .byWordWrapping, alignment: .natural
    )
    fileprivate static let contentBlockParagraph: NSMutableParagraphStyle = NSMutableParagraphStyle(
        minLineHeight: contentBlockLineSize, lineBreakMode: .byWordWrapping, alignment: .natural
    )
    fileprivate static let badgeParagraph: NSMutableParagraphStyle = NSMutableParagraphStyle(
        minLineHeight: blockLineSize, maxLineHeight: blockLineSize, lineBreakMode: .byWordWrapping, alignment: .center
    )


    // Fonts
    fileprivate static let sectionHeaderFont = UIFont.systemFont(ofSize: headerFontSize, weight: .semibold)
    fileprivate static var subjectRegularFont = UIFont.systemFont(ofSize: subjectFontSize)
    fileprivate static var subjectBoldFont = UIFont.systemFont(ofSize: subjectFontSize, weight: .bold)
    fileprivate static var subjectItalicsFont = UIFont.italicSystemFont(ofSize: subjectFontSize)

    fileprivate static let subjectNoticonFont       = UIFont(name: "Noticons", size: subjectNoticonSize)!

    fileprivate static let headerTitleRegularFont   = UIFont.systemFont(ofSize: blockFontSize)
    fileprivate static let headerTitleItalicsFont   = blockItalicsFont
    fileprivate static let blockItalicsFont         = UIFont.italicSystemFont(ofSize: blockFontSize)
    fileprivate static let blockNoticonFont         = subjectNoticonFont

    fileprivate static let sectionHeaderTextColor   = UIColor(red: 0xA7/255.0, green: 0xBB/255.0, blue: 0xCA/255.0, alpha: 0xFF/255.0)
    fileprivate static let subjectTextColor         = UIColor.blue
    fileprivate static let subjectNoticonColor      = UIColor.black
    fileprivate static let footerTextColor          = UIColor.red
    fileprivate static let blockNoticonColor        = UIColor.purple
    fileprivate static let snippetColor             = UIColor.green
    fileprivate static let headerTitleContextColor  = UIColor.orange
    fileprivate static let blockQuotedColor          = UIColor(red: 0x7E/255.0, green: 0x9E/255.0, blue: 0xB5/255.0, alpha: 0xFF/255.0)
}

extension FormattableContent {



    // Subject Text
    public var subjectRegularStyle: [NSAttributedStringKey: Any] {
        return  [.paragraphStyle: FormatConstants.subjectParagraph,
                 .font: FormatConstants.subjectRegularFont,
                 .foregroundColor: FormatConstants.subjectTextColor ]
    }

    public var subjectBoldStyle: [NSAttributedStringKey: Any] {
        return [.paragraphStyle: FormatConstants.subjectParagraph,
                .font: FormatConstants.subjectBoldFont ]
    }

    public var subjectItalicsStyle: [NSAttributedStringKey: Any] {
        return [.paragraphStyle: FormatConstants.subjectParagraph,
                .font: FormatConstants.subjectItalicsFont ]
    }

    public var subjectNoticonStyle: [NSAttributedStringKey: Any] {
        return [.paragraphStyle: FormatConstants.subjectParagraph,
                .font: FormatConstants.subjectNoticonFont,
                .foregroundColor: FormatConstants.subjectNoticonColor ]
    }

    public var blockQuotedStyle: [NSAttributedStringKey: Any] {
        return  [.paragraphStyle: FormatConstants.blockParagraph,
                 .font: FormatConstants.blockItalicsFont,
                 .foregroundColor: FormatConstants.blockQuotedColor ]
    }

    public var subjectQuotedStyle: [NSAttributedStringKey: Any] {
        return blockQuotedStyle
    }

    // Subject Snippet
    public var snippetRegularStyle: [NSAttributedStringKey: Any] {
        return [.paragraphStyle: FormatConstants.snippetParagraph,
                .font: FormatConstants.subjectRegularFont,
                .foregroundColor: FormatConstants.snippetColor ]
    }

    var subjectRangeStylesMap: [FormattableContentRange.Kind: [NSAttributedStringKey: Any]] {
        return [
            .User: subjectBoldStyle,
            .Post: subjectItalicsStyle,
            .Comment: subjectItalicsStyle,
            .Blockquote: subjectQuotedStyle,
            .Noticon: subjectNoticonStyle
        ]
    }

    func render() -> NSAttributedString {
        return textWithStyles(subjectRegularStyle, quoteStyles: snippetRegularStyle, rangeStylesMap: subjectRangeStylesMap, linksColor: FormatConstants.footerTextColor)
    }


    /// This method is an all-purpose helper to aid formatting the NotificationBlock's payload text.
    ///
    /// - Parameters:
    ///     - attributes: Represents the attributes to be applied, initially, to the Text.
    ///     - quoteStyles: The Styles to be applied to "any quoted text"
    ///     - rangeStylesMap: A Dictionary object mapping NotificationBlock types to a dictionary of styles
    ///                       to be applied.
    ///     - linksColor: The color that should be used on any links contained.
    ///
    /// - Returns: A NSAttributedString instance, formatted with all of the specified parameters
    ///
    fileprivate func textWithStyles(_ attributes: [NSAttributedStringKey: Any],
                                    quoteStyles: [NSAttributedStringKey: Any]?,
                                    rangeStylesMap: [FormattableContentRange.Kind: [NSAttributedStringKey: Any]]?,
                                    linksColor: UIColor?) -> NSAttributedString {
        guard let text = text else {
            return NSAttributedString()
        }

        let tightenedText = replaceCommonWhitespaceIssues(in: text)
        let theString = NSMutableAttributedString(string: tightenedText, attributes: attributes)

        if let quoteStyles = quoteStyles {
            theString.applyAttributes(toQuotes: quoteStyles)
        }

        // Apply the Ranges
        var lengthShift = 0

        for range in ranges {
            var shiftedRange        = range.range
            shiftedRange.location   += lengthShift

            if range.kind == .Noticon {
                let noticon         = (range.value ?? String()) + " "
                theString.replaceCharacters(in: shiftedRange, with: noticon)
                lengthShift         += noticon.count
                shiftedRange.length += noticon.count
            }

            if let rangeStyle = rangeStylesMap?[range.kind] {
                theString.addAttributes(rangeStyle, range: shiftedRange)
            }

            if let rangeURL = range.url, let linksColor = linksColor {
                theString.addAttribute(.link, value: rangeURL, range: shiftedRange)
                theString.addAttribute(.foregroundColor, value: linksColor, range: shiftedRange)
            }
        }

        return theString
    }

    /// Replaces some common extra whitespace with hairline spaces so that comments display better
    ///
    /// - Parameter baseString: string of the comment body before attributes are added
    /// - Returns: string of same length
    /// - Note: the length must be maintained or the formatting will break
    private func replaceCommonWhitespaceIssues(in baseString: String) -> String {
        var newString: String
        // \u{200A} = hairline space (very skinny space).
        // we use these so that the ranges are still in the right position, but the extra space basically disappears
        newString = baseString.replacingOccurrences(of: "\t ", with: "\u{200A}\u{200A}") // tabs before a space
        newString = newString.replacingOccurrences(of: " \t", with: " \u{200A}") // tabs after a space
        newString = newString.replacingOccurrences(of: "\t@", with: "\u{200A}@") // tabs before @mentions
        newString = newString.replacingOccurrences(of: "\t.", with: "\u{200A}.") // tabs before a space
        newString = newString.replacingOccurrences(of: "\t,", with: "\u{200A},") // tabs cefore a comman
        newString = newString.replacingOccurrences(of: "\n\t\n\t", with: "\u{200A}\u{200A}\n\t") // extra newline-with-tab before a newline-with-tab

        // if the length of the string changes the range-based formatting will break
        guard newString.count == baseString.count else {
            return baseString
        }

        return newString
    }
}

extension NSMutableParagraphStyle {
    @objc convenience init(minLineHeight: CGFloat, lineBreakMode: NSLineBreakMode, alignment: NSTextAlignment) {
        self.init()
        self.minimumLineHeight  = minLineHeight
        self.lineBreakMode      = lineBreakMode
        self.alignment          = alignment
    }

    @objc convenience init(minLineHeight: CGFloat, maxLineHeight: CGFloat, lineBreakMode: NSLineBreakMode, alignment: NSTextAlignment) {
        self.init(minLineHeight: minLineHeight, lineBreakMode: lineBreakMode, alignment: alignment)
        self.maximumLineHeight  = maxLineHeight
    }
}


extension NSMutableAttributedString {
    func applyAttributes(toQuotes attributes: [NSAttributedStringKey: Any]?) {
        guard let attributes = attributes else {
            return
        }
        let rawString = self.string
        let scanner = Scanner(string: rawString)
        let quotes = scanner.scanQuotesText()
        quotes.forEach {
            if let itemRange = rawString.range(of: $0) {
                let range = NSRange(itemRange, in: rawString)
                self.addAttributes(attributes, range: range)
            }

        }
    }
}

extension Scanner {
    func scanQuotesText() -> [String] {
        var scanned = [String]()
        var quote: NSString?
        let quoteString = "\""
        while self.isAtEnd == false {
            scanUpTo(quoteString, into: nil)
            scanString(quoteString, into: nil)
            scanUpTo(quoteString, into: &quote)
            scanUpTo(quoteString, into: nil)

            if let quoteString = quote, quoteString.isEmpty() == false {
                scanned.append(quoteString as String)
            }
        }

        return scanned
    }
}
