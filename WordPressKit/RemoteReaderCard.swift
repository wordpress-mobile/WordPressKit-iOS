import Foundation

struct ReaderCardEnvelope: Decodable {
    var cards: [RemoteReaderCard]
}

struct RemoteReaderCard: Decodable {
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
