
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
        ranges = FormattableTextContent.rangesFrom(rawRanges)
        parent = note
        internalText = dictionary[Constants.BlockKeys.Text] as? String
        meta = dictionary[Constants.BlockKeys.Meta] as? [String: AnyObject]
    }

    public init(text: String, ranges: [FormattableContentRange]) {
        self.internalText = text
        self.ranges = ranges
    }

    private static func rangesFrom(_ rawRanges: [[String: AnyObject]]?) -> [FormattableContentRange] {
        let parsed = rawRanges?.compactMap { rawRange -> FormattableContentRange? in

            guard let indices = rawRange[RangeKeys.indices] as? [Int],
                let start = indices.first,
                let end = indices.last else {
                    return nil
            }
            let range = NSMakeRange(start, end - start)
            return self.rangeFrom(rawRange, range: range)
        }

        return parsed ?? []
    }

    private static func rangeFrom(_ rawRange: [String: AnyObject], range: NSRange) -> FormattableContentRange? {
        if let type = rawRange[RangeKeys.rawType] as? String {
            let kind = FormattableContentRange.Kind(type)
            switch kind {
            case .user:
                guard let userID = rawRange[RangeKeys.id] as? NSNumber else {
                    fatalError()
                }
                return FormattableUserRange(userID: userID, range: range)
            case .post:
                guard let postID = rawRange[RangeKeys.postId] as? NSNumber else {
                    fatalError()
                }
                return FormattablePostRange(postID: postID, range: range)
            case .comment:
                guard let postID = rawRange[RangeKeys.postId] as? NSNumber, let commentID = rawRange[RangeKeys.id] as? NSNumber else {
                    fatalError()
                }
                return FormattableCommentRange(commentID: commentID, postID: postID, range: range)
            case .noticon:
                guard let value = rawRange[RangeKeys.value] as? String else {
                    fatalError()
                }
                return FormattableNoticonRange(value: value, range: range)
            case .site:
                guard let siteID = rawRange[RangeKeys.siteId] as? NSNumber else {
                    fatalError()
                }
                return FormattableSiteRange(siteID: siteID, range: range)
            case .link:
                guard let urlString = rawRange[RangeKeys.url] as? String, let url = URL(string: urlString) else {
                    fatalError()
                }
                return FormattableLinkRange(url: url, range: range)
            case .blockquote, .stats, .follow, .match:
                return FormattableContentRange(kind: kind, range: range)
            default: break
            }
        }
        // No type comming from payload
        if let siteID = rawRange[RangeKeys.siteId] as? NSNumber {
            return FormattableSiteRange(siteID: siteID, range: range)
        } else if let urlString = rawRange[RangeKeys.url] as? String, let url = URL(string: urlString) {
            return FormattableLinkRange(url: url, range: range)
        }

        return nil
    }
}

fileprivate enum RangeKeys {
    static let rawType = "type"
    static let url = "url"
    static let indices = "indices"
    static let id = "id"
    static let value = "value"
    static let siteId = "site_id"
    static let postId = "post_id"
}

public extension FormattableMediaItem {
    fileprivate enum MediaKeys {
        static let RawType      = "type"
        static let URL          = "url"
        static let Indices      = "indices"
        static let Width        = "width"
        static let Height       = "height"
    }
}

private enum Constants {
    fileprivate enum BlockKeys {
        static let Meta         = "meta"
        static let Ranges       = "ranges"
        static let Text         = "text"
    }
}
