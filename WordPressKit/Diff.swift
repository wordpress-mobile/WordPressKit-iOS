import Foundation


/// Diff model
public struct Diff: Codable {
    public var fromRevisionId: Int
    public var toRevisionId: Int

    public var values: DiffValues

    private enum CodingKeys: String, CodingKey {
        case fromRevisionId = "from"
        case toRevisionId = "to"
        case values = "diff"
    }

    public init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: CodingKeys.self)

        fromRevisionId = (try? data.decode(Int.self, forKey: .fromRevisionId)) ?? 0
        toRevisionId = (try? data.decode(Int.self, forKey: .toRevisionId)) ?? 0
        values = try data.decode(DiffValues.self, forKey: .values)
    }
}


public struct DiffValues: Codable {
    public var totals: DiffTotals?

    public var titleDiffs: [DiffValue]
    public var contentDiffs: [DiffValue]

    private enum CodingKeys: String, CodingKey {
        case titleDiffs = "post_title"
        case contentDiffs = "post_content"
        case totals
    }
}


public struct DiffTotals: Codable {
    public var totalAdditions: Int
    public var totalDeletions: Int

    private enum CodingKeys: String, CodingKey {
        case totalAdditions = "add"
        case totalDeletions = "del"
    }


    public init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: CodingKeys.self)

        totalAdditions = (try? data.decode(Int.self, forKey: .totalAdditions)) ?? 0
        totalDeletions = (try? data.decode(Int.self, forKey: .totalDeletions)) ?? 0
    }
}


public enum DiffOperation: String, Codable {
    case add
    case copy
    case del
    case unknown
}


public struct DiffValue: Codable {
    public var operation: DiffOperation
    public var value: String?

    private enum CodingKeys: String, CodingKey {
        case operation = "op"
        case value
    }

    public init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: CodingKeys.self)

        operation = (try? data.decode(DiffOperation.self, forKey: .operation)) ?? .unknown
        value = try? data.decode(String.self, forKey: .value)
    }
}
