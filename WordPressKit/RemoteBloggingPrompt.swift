public struct RemoteBloggingPrompt {
    public var promptID: Int
    public var text: String
    public var title: String
    public var content: String
    public var date: Date
    public var answered: Bool
    public var answeringUserCount: Int
    public var answeringUserAvatarURLs: [URL]
}

// MARK: - Decodable

extension RemoteBloggingPrompt: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case title
        case content
        case date = "date_gmt"
        case answered = "i_answered"
        case answeringUserCount = "answering_user_count"
        case answeringUserAvatarURLs = "answering_user_avatars"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.promptID = try container.decode(Int.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        self.title = try container.decode(String.self, forKey: .title)
        self.content = try container.decode(String.self, forKey: .content)

        // since `date_gmt` is already in GMT timezone, manually add the timezone string to make the rfc3339 formatter happy (or it will throw otherwise).
        guard let dateString = try? container.decode(String.self, forKey: .date),
              let date = NSDate(wordPressComJSONString: dateString + "+00:00") as Date? else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Date parsing failed")
        }
        self.date = date
        self.answered = try container.decode(Bool.self, forKey: .answered)
        self.answeringUserCount = try container.decode(Int.self, forKey: .answeringUserCount)

        let userAvatars = try container.decode([UserAvatar].self, forKey: .answeringUserAvatarURLs)
        self.answeringUserAvatarURLs = userAvatars.compactMap { URL(string: $0.avatarURL) }
    }

    /// meta structure to simplify decoding logic for user avatar objects.
    /// this is intended to be private.
    private struct UserAvatar: Codable {
        var avatarURL: String

        enum CodingKeys: String, CodingKey {
            case avatarURL = "avatar_URL"
        }
    }
}
