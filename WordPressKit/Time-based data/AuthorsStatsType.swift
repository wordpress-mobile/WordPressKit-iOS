struct AuthorsStatsType {
    let period: StatsPeriodUnit
    let periodEndDate: Date

    let topAuthors: [StatsTopAuthor]
}

struct StatsTopAuthor {
    let name: String
    let iconURL: URL?
    let viewsCount: Int
    let posts: [StatsTopPost]

    init?(jsonDictionary: [String: AnyObject]) {
        guard
            let name = jsonDictionary["name"] as? String,
            let views = jsonDictionary["views"] as? Int,
            let avatar = jsonDictionary["avatar"] as? String,
            let posts = jsonDictionary["posts"] as? [[String: AnyObject]]
            else {
                return nil
        }

        let url: URL?
        if var components = URLComponents(string: avatar) {
            components.query = "d=mm&s=60"
            url = try? components.asURL()
        } else {
            url = nil
        }

        let mappedPosts = posts.compactMap { StatsTopPost(jsonDictionary: $0) }

        self.name = name
        self.viewsCount = views
        self.iconURL = url
        self.posts = mappedPosts

    }
}

struct StatsTopPost {
    let title: String
    let postID: Int
    let postURL: URL?
    let viewsCount: Int

    init?(jsonDictionary: [String: AnyObject]) {
        guard
            let title = jsonDictionary["title"] as? String,
            let postID = jsonDictionary["id"] as? Int,
            let viewsCount = jsonDictionary["views"] as? Int,
            let postURL = jsonDictionary["url"] as? String
            else {
                return nil
        }

        self.title = title
        self.postID = postID
        self.viewsCount = viewsCount
        self.postURL = URL(string: postURL)
    }
}

extension AuthorsStatsType: TimeStatsProtocol {
    static var pathComponent: String {
        return "stats/top-authors/"
    }

    init?(date: Date, period: StatsPeriodUnit, jsonDictionary: [String : AnyObject]) {
        guard
            let days = jsonDictionary["days"] as? [String: AnyObject],
            let firstKey = days.keys.first,
            let firstDay = days[firstKey] as? [String: AnyObject],
            let authors = firstDay["authors"] as? [[String: AnyObject]]
            else {
                return nil
        }

        self.period = period
        self.periodEndDate = date
        self.topAuthors = authors.compactMap { StatsTopAuthor(jsonDictionary: $0) }
    }
}
