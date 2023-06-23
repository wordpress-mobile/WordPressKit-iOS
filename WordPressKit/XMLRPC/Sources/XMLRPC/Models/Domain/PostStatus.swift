import Foundation

public enum PostStatus: String, CustomStringConvertible {
    case draft
    case pending
    case `private`
    case publish
    case future
    case trash
    case deleted

    public var description: String {
        self.rawValue
    }
}

public enum PostField: String, CaseIterable {
    case post
    case terms
    case custom_fields
}
