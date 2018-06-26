
import Foundation

public class FormattableContentFormatter {

    let styles: FormattableContentStyles

    init(styles: FormattableContentStyles) {
        self.styles = styles
    }

    func render(content: FormattableContent) -> NSAttributedString {
        return text(from: content, with: styles)
    }

    private func text(from content: FormattableContent, with styles: FormattableContentStyles) -> NSAttributedString {

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
