import Foundation

public final class BlazeServiceRemote: ServiceRemoteWordPressComREST {

    public typealias BlazeStatusResponseCallback = (Result<Bool, Error>) -> Void

    public enum BlazeServiceRemoteError: Error {
        case InvalidDataError
    }

    // MARK: - Status

    public func getStatus(forSiteId siteId: Int, callback: @escaping BlazeStatusResponseCallback) {

        let endpoint = "sites/\(siteId)/blaze/status"
        let path = self.path(forEndpoint: endpoint, withVersion: ._2_0)

        wordPressComRestApi.GET(path, parameters: nil, success: { response, _ in
            if let json = response as? [String: Any],
               let approved = json["approved"] as? Bool {
                callback(.success(approved))
            } else {
                callback(.failure(BlazeServiceRemoteError.InvalidDataError))
            }
        }, failure: { error, response in
            WPKitLogError("Error retrieving blaze status")
            WPKitLogError("\(error)")

            if let response = response {
                WPKitLogDebug("Response Code: \(response.statusCode)")
            }

            callback(.failure(error))
        })
    }

    // MARK: - Campaigns

    func getCampaignsSummary(forsSiteId siteId: Int, callback: @escaping (Result<BlazeCampaignsSummaryResponse, Error>) -> Void) {
        let endpoint = "sites/\(siteId)/wordads/dsp/api/v1/campaigns/site/\(siteId)/summary"
        let path = self.path(forEndpoint: endpoint, withVersion: ._2_0)
        wordPressComRestApi.GET(path, parameters: nil, success: { response, _ in
            do {
                let data = try JSONSerialization.data(withJSONObject: response)
                let response = try JSONDecoder.apiDecoder.decode(BlazeCampaignsSummaryResponse.self, from: data)
                callback(.success((response)))
            } catch {
                WPKitLogError("Error parsing campaigns response: \(error), \(response)")
                callback(.failure(error))
            }
        }, failure: { error, _ in
            callback(.failure(error))
        })
    }

    func getCampaignsSearch(forSiteId siteId: Int, page: Int = 1, callback: @escaping (Result<BlazeCampaignsSearchResponse, Error>) -> Void) {
        let endpoint = "sites/\(siteId)/wordads/dsp/api/v1/search/campaigns"
        let path = self.path(forEndpoint: endpoint, withVersion: ._2_0)
        wordPressComRestApi.GET(path, parameters: [
            "order": "asc" as AnyObject,
            "order_by": "post_date" as AnyObject,
            "page": "\(page)" as AnyObject,
            "site_id": "\(siteId)" as AnyObject
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
            callback(.failure(error))
        })
    }
}
