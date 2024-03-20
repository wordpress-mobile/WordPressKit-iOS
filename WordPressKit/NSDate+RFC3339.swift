import Foundation

extension NSDate {

    @objc(WordPressComJSONString)
    public func wordPressComJSONString() -> String {
        NSDate.rfc3339DateFormatter().string(from: self as Date)
    }
}
