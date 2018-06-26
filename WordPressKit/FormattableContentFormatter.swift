
import Foundation

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

protocol FormattableContentStyles {
    var attributes: [NSAttributedStringKey: Any] { get }
    var quoteStyles: [NSAttributedStringKey: Any]? { get }
    var rangeStylesMap: [FormattableContentRange.Kind: [NSAttributedStringKey: Any]]? { get }
    var linksColor: UIColor? { get }
}

class ActivityFormattableContentStyles: FormattableContentStyles {
    var attributes: [NSAttributedStringKey : Any] {
        return subjectRegularStyle
    }

    var quoteStyles: [NSAttributedStringKey : Any]? {
        return blockQuotedStyle
    }

    var rangeStylesMap: [FormattableContentRange.Kind : [NSAttributedStringKey : Any]]? {
        return subjectRangeStylesMap
    }

    var linksColor: UIColor? {
        return .yellow
    }

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
}

class FormattableContentFormatter {

    let styles: FormattableContentStyles

    init(styles: FormattableContentStyles) {
        self.styles = styles
    }

    func render<ParentType: FormattableContentParent>(content: FormattableContent<ParentType>) -> NSAttributedString {
        return text(from: content, with: styles)
    }


    private func text<ParentType: FormattableContentParent>(from content: FormattableContent<ParentType>, with styles: FormattableContentStyles) -> NSAttributedString {

        guard let text = content.text else {
            return NSAttributedString()
        }

        let tightenedText = replaceCommonWhitespaceIssues(in: text)
        let theString = NSMutableAttributedString(string: tightenedText, attributes: styles.attributes)

        if let quoteStyles = styles.quoteStyles {
            theString.applyAttributes(toQuotes: quoteStyles)
        }

        // Apply the Ranges
        var lengthShift = 0

        for range in content.ranges {
            var shiftedRange        = range.range
            shiftedRange.location   += lengthShift

            if range.kind == .Noticon {
                let noticon         = (range.value ?? String()) + " "
                theString.replaceCharacters(in: shiftedRange, with: noticon)
                lengthShift         += noticon.count
                shiftedRange.length += noticon.count
            }

            if let rangeStyle = styles.rangeStylesMap?[range.kind] {
                theString.addAttributes(rangeStyle, range: shiftedRange)
            }

            if let rangeURL = range.url, let linksColor = styles.linksColor {
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
