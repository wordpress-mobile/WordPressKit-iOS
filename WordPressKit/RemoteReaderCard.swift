import Foundation

struct ReaderCardEnvelope: Decodable {
    var cards: [RemoteReaderCard]
}

public struct RemoteReaderCard: Decodable {
    public enum CardType: String {
        case post
        case interests = "interests_you_may_like"
        case unknown
    }

    public var type: CardType
    public var post: RemoteReaderPost?
    public var interests: [RemoteReaderInterest]?

    private enum CodingKeys: String, CodingKey {
        case type
        case data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeString = try container.decode(String.self, forKey: .type)
        type = CardType(rawValue: typeString) ?? .unknown

        switch type {
        case .post:
            let postDictionary = try container.decode([String: Any].self, forKey: .data)
            post = RemoteReaderPost(dictionary: postDictionary)
        case .interests:
            interests = try container.decode([RemoteReaderInterest].self, forKey: .data)
        default:
            post = nil
        }
    }
}
