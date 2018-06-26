//private enum FormatConstants {
//    static let headerFontSize            = CGFloat(12)
//    static let headerLineSize            = CGFloat(16)
//    static let subjectFontSize           = CGFloat(14)
//    static let subjectNoticonSize        = CGFloat(14)
//    static let subjectLineSize           = CGFloat(18)
//    static let snippetLineSize           = subjectLineSize
//    static let blockFontSize             = CGFloat(14)
//    static let blockLineSize             = CGFloat(20)
//    static let contentBlockLineSize      = CGFloat(21)
//    static let maximumCellWidth          = CGFloat(600)
//
//    static let sectionHeaderParagraph: NSMutableParagraphStyle = NSMutableParagraphStyle(
//        minLineHeight: headerLineSize, lineBreakMode: .byWordWrapping, alignment: .natural
//    )
//    fileprivate static let subjectParagraph: NSMutableParagraphStyle = NSMutableParagraphStyle(
//        minLineHeight: subjectLineSize, lineBreakMode: .byWordWrapping, alignment: .natural
//    )
//    fileprivate static let snippetParagraph: NSMutableParagraphStyle = NSMutableParagraphStyle(
//        minLineHeight: snippetLineSize, lineBreakMode: .byWordWrapping, alignment: .natural
//    )
//    fileprivate static let blockParagraph: NSMutableParagraphStyle = NSMutableParagraphStyle(
//        minLineHeight: blockLineSize, lineBreakMode: .byWordWrapping, alignment: .natural
//    )
//    fileprivate static let contentBlockParagraph: NSMutableParagraphStyle = NSMutableParagraphStyle(
//        minLineHeight: contentBlockLineSize, lineBreakMode: .byWordWrapping, alignment: .natural
//    )
//    fileprivate static let badgeParagraph: NSMutableParagraphStyle = NSMutableParagraphStyle(
//        minLineHeight: blockLineSize, maxLineHeight: blockLineSize, lineBreakMode: .byWordWrapping, alignment: .center
//    )
//
//
//    // Fonts
//    fileprivate static let sectionHeaderFont = UIFont.systemFont(ofSize: headerFontSize, weight: .semibold)
//    fileprivate static var subjectRegularFont = UIFont.systemFont(ofSize: subjectFontSize)
//    fileprivate static var subjectBoldFont = UIFont.systemFont(ofSize: subjectFontSize, weight: .bold)
//    fileprivate static var subjectItalicsFont = UIFont.italicSystemFont(ofSize: subjectFontSize)
//
//    fileprivate static let subjectNoticonFont       = UIFont(name: "Noticons", size: subjectNoticonSize)!
//
//    fileprivate static let headerTitleRegularFont   = UIFont.systemFont(ofSize: blockFontSize)
//    fileprivate static let headerTitleItalicsFont   = blockItalicsFont
//    fileprivate static let blockItalicsFont         = UIFont.italicSystemFont(ofSize: blockFontSize)
//    fileprivate static let blockNoticonFont         = subjectNoticonFont
//
//    fileprivate static let sectionHeaderTextColor   = UIColor(red: 0xA7/255.0, green: 0xBB/255.0, blue: 0xCA/255.0, alpha: 0xFF/255.0)
//    fileprivate static let subjectTextColor         = UIColor.blue
//    fileprivate static let subjectNoticonColor      = UIColor.black
//    fileprivate static let footerTextColor          = UIColor.red
//    fileprivate static let blockNoticonColor        = UIColor.purple
//    fileprivate static let snippetColor             = UIColor.green
//    fileprivate static let headerTitleContextColor  = UIColor.orange
//    fileprivate static let blockQuotedColor          = UIColor(red: 0x7E/255.0, green: 0x9E/255.0, blue: 0xB5/255.0, alpha: 0xFF/255.0)
//}

protocol FormattableContentStyles {
    var attributes: [NSAttributedStringKey: Any] { get }
    var quoteStyles: [NSAttributedStringKey: Any]? { get }
    var rangeStylesMap: [FormattableContentRange.Kind: [NSAttributedStringKey: Any]]? { get }
    var linksColor: UIColor? { get }
}

//class ActivityFormattableContentStyles: FormattableContentStyles {
//    var attributes: [NSAttributedStringKey : Any] {
//        return subjectRegularStyle
//    }
//
//    var quoteStyles: [NSAttributedStringKey : Any]? {
//        return blockQuotedStyle
//    }
//
//    var rangeStylesMap: [FormattableContentRange.Kind : [NSAttributedStringKey : Any]]? {
//        return subjectRangeStylesMap
//    }
//
//    var linksColor: UIColor? {
//        return .yellow
//    }
//
//    // Subject Text
//    public var subjectRegularStyle: [NSAttributedStringKey: Any] {
//        return  [.paragraphStyle: FormatConstants.subjectParagraph,
//                 .font: FormatConstants.subjectRegularFont,
//                 .foregroundColor: FormatConstants.subjectTextColor ]
//    }
//
//    public var subjectBoldStyle: [NSAttributedStringKey: Any] {
//        return [.paragraphStyle: FormatConstants.subjectParagraph,
//                .font: FormatConstants.subjectBoldFont ]
//    }
//
//    public var subjectItalicsStyle: [NSAttributedStringKey: Any] {
//        return [.paragraphStyle: FormatConstants.subjectParagraph,
//                .font: FormatConstants.subjectItalicsFont ]
//    }
//
//    public var subjectNoticonStyle: [NSAttributedStringKey: Any] {
//        return [.paragraphStyle: FormatConstants.subjectParagraph,
//                .font: FormatConstants.subjectNoticonFont,
//                .foregroundColor: FormatConstants.subjectNoticonColor ]
//    }
//
//    public var blockQuotedStyle: [NSAttributedStringKey: Any] {
//        return  [.paragraphStyle: FormatConstants.blockParagraph,
//                 .font: FormatConstants.blockItalicsFont,
//                 .foregroundColor: FormatConstants.blockQuotedColor ]
//    }
//
//    public var subjectQuotedStyle: [NSAttributedStringKey: Any] {
//        return blockQuotedStyle
//    }
//
//    // Subject Snippet
//    public var snippetRegularStyle: [NSAttributedStringKey: Any] {
//        return [.paragraphStyle: FormatConstants.snippetParagraph,
//                .font: FormatConstants.subjectRegularFont,
//                .foregroundColor: FormatConstants.snippetColor ]
//    }
//
//    var subjectRangeStylesMap: [FormattableContentRange.Kind: [NSAttributedStringKey: Any]] {
//        return [
//            .User: subjectBoldStyle,
//            .Post: subjectItalicsStyle,
//            .Comment: subjectItalicsStyle,
//            .Blockquote: subjectQuotedStyle,
//            .Noticon: subjectNoticonStyle
//        ]
//    }
//}
