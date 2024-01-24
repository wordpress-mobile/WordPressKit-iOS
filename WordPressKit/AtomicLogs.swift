import Foundation

public final class AtomicLogMessage: Decodable {
    public let message: String?
    public let severity: String?
    public let kind: String?
    public let name: String?
    public let file: String?
    public let line: Int?
    public let timestamp: Date?

    public enum Severity: String {
        case user = "User"
        case warning = "Warning"
        case deprecated = "Deprecated"
        case fatalError = "Fatal error"
    }
}

public final class AtomicErrorLogsResponse: Decodable {
    public let totalResults: Int
    public let logs: [AtomicLogMessage]
    public let scrollId: String?
}
