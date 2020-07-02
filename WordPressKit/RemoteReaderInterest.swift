import Foundation

struct ReaderInterestEnvelope: Decodable {
    var interests: [RemoteReaderInterest]
}

public struct RemoteReaderInterest: Decodable {
    var title: String
    var slug: String

    private enum CodingKeys: String, CodingKey {
        case title
        case slug = "slug-en"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        slug = try container.decode(String.self, forKey: .slug)
    }
}
