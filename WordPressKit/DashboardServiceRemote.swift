import Foundation

#if SWIFT_PACKAGE
import WordPressKitObjC
#endif

open class DashboardServiceRemote: ServiceRemoteWordPressComREST {
    open func fetch(cards: [String], forBlogID blogID: Int, success: @escaping (NSDictionary) -> Void, failure: @escaping (Error) -> Void) {
        guard let requestUrl = endpoint(for: cards, blogID: blogID) else {
            return
        }

        wordPressComRestApi.get(requestUrl,
                                parameters: nil,
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

    private func endpoint(for cards: [String], blogID: Int) -> String? {
        var path = URLComponents(string: "sites/\(blogID)/dashboard/cards-data/")

        let cardsEncoded = cards.joined(separator: ",")
        path?.queryItems = [URLQueryItem(name: "cards", value: cardsEncoded)]

        guard let endpoint = path?.string else {
            return nil
        }

        return self.path(forEndpoint: endpoint, withVersion: ._2_0)
    }

    enum ResponseError: Error {
        case decodingFailure
    }
}
