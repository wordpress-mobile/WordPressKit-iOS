
import Foundation

public class FormattableContentFormatter {

    let styles: FormattableContentStyles

    /// Helper used by the +Interface Extension.
    ///
    fileprivate var dynamicAttributesCache = [String: AnyObject]()

    public init(styles: FormattableContentStyles) {
        self.styles = styles
    }

    public func render(content: FormattableContent) -> NSAttributedString {
        let attributedText = memoize {
            let snippet = self.text(from: content, with: self.styles)

            return snippet.trimNewlines()
        }

        return attributedText(styles.key)
    }


    /// This method is meant to aid cache-implementation into all of the AttriutedString getters introduced
    /// in this extension.
    ///
    /// - Parameter fn: A Closure that, on execution, returns an attributed string.
    ///
    /// - Returns: A new Closure that on execution will either hit the cache, or execute the closure `fn`
    ///            and store its return value in the cache.
    ///
    fileprivate func memoize(_ fn: @escaping () -> NSAttributedString) -> (String) -> NSAttributedString {
        return { cacheKey in

            if let cachedSubject = self.cacheValueForKey(cacheKey) as? NSAttributedString {
                return cachedSubject
            }

            let newValue = fn()
            self.setCacheValue(newValue, forKey: cacheKey)
            return newValue
        }
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

extension NSAttributedString {
    /// This helper method returns a new NSAttributedString instance, with all of the the leading / trailing newLines
    /// characters removed.
    ///
    @objc func trimNewlines() -> NSAttributedString {
        guard let trimmed = mutableCopy() as? NSMutableAttributedString else {
            return self
        }

        let characterSet = CharacterSet.newlines

        // Trim: Leading
        var range = (trimmed.string as NSString).rangeOfCharacter(from: characterSet)

        while range.length != 0 && range.location == 0 {
            trimmed.replaceCharacters(in: range, with: String())
            range = (trimmed.string as NSString).rangeOfCharacter(from: characterSet)
        }

        // Trim Trailing
        range = (trimmed.string as NSString).rangeOfCharacter(from: characterSet, options: .backwards)

        while range.length != 0 && NSMaxRange(range) == trimmed.length {
            trimmed.replaceCharacters(in: range, with: String())
            range = (trimmed.string as NSString).rangeOfCharacter(from: characterSet, options: .backwards)
        }

        return trimmed
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
