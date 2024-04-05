@testable import WordPressKit
import XCTest

// The aim of these tests is not to be comprehensive, but to help with migrating the decoding and encoding logic from Objective-C to Swift without regression.
// (The logic was originally part of BlogServiceRemoteREST).
// They remain in the suite after the conversion to Swift to prevent future regression and provide a ready made harness where to add more tests.
final class RemoteBlogSettingsTests: XCTestCase {

    func testInitWithJSON() throws {
        let json = try loadJSONSettings()
        let settings = RemoteBlogSettings(jsonDictionary: json as NSDictionary)

        // Root properties
        XCTAssertEqual(settings.name, "My Epic Blog")
        XCTAssertEqual(settings.tagline, "Definitely, the best blog out there")
        // Flattened settings properties
        XCTAssertEqual(settings.privacy, 1)
        XCTAssertEqual(settings.languageID, 31337)
        XCTAssertNil(settings.iconMediaID)
        XCTAssertEqual(settings.gmtOffset, 0)
        // And so on...

        // defaultPostFormat has custom decoding, so let's test it explicitly.
        // Note that here we're obviously testing only one of the possible paths.
        XCTAssertEqual(settings.defaultPostFormat, "standard")
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
