import Foundation

/// This class encapsulates all of the *remote* settings available for a Blog entity
///
public class RemoteBlogSettings: NSObject {
    // MARK: - General

    /// Represents the Blog Name.
    ///
    @objc public var name: String?

    /// Stores the Blog's Tagline setting.
    ///
    @objc public var tagline: String?

    /// Stores the Blog's Privacy Preferences Settings
    ///
    @objc public var privacy: NSNumber?

    /// Stores the Blog's Language ID Setting
    ///
    @objc public var languageID: NSNumber?

    /// Stores the Blog's Icon Media ID
    ///
    @objc public var iconMediaID: NSNumber?

    /// Stores the Blog's GMT offset
    ///
    @objc public var gmtOffset: NSNumber?

    /// Stores the Blog's timezone
    ///
    @objc public var timezoneString: String?

    // MARK: - Writing

    /// Contains the Default Category ID. Used when creating new posts.
    ///
    @objc public var defaultCategoryID: NSNumber?

    /// Contains the Default Post Format. Used when creating new posts.
    ///
    @objc public var defaultPostFormat: String?

    /// The blog's date format setting.
    ///
    @objc public var dateFormat: String?

    /// The blog's time format setting
    ///
    @objc public var timeFormat: String?

    /// The blog's chosen day to start the week setting
    ///
    @objc public var startOfWeek: String?

    /// Numbers of posts per page
    ///
    @objc public var postsPerPage: NSNumber?

    // MARK: - Discussion

    /// Represents whether comments are allowed, or not.
    ///
    @objc public var commentsAllowed: NSNumber?

    /// Contains a list of words that would automatically blocklist a comment.
    ///
    @objc public var commentsBlocklistKeys: String?

    /// If true, comments will be automatically closed after the number of days, specified by `commentsCloseAutomaticallyAfterDays`.
    ///
    @objc public var commentsCloseAutomatically: NSNumber?

    /// Represents the number of days comments will be enabled, granted that the `commentsCloseAutomatically`
    /// property is set to true.
    ///
    @objc public var commentsCloseAutomaticallyAfterDays: NSNumber?

    /// When enabled, comments from known users will be allowlisted.
    ///
    @objc public var commentsFromKnownUsersAllowlisted: NSNumber?

    /// Indicates the maximum number of links allowed per comment. When a new comment exceeds this number,
    /// it'll be held in queue for moderation.
    ///
    @objc public var commentsMaximumLinks: NSNumber?

    /// Contains a list of words that cause a comment to require moderation.
    ///
    @objc public var commentsModerationKeys: String?

    /// If true, comment pagination will be enabled.
    ///
    @objc public var commentsPagingEnabled: NSNumber?

    /// Specifies the number of comments per page. This will be used only if the property `commentsPagingEnabled`
    /// is set to true.
    ///
    @objc public var commentsPageSize: NSNumber?

    /// When enabled, new comments will require Manual Moderation, before showing up.
    ///
    @objc public var commentsRequireManualModeration: NSNumber?

    /// If set to true, commenters will be required to enter their name and email.
    ///
    @objc public var commentsRequireNameAndEmail: NSNumber?

    /// Specifies whether commenters should be registered or not.
    ///
    @objc public var commentsRequireRegistration: NSNumber?

    /// Indicates the sorting order of the comments. Ascending / Descending, based on the date.
    ///
    @objc public var commentsSortOrder: String?

    /// Indicates the number of levels allowed per comment.
    ///
    @objc public var commentsThreadingDepth: NSNumber?

    /// When enabled, comment threading will be supported.
    ///
    @objc public var commentsThreadingEnabled: NSNumber?

    /// If set to true, 3rd party sites will be allowed to post pingbacks.
    ///
    @objc public var pingbackInboundEnabled: NSNumber?

    /// When Outbound Pingbacks are enabled, 3rd party sites that get linked will be notified.
    ///
    @objc public var pingbackOutboundEnabled: NSNumber?

    // MARK: - Related Posts

    /// When set to true, Related Posts will be allowed.
    ///
    @objc public var relatedPostsAllowed: NSNumber?

    /// When set to true, Related Posts will be enabled.
    ///
    @objc public var relatedPostsEnabled: NSNumber?

    /// Indicates whether related posts should show a headline.
    ///
    @objc public var relatedPostsShowHeadline: NSNumber?

    /// Indicates whether related posts should show thumbnails.
    ///
    @objc public var relatedPostsShowThumbnails: NSNumber?

    // MARK: - AMP

    /// Indicates if AMP is supported on the site
    ///
    @objc public var ampSupported: NSNumber?

    /// Indicates if AMP is enabled on the site
    ///
    @objc public var ampEnabled: NSNumber?

    // MARK: - Sharing

    /// Indicates the style to use for the sharing buttons on a particular blog..
    ///
    @objc public var sharingButtonStyle: String?

    /// The title of the sharing label on the user's blog.
    ///
    @objc public var sharingLabel: String?

    /// Indicates the twitter username to use when sharing via Twitter
    ///
    @objc public var sharingTwitterName: String?

    /// Indicates whether related posts should show thumbnails.
    ///
    @objc public var sharingCommentLikesEnabled: NSNumber?

    /// Indicates whether sharing via post likes has been disabled
    ///
    @objc public var sharingDisabledLikes: NSNumber?

    /// Indicates whether sharing by reblogging has been disabled
    ///
    @objc public var sharingDisabledReblogs: NSNumber?

    // Defined as CodingKey-conforming already to simplify Codable support in the future.
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case tagline = "description"
        case privacy = "blog_public"
        case languageID = "lang_id"
        case iconMediaID = "site_icon"
        case gmtOffset = "gmt_offset"
        case timezoneString = "timezone_string"
        case settings = "settings"
        case defaultCategory = "default_category"
        case defaultPostFormat = "default_post_format"
        case dateFormat = "date_format"
        case timeFormat = "time_format"
        case startOfWeek = "start_of_week"
        case postsPerPage = "posts_per_page"
        case commentsAllowed = "default_comment_status"
        case commentsBlocklistKeys = "blacklist_keys"
        case commentsCloseAutomatically = "close_comments_for_old_posts"
        case commentsCloseAutomaticallyAfterDays = "close_comments_days_old"
        case commentsKnownUsersAllowlist = "comment_whitelist"
        case commentsMaxLinks = "comment_max_links"
        case commentsModerationKeys = "moderation_keys"
        case commentsPagingEnabled = "page_comments"
        case commentsPageSize = "comments_per_page"
        case commentsRequireModeration = "comment_moderation"
        case commentsRequireNameAndEmail = "require_name_email"
        case commentsRequireRegistration = "comment_registration"
        case commentsSortOrder = "comment_order"
        case commentsThreadingEnabled = "thread_comments"
        case commentsThreadingDepth = "thread_comments_depth"
        case pingbackOutbound = "default_pingback_flag"
        case pingbackInbound = "default_ping_status"
        case relatedPostsAllowed = "jetpack_relatedposts_allowed"
        case relatedPostsEnabled = "jetpack_relatedposts_enabled"
        case relatedPostsShowHeadline = "jetpack_relatedposts_show_headline"
        case relatedPostsShowThumbnails = "jetpack_relatedposts_show_thumbnails"
        case ampSupported = "amp_is_supported"
        case ampEnabled = "amp_is_enabled"

        case sharingButtonStyle = "sharing_button_style"
        case sharingLabel = "sharing_label"
        case sharingTwitterName = "twitter_via"
        case sharingCommentLikesEnabled = "jetpack_comment_likes_enabled"
        case sharingDisabledLikes = "disabled_likes"
        case sharingDisabledReblogs = "disabled_reblogs"
    }

    /// Parses details from a JSON dictionary, as returned by the WordPress.com REST API.
    @objc
    public init(jsonDictionary json: NSDictionary) {
        let rawSettings = json.object(forKey: CodingKeys.settings.rawValue) as? NSDictionary ?? [:]

        name = json.string(forKey: CodingKeys.name.rawValue)
        tagline = json.string(forKey: CodingKeys.tagline.rawValue)
        privacy = rawSettings.number(forKey: CodingKeys.privacy.rawValue)
        languageID = rawSettings.number(forKey: CodingKeys.languageID.rawValue)
        iconMediaID = rawSettings.number(forKey: CodingKeys.iconMediaID.rawValue)
        gmtOffset = rawSettings.number(forKey: CodingKeys.gmtOffset.rawValue)
        timezoneString = rawSettings.string(forKey: CodingKeys.timezoneString.rawValue)

        defaultCategoryID = rawSettings.number(forKey: CodingKeys.defaultCategory.rawValue) ?? 1
        let defaultPostFormatValue = rawSettings.object(forKey: CodingKeys.defaultPostFormat.rawValue)
        if let defaultPostFormatNumber = defaultPostFormatValue as? NSNumber, defaultPostFormatNumber == 0 ||
           defaultPostFormatValue as? String == "0" {
            defaultPostFormat = "standard"
        } else {
            defaultPostFormat = rawSettings.string(forKey: CodingKeys.defaultPostFormat.rawValue)
        }
        dateFormat = rawSettings.string(forKey: CodingKeys.dateFormat.rawValue)
        timeFormat = rawSettings.string(forKey: CodingKeys.timeFormat.rawValue)
        startOfWeek = rawSettings.string(forKey: CodingKeys.startOfWeek.rawValue)
        postsPerPage = rawSettings.number(forKey: CodingKeys.postsPerPage.rawValue)

        commentsAllowed = rawSettings.number(forKey: CodingKeys.commentsAllowed.rawValue)
        commentsBlocklistKeys = rawSettings.string(forKey: CodingKeys.commentsBlocklistKeys.rawValue)
        commentsCloseAutomatically = rawSettings.number(forKey: CodingKeys.commentsCloseAutomatically.rawValue)
        commentsCloseAutomaticallyAfterDays = rawSettings.number(forKey: CodingKeys.commentsCloseAutomaticallyAfterDays.rawValue)
        commentsFromKnownUsersAllowlisted = rawSettings.number(forKey: CodingKeys.commentsKnownUsersAllowlist.rawValue)
        commentsMaximumLinks = rawSettings.number(forKey: CodingKeys.commentsMaxLinks.rawValue)
        commentsModerationKeys = rawSettings.string(forKey: CodingKeys.commentsModerationKeys.rawValue)
        commentsPagingEnabled = rawSettings.number(forKey: CodingKeys.commentsPagingEnabled.rawValue)
        commentsPageSize = rawSettings.number(forKey: CodingKeys.commentsPageSize.rawValue)
        commentsRequireManualModeration = rawSettings.number(forKey: CodingKeys.commentsRequireModeration.rawValue)
        commentsRequireNameAndEmail = rawSettings.number(forKey: CodingKeys.commentsRequireNameAndEmail.rawValue)
        commentsRequireRegistration = rawSettings.number(forKey: CodingKeys.commentsRequireRegistration.rawValue)
        commentsSortOrder = rawSettings.string(forKey: CodingKeys.commentsSortOrder.rawValue)
        commentsThreadingEnabled = rawSettings.number(forKey: CodingKeys.commentsThreadingEnabled.rawValue)
        commentsThreadingDepth = rawSettings.number(forKey: CodingKeys.commentsThreadingDepth.rawValue)
        pingbackOutboundEnabled = rawSettings.number(forKey: CodingKeys.pingbackOutbound.rawValue)
        pingbackInboundEnabled = rawSettings.number(forKey: CodingKeys.pingbackInbound.rawValue)

        relatedPostsAllowed = rawSettings.number(forKey: CodingKeys.relatedPostsAllowed.rawValue)
        relatedPostsEnabled = rawSettings.number(forKey: CodingKeys.relatedPostsEnabled.rawValue)
        relatedPostsShowHeadline = rawSettings.number(forKey: CodingKeys.relatedPostsShowHeadline.rawValue)
        relatedPostsShowThumbnails = rawSettings.number(forKey: CodingKeys.relatedPostsShowThumbnails.rawValue)

        ampSupported = rawSettings.number(forKey: CodingKeys.ampSupported.rawValue)
        ampEnabled = rawSettings.number(forKey: CodingKeys.ampEnabled.rawValue)

        sharingButtonStyle = rawSettings.string(forKey: CodingKeys.sharingButtonStyle.rawValue)
        sharingLabel = rawSettings.string(forKey: CodingKeys.sharingLabel.rawValue)
        sharingTwitterName = rawSettings.string(forKey: CodingKeys.sharingTwitterName.rawValue)
        sharingCommentLikesEnabled = rawSettings.number(forKey: CodingKeys.sharingCommentLikesEnabled.rawValue)
        sharingDisabledLikes = rawSettings.number(forKey: CodingKeys.sharingDisabledLikes.rawValue)
        sharingDisabledReblogs = rawSettings.number(forKey: CodingKeys.sharingDisabledReblogs.rawValue)
    }

    // MARK: - Helpers

    /// Computed property, meant to help conversion from Remote / String-Based values, into their Integer counterparts
    ///
    @objc public var commentsSortOrderAscending: Bool {
        set {
            commentsSortOrder = newValue ? RemoteBlogSettings.AscendingStringValue :  RemoteBlogSettings.DescendingStringValue
        }
        get {
            return commentsSortOrder == RemoteBlogSettings.AscendingStringValue
        }
    }

    // MARK: - Private

    private static let AscendingStringValue     = "asc"
    private static let DescendingStringValue    = "desc"
}
