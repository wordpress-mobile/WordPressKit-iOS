
import Foundation

open class FormattableTextContent: FormattableContent {
    public let text: String?
    public let ranges: [FormattableContentRange]

    public var parent: FormattableContentParent?
    public var actions: [FormattableContentAction]?

    public var meta: [String : AnyObject]?

    public required init(dictionary: [String : AnyObject], actions commandActions: [FormattableContentAction], parent note: FormattableContentParent) {
        let rawRanges   = dictionary[Constants.BlockKeys.Ranges] as? [[String: AnyObject]]

        actions = commandActions
        ranges  = FormattableContentRange.rangesFromArray(rawRanges)
        parent  = note
        text    = dictionary[Constants.BlockKeys.Text] as? String
        meta    = dictionary[Constants.BlockKeys.Meta] as? [String: AnyObject]
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
