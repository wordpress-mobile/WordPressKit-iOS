import Foundation

// MARK: - DefaultFormattableContentRange Entity
//
public class FormattableContentRange {
    public let kind: Kind
    public let range: NSRange

    public func apply(_ styles: FormattableContentStyles, to string: NSMutableAttributedString, withShift shift: Int) {
        var shiftedRange        = range
        shiftedRange.location   += shift

        if let rangeStyle = styles.rangeStylesMap?[kind] {
            string.addAttributes(rangeStyle, range: shiftedRange)
        }
    }

    var shift: Int {
        return 0
    }

    init(kind: Kind, range: NSRange) {
        self.range = range
        self.kind = kind
    }
}

extension FormattableContentRange {
    public struct Kind: Equatable, Hashable {
        let rawType: String

        public init(_ rawType: String) {
            self.rawType = rawType
        }
    }
}

class FormattableUserRange: FormattableContentRange {
    public let userID: NSNumber

    init(userID: NSNumber, range: NSRange) {
        self.userID = userID
        super.init(kind: FormattableContentRange.Kind.user, range: range)
    }
}

public class FormattablePostRange: FormattableContentRange {
    public let postID: NSNumber

    init(postID: NSNumber, range: NSRange) {
        self.postID = postID
        super.init(kind: FormattableContentRange.Kind.post, range: range)
    }
}

public class FormattableCommentRange: FormattableContentRange {
    public let commentID: NSNumber
    public let postID: NSNumber

    init(commentID: NSNumber, postID: NSNumber, range: NSRange) {
        self.commentID = commentID
        self.postID = postID
        super.init(kind: FormattableContentRange.Kind.comment, range: range)
    }
}

public class FormattableNoticonRange: FormattableContentRange {
    public let value: String
    override var shift: Int {
        return 1
    }

    init(value: String, range: NSRange) {
        self.value = value
        super.init(kind: FormattableContentRange.Kind.noticon, range: range)
    }

    public override func apply(_ styles: FormattableContentStyles, to string: NSMutableAttributedString, withShift shift: Int) {
        //do noticon stuff
        super.apply(styles, to: string, withShift: shift)
    }
}

public class FormattableSiteRange: FormattableContentRange {
    public let siteID: NSNumber

    init(siteID: NSNumber, range: NSRange) {
        self.siteID = siteID
        super.init(kind: FormattableContentRange.Kind.site, range: range)
    }
}

public class FormattableLinkRange: FormattableContentRange {
    public let url: URL

    init(url: URL, range: NSRange) {
        self.url = url
        super.init(kind: FormattableContentRange.Kind.link, range: range)
    }

    public override func apply(_ styles: FormattableContentStyles, to string: NSMutableAttributedString, withShift shift: Int) {
        super.apply(styles, to: string, withShift: shift)

        var shiftedRange        = range
        shiftedRange.location   += shift

        if let linksColor = styles.linksColor {
            string.addAttribute(.link, value: url, range: shiftedRange)
            string.addAttribute(.foregroundColor, value: linksColor, range: shiftedRange)
        }
    }
}

extension FormattableContentRange.Kind {
    static let user       = FormattableContentRange.Kind("user")
    static let post       = FormattableContentRange.Kind("post")
    static let comment    = FormattableContentRange.Kind("comment")
    static let stats      = FormattableContentRange.Kind("stat")
    static let follow     = FormattableContentRange.Kind("follow")
    static let blockquote = FormattableContentRange.Kind("blockquote")
    static let noticon    = FormattableContentRange.Kind("noticon")
    static let site       = FormattableContentRange.Kind("site")
    static let match      = FormattableContentRange.Kind("match")
    static let link       = FormattableContentRange.Kind("link")
}
