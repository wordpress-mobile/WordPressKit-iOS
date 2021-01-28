extension ReaderPostServiceRemote {
    /// Returns a collection of RemoteReaderCard
    /// a Reader Card can represent an item for the reader feed, such as
    /// - Reader Post
    /// - Topics you may like
    /// - Blogs you may like and so on
    ///
    /// - Parameter topics: an array of String representing the topics
    /// - Parameter page: a String that represents a page handle
    /// - Parameter sortingOption: a String that represents a sorting option
    /// - Parameter success: Called when the request succeeds and the data returned is valid
    /// - Parameter failure: Called if the request fails for any reason, or the response data is invalid
    public func fetchCards(for topics: [String],
                           page: String? = nil,
                           sortingOption: String? = nil,
                           refreshCount: Int? = nil,
                           success: @escaping ([RemoteReaderCard], String?) -> Void,
                           failure: @escaping (Error) -> Void) {
        guard let requestUrl = cardsEndpoint(for: topics, page: page, sortingOption: sortingOption, refreshCount: refreshCount) else {
            return
        }

        wordPressComRestApi.GET(requestUrl,
                                parameters: nil,
                                success: { response, _ in

                                    do {
                                        let decoder = JSONDecoder()
                                        let data = try JSONSerialization.data(withJSONObject: response, options: [])
                                        let envelope = try decoder.decode(ReaderCardEnvelope.self, from: data)

                                        success(envelope.cards, envelope.nextPageHandle)
                                    } catch {
                                        DDLogError("Error parsing the reader cards response: \(error)")
                                        failure(error)
                                    }
        }, failure: { error, _ in
            DDLogError("Error fetching reader cards: \(error)")
            
            failure(error)
        })
    }

    private func cardsEndpoint(for topics: [String], page: String? = nil, sortingOption: String? = nil, refreshCount: Int? = nil) -> String? {
        var path = URLComponents(string: "read/tags/cards")

        path?.queryItems = topics.map { URLQueryItem(name: "tags[]", value: $0) }

        if let page = page {
            path?.queryItems?.append(URLQueryItem(name: "page_handle", value: page))
        }
        
        if let sortingOption = sortingOption {
            path?.queryItems?.append(URLQueryItem(name: "sort", value: sortingOption))
        }

        if let refreshCount = refreshCount {
            path?.queryItems?.append(URLQueryItem(name: "refresh", value: String(refreshCount)))
        }

        guard let endpoint = path?.string else {
            return nil
        }

        return self.path(forEndpoint: endpoint, withVersion: ._2_0)
    }
}
