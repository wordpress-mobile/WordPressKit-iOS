import Foundation

open class BlazeServiceRemote: ServiceRemoteWordPressComREST {

    // MARK: - Campaigns

    /// Searches the campaigns for the site with the given ID. The campaigns are returned ordered by the post date.
    ///
    /// - parameters:
    ///   - siteId: The site ID.
    ///   - page: The response page. By default, returns the first page.
    open func searchCampaigns(forSiteId siteId: Int, page: Int = 1, callback: @escaping (Result<BlazeCampaignsSearchResponse, Error>) -> Void) {
        let endpoint = "sites/\(siteId)/wordads/dsp/api/v1/search/campaigns/site/\(siteId)"
        let path = self.path(forEndpoint: endpoint, withVersion: ._2_0)
        wordPressComRestApi.GET(path, parameters: [
            "page": "\(page)" as AnyObject
        ], success: { response, _ in
            do {
                let data = try JSONSerialization.data(withJSONObject: response)
                let response = try JSONDecoder.apiDecoder.decode(BlazeCampaignsSearchResponse.self, from: data)
                callback(.success((response)))
            } catch {
                WPKitLogError("Error parsing campaigns response: \(error), \(response)")
                callback(.failure(error))
            }
        }, failure: { error, _ in
            WPKitLogError("Error retrieving blaze campaigns: ", error)
            callback(.failure(error))
        })
    }
}
