import Foundation

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
