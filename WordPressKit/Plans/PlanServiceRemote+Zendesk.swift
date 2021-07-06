
extension PlanServiceRemote {
    /// Retrieves Zendesk meta data: plan and Jetpack addons, if available
    public func getZendeskMetadata(siteID: Int, completion: @escaping (Result<ZendeskMetadata, Error>) -> Void) {
        let endpoint = "me/sites"
        let path = self.path(forEndpoint: endpoint, withVersion: ._1_1)
        let parameters: [String: String] = ["fields": "ID, zendesk_site_meta"]

        wordPressComRestApi.GETData(path, parameters: parameters as [String: AnyObject]) { result in
            switch result {
            case .success((let data, _)):
                do {
                    let metadata = try self.decodeZendeskMetadata(from: data, siteID: siteID)
                    completion(.success(metadata))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func decodeZendeskMetadata(from data: Data, siteID: Int) throws -> ZendeskMetadata {
        let container = try JSONDecoder().decode(ZendeskSiteContainer.self, from: data)
        return container.sites.filter { $0.ID == siteID }.first!.zendeskMetadata
    }
}


public struct ZendeskSiteContainer: Decodable {
    public let sites: [ZendeskSite]
}


public struct ZendeskSite: Decodable {
    public let ID: Int
    public let zendeskMetadata: ZendeskMetadata

    private enum CodingKeys: String, CodingKey {
        case ID = "ID"
        case zendeskMetadata = "zendesk_site_meta"
    }
}


public struct ZendeskMetadata: Decodable {
    public let plan: String
    public let jetpackAddons: [String]

    private enum CodingKeys: String, CodingKey {
        case plan = "plan"
        case jetpackAddons = "addon"
    }
}