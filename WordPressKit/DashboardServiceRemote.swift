import Foundation

open class DashboardServiceRemote: ServiceRemoteWordPressComREST {
    open func fetch(
        cards: [String],
        forBlogID blogID: Int,
        deviceId: String? = nil,
        success: @escaping (NSDictionary) -> Void,
        failure: @escaping (Error) -> Void
    ) {
        let requestUrl =  self.path(forEndpoint: "sites/\(blogID)/dashboard/cards-data/", withVersion: ._2_0)
        var params: [String: AnyObject]?

        do {
            params = try self.makeQueryParams(cards: cards, deviceId: deviceId)
        } catch {
            failure(error)
        }

        wordPressComRestApi.GET(requestUrl,
                                parameters: params,
                                success: { response, _ in
            guard let cards = response as? NSDictionary else {
                failure(ResponseError.decodingFailure)
                return
            }

            success(cards)
        }, failure: { error, _ in
            failure(error)
            WPKitLogError("Error fetching dashboard cards: \(error)")
        })
    }

    private func makeQueryParams(cards: [String], deviceId: String?) throws -> [String: AnyObject] {
        let cardsParams: [String: AnyObject] = [
            "cards": cards.joined(separator: ",") as NSString
        ]
        let featureFlagParams: [String: AnyObject]? = try {
            guard let deviceId else {
                return nil
            }
            return try SessionDetails(deviceId: deviceId).dictionaryRepresentation()
        }()
        return cardsParams.merging(featureFlagParams ?? [:]) { first, second in
            return first
        }
    }

    enum ResponseError: Error {
        case decodingFailure
    }
}
