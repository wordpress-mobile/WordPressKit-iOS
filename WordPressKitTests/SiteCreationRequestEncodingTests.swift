
import XCTest
@testable import WordPressKit

class SiteCreationRequestEncodingTests: XCTestCase {

    func testSiteCreationRequestEncoding_WithAllParameters_IsSuccessful() {
        // Given
        let request = SiteCreationRequest(
            segmentIdentifier: 1,
            verticalIdentifier: "p2v10",
            title: "Come on in",
            tagline: "This is a site I like",
            siteURLString: "Cool Restaurant",
            isPublic: true,
            languageIdentifier: "TEST-ENGLISH",
            shouldValidate: true,
            clientIdentifier: "TEST-ID",
            clientSecret: "TEST-SECRET"
        )

        // When
        let encoder = JSONEncoder()

        XCTAssertNoThrow(try encoder.encode(request))
        let encodedJSON = try! encoder.encode(request)

        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: encodedJSON, options: []))
        let serializedJSON = try! JSONSerialization.jsonObject(with: encodedJSON, options: [])

        if let _ = serializedJSON as? [String : AnyObject] {} else {
            XCTFail("Failed to encode a proper JSON dictionary!")
        }
        let jsonDictionary = serializedJSON as! [String : AnyObject]

        // Then
        XCTAssertNotNil(jsonDictionary["blog_name"])
        XCTAssertNotNil(jsonDictionary["blog_title"])
        XCTAssertNotNil(jsonDictionary["client_id"])
        XCTAssertNotNil(jsonDictionary["client_secret"])
        XCTAssertNotNil(jsonDictionary["public"])
        XCTAssertNotNil(jsonDictionary["lang_id"])
        XCTAssertNotNil(jsonDictionary["options"])
        XCTAssertNotNil(jsonDictionary["validate"])
    }

    func testSiteCreationRequestEncoding_WorksWithPrivate() {
        // Given
        let request = SiteCreationRequest(
            segmentIdentifier: 1,
            verticalIdentifier: "p2v10",
            title: "Come on in",
            tagline: "This is a site I like",
            siteURLString: "Cool Restaurant",
            isPublic: false,
            languageIdentifier: "TEST-ENGLISH",
            shouldValidate: true,
            clientIdentifier: "TEST-ID",
            clientSecret: "TEST-SECRET"
        )

        // When
        let encoder = JSONEncoder()

        XCTAssertNoThrow(try encoder.encode(request))
        let encodedJSON = try! encoder.encode(request)

        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: encodedJSON, options: []))
        let serializedJSON = try! JSONSerialization.jsonObject(with: encodedJSON, options: [])

        if let _ = serializedJSON as? [String : AnyObject] {} else {
            XCTFail("Failed to encode a proper JSON dictionary!")
        }
        let jsonDictionary = serializedJSON as! [String : AnyObject]

        // Then
        XCTAssertNotNil(jsonDictionary["blog_name"])
        XCTAssertNotNil(jsonDictionary["blog_title"])
        XCTAssertNotNil(jsonDictionary["client_id"])
        XCTAssertNotNil(jsonDictionary["client_secret"])
        XCTAssertNotNil(jsonDictionary["public"])
        XCTAssertNotNil(jsonDictionary["lang_id"])
        XCTAssertNotNil(jsonDictionary["options"])
        XCTAssertNotNil(jsonDictionary["validate"])
    }

    func testSiteCreationRequestEncoding_WorksWithoutValidation() {
        // Given
        let request = SiteCreationRequest(
            segmentIdentifier: 1,
            verticalIdentifier: "p2v10",
            title: "Come on in",
            tagline: "This is a site I like",
            siteURLString: "Cool Restaurant",
            isPublic: true,
            languageIdentifier: "TEST-ENGLISH",
            shouldValidate: false,
            clientIdentifier: "TEST-ID",
            clientSecret: "TEST-SECRET"
        )

        // When
        let encoder = JSONEncoder()

        XCTAssertNoThrow(try encoder.encode(request))
        let encodedJSON = try! encoder.encode(request)

        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: encodedJSON, options: []))
        let serializedJSON = try! JSONSerialization.jsonObject(with: encodedJSON, options: [])

        if let _ = serializedJSON as? [String : AnyObject] {} else {
            XCTFail("Failed to encode a proper JSON dictionary!")
        }
        let jsonDictionary = serializedJSON as! [String : AnyObject]

        // Then
        XCTAssertNotNil(jsonDictionary["blog_name"])
        XCTAssertNotNil(jsonDictionary["blog_title"])
        XCTAssertNotNil(jsonDictionary["client_id"])
        XCTAssertNotNil(jsonDictionary["client_secret"])
        XCTAssertNotNil(jsonDictionary["public"])
        XCTAssertNotNil(jsonDictionary["lang_id"])
        XCTAssertNotNil(jsonDictionary["options"])
        XCTAssertNotNil(jsonDictionary["validate"])
    }

    func testSiteCreationRequestEncoding_WorksSansVertical() {
        // Given
        let request = SiteCreationRequest(
            segmentIdentifier: 1,
            verticalIdentifier: nil,
            title: "Come on in",
            tagline: "This is a site I like",
            siteURLString: "Cool Restaurant",
            isPublic: true,
            languageIdentifier: "TEST-ENGLISH",
            shouldValidate: false,
            clientIdentifier: "TEST-ID",
            clientSecret: "TEST-SECRET"
        )

        // When
        let encoder = JSONEncoder()

        XCTAssertNoThrow(try encoder.encode(request))
        let encodedJSON = try! encoder.encode(request)

        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: encodedJSON, options: []))
        let serializedJSON = try! JSONSerialization.jsonObject(with: encodedJSON, options: [])

        if let _ = serializedJSON as? [String : AnyObject] {} else {
            XCTFail("Failed to encode a proper JSON dictionary!")
        }
        let jsonDictionary = serializedJSON as! [String : AnyObject]

        // Then
        XCTAssertNotNil(jsonDictionary["blog_name"])
        XCTAssertNotNil(jsonDictionary["blog_title"])
        XCTAssertNotNil(jsonDictionary["client_id"])
        XCTAssertNotNil(jsonDictionary["client_secret"])
        XCTAssertNotNil(jsonDictionary["public"])
        XCTAssertNotNil(jsonDictionary["lang_id"])
        XCTAssertNotNil(jsonDictionary["options"])
        XCTAssertNotNil(jsonDictionary["validate"])
    }

    func testSiteCreationRequestEncoding_WorksSansTagline() {
        // Given
        let request = SiteCreationRequest(
            segmentIdentifier: 1,
            verticalIdentifier: "p2v10",
            title: "Come on in",
            tagline: nil,
            siteURLString: "Cool Restaurant",
            isPublic: true,
            languageIdentifier: "TEST-ENGLISH",
            shouldValidate: false,
            clientIdentifier: "TEST-ID",
            clientSecret: "TEST-SECRET"
        )

        // When
        let encoder = JSONEncoder()

        XCTAssertNoThrow(try encoder.encode(request))
        let encodedJSON = try! encoder.encode(request)

        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: encodedJSON, options: []))
        let serializedJSON = try! JSONSerialization.jsonObject(with: encodedJSON, options: [])

        if let _ = serializedJSON as? [String : AnyObject] {} else {
            XCTFail("Failed to encode a proper JSON dictionary!")
        }
        let jsonDictionary = serializedJSON as! [String : AnyObject]

        // Then
        XCTAssertNotNil(jsonDictionary["blog_name"])
        XCTAssertNotNil(jsonDictionary["blog_title"])
        XCTAssertNotNil(jsonDictionary["client_id"])
        XCTAssertNotNil(jsonDictionary["client_secret"])
        XCTAssertNotNil(jsonDictionary["public"])
        XCTAssertNotNil(jsonDictionary["lang_id"])
        XCTAssertNotNil(jsonDictionary["options"])
        XCTAssertNotNil(jsonDictionary["validate"])
    }
}
