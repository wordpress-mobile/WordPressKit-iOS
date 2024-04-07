@testable import WordPressKit
import XCTest

// The aim of these tests is not to be comprehensive, but to help with migrating the decoding and encoding logic from Objective-C to Swift without regression.
// (The logic was originally part of BlogServiceRemoteREST).
// They remain in the suite after the conversion to Swift to prevent future regression and provide a ready made harness where to add more tests.
final class RemoteBlogSettingsTests: XCTestCase {

    func testInitWithJSON() throws {
        let json = try loadJSONSettings()
        let settings = RemoteBlogSettings(jsonDictionary: json as NSDictionary)

        XCTAssertEqual(settings.name, "My Epic Blog")
        XCTAssertEqual(settings.tagline, "Definitely, the best blog out there")
        XCTAssertEqual(settings.privacy, 1)
        XCTAssertEqual(settings.languageID, 31337)
        XCTAssertNil(settings.iconMediaID)
        XCTAssertEqual(settings.gmtOffset, 0)
        XCTAssertEqual(settings.timezoneString, "")
        XCTAssertEqual(settings.defaultCategoryID, 8)
        // [!] This is the only property with custom decoding.
        // It would be appropriate to add additional tests to check all its paths.
        XCTAssertEqual(settings.defaultPostFormat, "standard")
        XCTAssertEqual(settings.dateFormat, "m/d/Y")
        XCTAssertEqual(settings.timeFormat, "g:i a")
        XCTAssertEqual(settings.startOfWeek, "0")
        XCTAssertEqual(settings.postsPerPage, 12)
        XCTAssertEqual(settings.commentsAllowed, true)
        XCTAssertEqual(settings.commentsBlocklistKeys, "some evil keywords")
        XCTAssertEqual(settings.commentsCloseAutomatically, false)
        XCTAssertEqual(settings.commentsCloseAutomaticallyAfterDays, 3000)
        XCTAssertEqual(settings.commentsFromKnownUsersAllowlisted, true)
        XCTAssertEqual(settings.commentsMaximumLinks, 42)
        XCTAssertEqual(settings.commentsModerationKeys, "moderation keys")
        XCTAssertEqual(settings.commentsPagingEnabled, true)
        XCTAssertEqual(settings.commentsPageSize, 5)
        XCTAssertEqual(settings.commentsRequireManualModeration, true)
        XCTAssertEqual(settings.commentsRequireNameAndEmail, false)
        XCTAssertEqual(settings.commentsRequireRegistration, true)
        XCTAssertEqual(settings.commentsSortOrder, "desc")
        XCTAssertEqual(settings.commentsThreadingDepth, 5)
        XCTAssertEqual(settings.commentsThreadingEnabled, true)
        XCTAssertEqual(settings.pingbackInboundEnabled, true)
        XCTAssertEqual(settings.pingbackOutboundEnabled, true)
        XCTAssertEqual(settings.relatedPostsAllowed, true)
        XCTAssertEqual(settings.relatedPostsEnabled, false)
        XCTAssertEqual(settings.relatedPostsShowHeadline, true)
        XCTAssertEqual(settings.relatedPostsShowThumbnails, false)
        XCTAssertEqual(settings.ampSupported, true)
        XCTAssertEqual(settings.ampEnabled, false)
        XCTAssertEqual(settings.sharingButtonStyle, "icon-text")
        XCTAssertEqual(settings.sharingLabel, "Share this:")
        XCTAssertEqual(settings.sharingTwitterName, "gcorne")
        XCTAssertEqual(settings.sharingCommentLikesEnabled, true)
        XCTAssertEqual(settings.sharingDisabledLikes, false)
        XCTAssertEqual(settings.sharingDisabledReblogs, false)
    }

    func testToDictionary() throws {
        // Rather than creating an object and checking the resulting NSDictionary,
        // let's load one, convert it, then compare the source and converted dictionaries
        let json = try loadJSONSettings()
        let settings = try XCTUnwrap(RemoteBlogSettings(jsonDictionary: json as NSDictionary))

        let dictionary = try XCTUnwrap(settings.dictionaryRepresentation)

        // defaultPostFormat has custom encoding, so let's test it explicitly.
        // Note that here we're obviously testing only one of the possible paths.
        XCTAssertEqual(dictionary["default_post_format"] as? String, settings.defaultPostFormat)

        XCTAssertEqual(dictionary["blogname"] as? String, settings.name) // "name" in JSON
        XCTAssertEqual(dictionary["blogdescription"] as? String, settings.tagline) // "description" in JSON
        XCTAssertEqual(dictionary["blog_public"] as? NSNumber, settings.privacy)
        XCTAssertEqual(dictionary["lang_id"] as? NSNumber, settings.languageID)
        XCTAssertEqual(dictionary["site_icon"] as? NSNumber, settings.iconMediaID)
        XCTAssertEqual(dictionary["gmt_offset"] as? NSNumber, settings.gmtOffset)
        XCTAssertEqual(dictionary["timezone_string"] as? String, settings.timezoneString)
        XCTAssertEqual(dictionary["default_category"] as? NSNumber, settings.defaultCategoryID)

        // defaultPostFormat has custom encoding, so let's test it explicitly.
        // Note that here we're obviously testing only one of the possible paths.
        XCTAssertEqual(dictionary["default_post_format"] as? String, settings.defaultPostFormat)

        XCTAssertEqual(dictionary["date_format"] as? String, settings.dateFormat)
        XCTAssertEqual(dictionary["time_format"] as? String, settings.timeFormat)
        XCTAssertEqual(dictionary["start_of_week"] as? String, settings.startOfWeek)
        XCTAssertEqual(dictionary["posts_per_page"] as? NSNumber, settings.postsPerPage)
        XCTAssertEqual(dictionary["default_comment_status"] as? NSNumber, settings.commentsAllowed)
        XCTAssertEqual(dictionary["blacklist_keys"] as? String, settings.commentsBlocklistKeys)
        XCTAssertEqual(dictionary["close_comments_for_old_posts"] as? NSNumber, settings.commentsCloseAutomatically)
        XCTAssertEqual(dictionary["close_comments_days_old"] as? NSNumber, settings.commentsCloseAutomaticallyAfterDays)
        XCTAssertEqual(dictionary["comment_whitelist"] as? NSNumber, settings.commentsFromKnownUsersAllowlisted)
        XCTAssertEqual(dictionary["comment_max_links"] as? NSNumber, settings.commentsMaximumLinks)
        XCTAssertEqual(dictionary["moderation_keys"] as? String, settings.commentsModerationKeys)
        XCTAssertEqual(dictionary["page_comments"] as? NSNumber, settings.commentsPagingEnabled)
        XCTAssertEqual(dictionary["comments_per_page"] as? NSNumber, settings.commentsPageSize)
        XCTAssertEqual(dictionary["comment_moderation"] as? NSNumber, settings.commentsRequireManualModeration)
        XCTAssertEqual(dictionary["require_name_email"] as? NSNumber, settings.commentsRequireNameAndEmail)
        XCTAssertEqual(dictionary["comment_registration"] as? NSNumber, settings.commentsRequireRegistration)
        XCTAssertEqual(dictionary["comment_order"] as? String, settings.commentsSortOrder)
        XCTAssertEqual(dictionary["thread_comments"] as? NSNumber, settings.commentsThreadingEnabled)
        XCTAssertEqual(dictionary["thread_comments_depth"] as? NSNumber, settings.commentsThreadingDepth)
        XCTAssertEqual(dictionary["jetpack_relatedposts_allowed"] as? NSNumber, settings.relatedPostsAllowed)
        XCTAssertEqual(dictionary["jetpack_relatedposts_enabled"] as? NSNumber, settings.relatedPostsEnabled)
        XCTAssertEqual(dictionary["jetpack_relatedposts_show_headline"] as? NSNumber, settings.relatedPostsShowHeadline)
        XCTAssertEqual(dictionary["jetpack_relatedposts_show_thumbnails"] as? NSNumber, settings.relatedPostsShowThumbnails)
        XCTAssertEqual(dictionary["amp_is_supported"] as? NSNumber, settings.ampSupported)
        XCTAssertEqual(dictionary["amp_is_enabled"] as? NSNumber, settings.ampEnabled)
        XCTAssertEqual(dictionary["sharing_button_style"] as? String, settings.sharingButtonStyle)
        XCTAssertEqual(dictionary["sharing_label"] as? String, settings.sharingLabel)
        XCTAssertEqual(dictionary["twitter_via"] as? String, settings.sharingTwitterName)
        XCTAssertEqual(dictionary["jetpack_comment_likes_enabled"] as? NSNumber, settings.sharingCommentLikesEnabled)
        XCTAssertEqual(dictionary["disabled_likes"] as? NSNumber, settings.sharingDisabledLikes)
        XCTAssertEqual(dictionary["disabled_reblogs"] as? NSNumber, settings.sharingDisabledReblogs)
    }

    func loadJSONSettings() throws -> [String: Any] {
        let jsonPath = try XCTUnwrap(
            Bundle(for: type(of: self))
                .path(forResource: "rest-site-settings", ofType: "json")
        )
        let json = try XCTUnwrap(JSONLoader().loadFile(jsonPath))
        return json
    }
}
