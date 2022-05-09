public struct RemoteBloggingPrompt {
    public var promptID: Int
    public var text: String
    public var title: String
    public var content: String
    public var attribution: String
    public var date: Date
    public var answered: Bool
    public var answeredUsersCount: Int
    public var answeredUserAvatarURLs: [URL]
}

// MARK: - Decodable

extension RemoteBloggingPrompt: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case title
        case content
        case attribution
        case date
        case answered
        case answeredUsersCount = "answered_users_count"
        case answeredUserAvatarURLs = "answered_users_sample"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.promptID = try container.decode(Int.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        self.title = try container.decode(String.self, forKey: .title)
        self.content = try container.decode(String.self, forKey: .content)
        self.attribution = try container.decode(String.self, forKey: .attribution)
        self.answered = try container.decode(Bool.self, forKey: .answered)
        self.date = try container.decode(Date.self, forKey: .date)
        self.answeredUsersCount = try container.decode(Int.self, forKey: .answeredUsersCount)

        let userAvatars = try container.decode([UserAvatar].self, forKey: .answeredUserAvatarURLs)
        self.answeredUserAvatarURLs = userAvatars.compactMap { URL(string: $0.avatar) }
    }

    /// meta structure to simplify decoding logic for user avatar objects.
    /// this is intended to be private.
    private struct UserAvatar: Codable {
        var avatar: String
    }
}
