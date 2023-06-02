import Foundation

public final class BlazeCampaignsSummaryResponse: Decodable {
    public var campaigns: [BlazeCampaign] { results ?? [] }
    public let canCreateCampaigns: Bool
    public let total: Int?

    let results: [BlazeCampaign]?

    public init(campaigns: [BlazeCampaign], canCreateCampaigns: Bool, total: Int?) {
        self.results = campaigns
        self.canCreateCampaigns = canCreateCampaigns
        self.total = total
    }
}
