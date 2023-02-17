import XCTest

@testable import WordPressKit

class NewRemoteReaderPostTests: XCTestCase {

    func testParsingEmptyTags() throws {
        // REST API returns an empty _array_ if there is no tags associated with the post.
        let jsonString = """
        {
            "tags": []
        }
        """
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!) as? NSDictionary)
        XCTAssertEqual(RemoteReaderPost.tags(fromPostDictionary: json), "")
    }

    func testParsingTags() throws {
        let jsonString = """
        {
            "tags": {
              "another-random-art-tag": {
                "ID": 1,
                "name": "another-random-art-tag",
                "slug": "another-random-art-tag",
                "description": "",
                "post_count": 1,
                "meta": {
                  "links": {
                  }
                },
                "display_name": "another-random-art-tag"
              },
              "random-art-tag": {
                "ID": 2,
                "name": "random-art-tag",
                "slug": "random-art-tag",
                "description": "",
                "post_count": 1,
                "meta": {
                  "links": {
                  }
                },
                "display_name": "random-art-tag"
              }
            }
        }
        """
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!) as? NSDictionary)
        let tags = RemoteReaderPost.tags(fromPostDictionary: json)
        XCTAssertTrue(
            tags == "random-art-tag, another-random-art-tag"
                || tags == "another-random-art-tag, random-art-tag"
        )
    }

}
