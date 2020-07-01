extension ReaderPostServiceRemote {
    func fetchCards(success: @escaping ([RemoteReaderCard]) -> Void) {
        let path = "read/cards"
        let requestUrl = self.path(forEndpoint: path, withVersion: ._1_2)

        wordPressComRestApi.GET(requestUrl,
                                parameters: nil,
                                success: { (response, _) in

                                    do {
                                        let decoder = JSONDecoder()
                                        let data = try JSONSerialization.data(withJSONObject: response, options: [])
                                        let envelope = try decoder.decode(ReaderCardEnvelope.self, from: data)

                                        success(envelope.cards)
                                    } catch {
                                        DDLogError("\(error)")
                                        DDLogDebug("Full response: \(response)")
                                    }
        }, failure: { error, _ in
            DDLogError("\(error)")
        })
    }
}
