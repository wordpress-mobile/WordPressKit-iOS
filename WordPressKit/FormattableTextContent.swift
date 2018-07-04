
import Foundation

public extension FormattableContentKind {
    public static let text = FormattableContentKind("text")
}

open class FormattableTextContent: FormattableContent {
    open var kind: FormattableContentKind {
        return .text
    }

    open var text: String? {
        return internalText
    }

    public let ranges: [FormattableContentRange]
    public var parent: FormattableContentParent?
    public var actions: [FormattableContentAction]?
    public var meta: [String : AnyObject]?

    private let internalText: String?

    public required init(dictionary: [String : AnyObject], actions commandActions: [FormattableContentAction], parent note: FormattableContentParent) {
        let rawRanges   = dictionary[Constants.BlockKeys.Ranges] as? [[String: AnyObject]]

        actions = commandActions
        ranges = FormattableContentRange.rangesFromArray(rawRanges)
        parent = note
        internalText = dictionary[Constants.BlockKeys.Text] as? String
        meta = dictionary[Constants.BlockKeys.Meta] as? [String: AnyObject]
    }

    public init(text: String, ranges: [FormattableContentRange]) {
        self.internalText = text
        self.ranges = ranges
    }
}

private enum Constants {
    fileprivate enum BlockKeys {
        static let Meta         = "meta"
        static let Ranges       = "ranges"
        static let Text         = "text"
    }
}
