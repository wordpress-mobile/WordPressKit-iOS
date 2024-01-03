import Foundation

open class DashboardServiceRemote: ServiceRemoteWordPressComREST {
    open func fetch(cards: [String], forBlogID blogID: Int, success: @escaping (NSDictionary) -> Void, failure: @escaping (Error) -> Void) {
        let requestUrl =  self.path(forEndpoint: "sites/\(blogID)/dashboard/cards-data/", withVersion: ._2_0)

        let params: [String: AnyObject] = [
            "cards": cards.joined(separator: ",") as NSString
        ]

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

    enum ResponseError: Error {
        case decodingFailure
    }
}
