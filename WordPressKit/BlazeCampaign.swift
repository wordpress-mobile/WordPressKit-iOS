import Foundation

public final class BlazeCampaign: Decodable {
    public let campaignID: Int
    public let name: String?
    public let startDate: Date?
    public let endDate: Date?
    public let status: Status
    public let budgetCents: Int?
    public let targetURL: String?
    public let stats: Stats?
    public let contentConfig: ContentConfig?
    public let creativeHTML: String?

    public init(campaignID: Int, name: String?, startDate: Date?, endDate: Date?, status: Status, budgetCents: Int?, targetURL: String?, stats: Stats?, contentConfig: ContentConfig?, creativeHTML: String?) {
        self.campaignID = campaignID
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.budgetCents = budgetCents
        self.targetURL = targetURL
        self.stats = stats
        self.contentConfig = contentConfig
        self.creativeHTML = creativeHTML
    }

    enum CodingKeys: String, CodingKey {
        case campaignID = "campaignId"
        case name
        case startDate
        case endDate
        case status
        case budgetCents
        case targetURL = "targetUrl"
        case contentConfig
        case stats = "campaignStats"
        case creativeHTML = "creativeHtml"
    }

    public enum Status: String, Decodable {
        case scheduled
        case created
        case rejected
        case approved
        case active
        case canceled
        case finished
        case processing
        case unknown

        public init(from decoder: Decoder) throws {
            let status = try? String(from: decoder)
            self = status.flatMap(Status.init) ?? .unknown
        }
    }

    public struct Stats: Decodable {
        public let impressionsTotal: Int?
        public let clicksTotal: Int?

        public init(impressionsTotal: Int?, clicksTotal: Int?) {
            self.impressionsTotal = impressionsTotal
            self.clicksTotal = clicksTotal
        }
    }

    public struct ContentConfig: Decodable {
        public let title: String?
        public let snippet: String?
        public let clickURL: String?
        public let imageURL: String?

        public init(title: String?, snippet: String?, clickURL: String?, imageURL: String?) {
            self.title = title
            self.snippet = snippet
            self.clickURL = clickURL
            self.imageURL = imageURL
        }

        enum CodingKeys: String, CodingKey {
            case title
            case snippet
            case clickURL = "clickUrl"
            case imageURL = "imageUrl"
        }
    }
}
