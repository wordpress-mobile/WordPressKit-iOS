struct ReaderCardEnvelope: Decodable {
    var cards: [ReaderRemoteCard]
}

struct ReaderRemoteCard: Decodable {
    enum CardType: String {
        case post
        case unknown
    }

    var type: CardType
    var post: RemoteReaderPost?

    private enum CodingKeys: String, CodingKey {
        case type
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeString = try container.decode(String.self, forKey: .type)
        type = CardType(rawValue: typeString) ?? .unknown

        switch type {
        case .post:
            let postDictionary = try container.decode([String: Any].self, forKey: .data)
            post = RemoteReaderPost(dictionary: postDictionary)
        default:
            post = nil
        }
    }
}

extension ReaderPostServiceRemote {
    func fetchCards(success: @escaping ([ReaderRemoteCard]) -> Void) {
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
