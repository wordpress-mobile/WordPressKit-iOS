
import Foundation

open class FormattableTextContent: FormattableContent {
    public let text: String?
    public let ranges: [FormattableContentRange]

    public var parent: FormattableContentParent?
    public var actions: [FormattableContentAction]?

    open var type: String? {
        return "text"
    }

    public var meta: [String : AnyObject]?

    public required init(dictionary: [String : AnyObject], actions commandActions: [FormattableContentAction], parent note: FormattableContentParent) {
        let rawRanges   = dictionary[Constants.BlockKeys.Ranges] as? [[String: AnyObject]]

        actions = commandActions
        ranges  = FormattableContentRange.rangesFromArray(rawRanges)
        parent  = note
        text    = dictionary[Constants.BlockKeys.Text] as? String
        meta    = dictionary[Constants.BlockKeys.Meta] as? [String: AnyObject]
    }

    public init(text: String, ranges: [FormattableContentRange]) {
        self.text = text
        self.ranges = ranges
    }
}

private enum Constants {
    /// Parsing Keys
    ///
    fileprivate enum BlockKeys {
        static let Meta         = "meta"
        static let Ranges       = "ranges"
        static let Text         = "text"
    }
}
