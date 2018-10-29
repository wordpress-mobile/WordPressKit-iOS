import Foundation


/// Diff model
public struct Diff: Codable {
    /// Revision id from the content has been changed
    public var fromRevisionId: Int

    /// Current revision id
    public var toRevisionId: Int

    /// Model for the diff values
    public var values: DiffValues

    /// Mapping keys
    private enum CodingKeys: String, CodingKey {
        case fromRevisionId = "from"
        case toRevisionId = "to"
        case values = "diff"
    }


    // MARK - Decode protocol

    public init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: CodingKeys.self)

        fromRevisionId = (try? data.decode(Int.self, forKey: .fromRevisionId)) ?? 0
        toRevisionId = (try? data.decode(Int.self, forKey: .toRevisionId)) ?? 0
        values = try data.decode(DiffValues.self, forKey: .values)
    }
}


public struct DiffValues: Codable {
    /// Model for the diff totals operations
    public var totals: DiffTotals?

    /// Title diffs array
    public var titleDiffs: [DiffValue]

    /// Content diffs array
    public var contentDiffs: [DiffValue]

    /// Mapping keys
    private enum CodingKeys: String, CodingKey {
        case titleDiffs = "post_title"
        case contentDiffs = "post_content"
        case totals
    }
}


/// DiffTotals model
public struct DiffTotals: Codable {
    /// Total of additional operations
    public var totalAdditions: Int

    /// Total of deletions operations
    public var totalDeletions: Int

    /// Mapping keys
    private enum CodingKeys: String, CodingKey {
        case totalAdditions = "add"
        case totalDeletions = "del"
    }


    // MARK - Decode protocol

    public init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: CodingKeys.self)

        totalAdditions = (try? data.decode(Int.self, forKey: .totalAdditions)) ?? 0
        totalDeletions = (try? data.decode(Int.self, forKey: .totalDeletions)) ?? 0
    }
}


/// Diff Operation
///
/// - add: Addition
/// - copy: Copy
/// - del: Deletion
/// - unknown: Default value
public enum DiffOperation: String, Codable {
    case add
    case copy
    case del
    case unknown
}


/// DiffValue
public struct DiffValue: Codable {
    /// Diff operation
    public var operation: DiffOperation

    /// Diff value
    public var value: String?

    /// Mapping keys
    private enum CodingKeys: String, CodingKey {
        case operation = "op"
        case value
    }


    // MARK - Decode protocol

    public init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: CodingKeys.self)

        operation = (try? data.decode(DiffOperation.self, forKey: .operation)) ?? .unknown
        value = try? data.decode(String.self, forKey: .value)
    }
}
