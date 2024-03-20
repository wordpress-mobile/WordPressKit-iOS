import Foundation

extension NSDate {

    static let rfc3339Formatter = DateFormatter.rfc3339Formatter

    /// Parses a date string
    ///
    /// Dates in the format specified in http://www.w3.org/TR/NOTE-datetime should be OK.
    /// The kind of dates returned by the REST API should match that format, even if the doc promises ISO 8601.
    ///
    /// Parsing the full ISO 8601, or even RFC 3339 is more complex than this, and makes no sense right now.
    ///
    /// - Warning: This method doesn't support fractional seconds or dates with leap seconds (23:59:60 turns into 23:59:00)
    //
    // Needs to be `public` because of the usages in the Objective-C code.
    @objc(dateWithWordPressComJSONString:)
    public static func with(wordPressComJSONString jsonString: String) -> Date? {
        self.rfc3339Formatter.date(from: jsonString)
    }

    @objc(WordPressComJSONString)
    public func wordPressComJSONString() -> String {
        NSDate.rfc3339Formatter.string(from: self as Date)
    }
}

extension DateFormatter {

    static let rfc3339Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        return formatter
    }()
}
