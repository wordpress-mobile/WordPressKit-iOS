import Foundation

public struct WPTerm {
    public let termID: Int
    public let name: String
    public let slug: String
    public let termGroup: Int
    public let termTaxonomyID: Int
    public let taxonomy: String
    public let description: String?
    public let parent: Int
    public let count: Int
    public let filter: String
    public let customFields: [String]
}
