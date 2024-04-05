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
        // FIXME: The init logic is currently in BlogServiceRemoteREST. We'll test it from there first, then update the test with the new location.
        let blogService = BlogServiceRemoteREST(wordPressComRestApi: MockWordPressComRestApi(), siteID: 0)
        let settings = try XCTUnwrap(blogService.remoteBlogSetting(fromJSONDictionary: json))

        let dictionary = try XCTUnwrap(blogService.remoteSettings(toDictionary: settings))

        // name and tagline have different keys when encoded...
        XCTAssertEqual(dictionary["blogname"] as? String, settings.name) // from JSON this is "name"
        XCTAssertEqual(dictionary["blogdescription"] as? String, settings.tagline) // from JSON this is "description"
        // Flattened settings properties
        XCTAssertEqual(dictionary["blog_public"] as? NSNumber, settings.privacy)
        XCTAssertEqual(dictionary["lang_id"] as? NSNumber, settings.languageID)
        XCTAssertEqual(dictionary["site_icon"] as? NSNumber, settings.iconMediaID)
        XCTAssertEqual(dictionary["gmt_offset"] as? NSNumber, settings.gmtOffset)
        // And so on...

        // defaultPostFormat has custom encoding, so let's test it explicitly.
        // Note that here we're obviously testing only one of the possible paths.
        XCTAssertEqual(dictionary["default_post_format"] as? String, settings.defaultPostFormat)
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
