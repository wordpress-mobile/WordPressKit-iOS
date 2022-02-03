import Foundation

open class DashboardServiceRemote: ServiceRemoteWordPressComREST {
    open func fetch(cards: [String], forBlogID blogID: Int, completion: @escaping (NSDictionary) -> Void) {
        guard let requestUrl = endpoint(for: cards, blogID: blogID) else {
            return
        }

        wordPressComRestApi.GET(requestUrl,
                                parameters: nil,
                                success: { response, _ in
            guard let cards = response["body"] as? NSDictionary else {
                // failure
                return
            }

            completion(cards)
        }, failure: { error, _ in
            DDLogError("Error fetching dashboard cards: \(error)")
        })
    }

    private func endpoint(for cards: [String], blogID: Int) -> String? {
        var path = URLComponents(string: "sites/\(blogID)/dashboard/cards/v1_1/")

        let cardsEncoded = cards.joined(separator: ",")
        path?.queryItems = [URLQueryItem(name: "cards", value: cardsEncoded)]

        guard let endpoint = path?.string else {
            return nil
        }

        return self.path(forEndpoint: endpoint, withVersion: ._2_0)
    }
}
