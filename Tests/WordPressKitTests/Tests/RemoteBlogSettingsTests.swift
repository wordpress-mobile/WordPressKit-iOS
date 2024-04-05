@testable import WordPressKit
import XCTest

final class RemoteBlogSettingsTests: XCTestCase {

    func testInitWithJSON() throws {
        let jsonPath = try XCTUnwrap(
            Bundle(for: type(of: self))
                .path(forResource: "rest-site-settings", ofType: "json")
        )
        let json = try XCTUnwrap(JSONLoader().loadFile(jsonPath))
        // FIXME: The init logic is currently in BlogServiceRemoteREST. We'll test it from there first, then update the test with the new location.
        let blogService = BlogServiceRemoteREST(wordPressComRestApi: MockWordPressComRestApi(), siteID: 0)
        let settings = try XCTUnwrap(blogService.remoteBlogSetting(fromJSONDictionary: json))

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
}
