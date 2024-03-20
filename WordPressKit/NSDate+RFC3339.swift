import Foundation

extension NSDate {

    // TODO: Make `static let` after conversion since it's not used outside WordPressKit
    @objc
    static func rfc3339DateFormatter() -> DateFormatter {
        DateFormatter.rfc3339Formatter
    }

    @objc(WordPressComJSONString)
    public func wordPressComJSONString() -> String {
        NSDate.rfc3339DateFormatter().string(from: self as Date)
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
