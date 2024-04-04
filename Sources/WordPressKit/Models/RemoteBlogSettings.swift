import Foundation
import NSObject_SafeExpectations

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

    /// Parses details from a JSON dictionary, as returned by the WordPress.com REST API.
    @objc
    public init(jsonDictionary json: NSDictionary) {
        let rawSettings = json.object(forKey: "settings") as? NSDictionary ?? [:]

        name = json.string(forKey: "name")
        tagline = json.string(forKey: "description")
        privacy = rawSettings.number(forKey: "blog_public")
        languageID = rawSettings.number(forKey: "lang_id")
        iconMediaID = rawSettings.number(forKey: "site_icon")
        gmtOffset = rawSettings.number(forKey: "gmt_offset")
        timezoneString = rawSettings.string(forKey: "timezone_string")

        defaultCategoryID = rawSettings.number(forKey: "default_category") ?? 1
        // Note: the backend might send '0' as a number, OR a string value.
        // See https://github.com/wordpress-mobile/WordPress-iOS/issues/4187
        let defaultPostFormatKey = "default_post_format"
        if let defaultPostFormatNumber = rawSettings.number(forKey: defaultPostFormatKey), defaultPostFormatNumber == 0 ||
            rawSettings.string(forKey: defaultPostFormatKey) == "0" {
            defaultPostFormat = "standard"
        } else {
            defaultPostFormat = rawSettings.string(forKey: defaultPostFormatKey)
        }
        dateFormat = rawSettings.string(forKey: "date_format")
        timeFormat = rawSettings.string(forKey: "time_format")
        startOfWeek = rawSettings.string(forKey: "start_of_week")
        postsPerPage = rawSettings.number(forKey: "posts_per_page")

        commentsAllowed = rawSettings.number(forKey: "default_comment_status")
        commentsBlocklistKeys = rawSettings.string(forKey: "blacklist_keys")
        commentsCloseAutomatically = rawSettings.number(forKey: "close_comments_for_old_posts")
        commentsCloseAutomaticallyAfterDays = rawSettings.number(forKey: "close_comments_days_old")
        commentsFromKnownUsersAllowlisted = rawSettings.number(forKey: "comment_whitelist")
        commentsMaximumLinks = rawSettings.number(forKey: "comment_max_links")
        commentsModerationKeys = rawSettings.string(forKey: "moderation_keys")
        commentsPagingEnabled = rawSettings.number(forKey: "page_comments")
        commentsPageSize = rawSettings.number(forKey: "comments_per_page")
        commentsRequireManualModeration = rawSettings.number(forKey: "comment_moderation")
        commentsRequireNameAndEmail = rawSettings.number(forKey: "require_name_email")
        commentsRequireRegistration = rawSettings.number(forKey: "comment_registration")
        commentsSortOrder = rawSettings.string(forKey: "comment_order")
        commentsThreadingEnabled = rawSettings.number(forKey: "thread_comments")
        commentsThreadingDepth = rawSettings.number(forKey: "thread_comments_depth")
        pingbackOutboundEnabled = rawSettings.number(forKey: "default_pingback_flag")
        pingbackInboundEnabled = rawSettings.number(forKey: "default_ping_status")

        relatedPostsAllowed = rawSettings.number(forKey: "jetpack_relatedposts_allowed")
        relatedPostsEnabled = rawSettings.number(forKey: "jetpack_relatedposts_enabled")
        relatedPostsShowHeadline = rawSettings.number(forKey: "jetpack_relatedposts_show_headline")
        relatedPostsShowThumbnails = rawSettings.number(forKey: "jetpack_relatedposts_show_thumbnails")

        ampSupported = rawSettings.number(forKey: "amp_is_supported")
        ampEnabled = rawSettings.number(forKey: "amp_is_enabled")

        sharingButtonStyle = rawSettings.string(forKey: "sharing_button_style")
        sharingLabel = rawSettings.string(forKey: "sharing_label")
        sharingTwitterName = rawSettings.string(forKey: "twitter_via")
        sharingCommentLikesEnabled = rawSettings.number(forKey: "jetpack_comment_likes_enabled")
        sharingDisabledLikes = rawSettings.number(forKey: "disabled_likes")
        sharingDisabledReblogs = rawSettings.number(forKey: "disabled_reblogs")
    }

    // MARK: - Private

    private static let AscendingStringValue     = "asc"
    private static let DescendingStringValue    = "desc"
}
