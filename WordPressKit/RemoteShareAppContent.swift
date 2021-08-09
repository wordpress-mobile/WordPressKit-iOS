/// Defines the information structure used for recommending the app to others.
///
public struct RemoteShareAppContent: Codable {
    /// A text content to share.
    public let message: String

    /// A URL string that directs the recipient to a page describing steps to get the app.
    public let link: String

    /// Convenience property that returns `link` as URL.
    private(set) public lazy var linkURL: URL? = {
        URL(string: link)
    }()
}
