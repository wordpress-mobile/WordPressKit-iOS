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

    /// Used to format the fetched object's date string to a date.
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.timeZone = .init(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.promptID = try container.decode(Int.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        self.title = try container.decode(String.self, forKey: .title)
        self.content = try container.decode(String.self, forKey: .content)
        self.attribution = try container.decode(String.self, forKey: .attribution)
        self.answered = try container.decode(Bool.self, forKey: .answered)
        self.date = Self.dateFormatter.date(from: try container.decode(String.self, forKey: .date)) ?? Date()
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
