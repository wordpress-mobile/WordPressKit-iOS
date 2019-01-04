
import XCTest
@testable import WordPressKit

class SiteCreationRequestEncodingTests: XCTestCase {

    func testSiteCreationRequestEncoding_WithAllParameters_IsSuccessful() {
        // Given
        let expectedSegmentId = Int64(1)
        let expectedVerticalId = "p2v10"
        let expectedBlogTitle = "Come on in"
        let expectedTagline = "This is a site I like"
        let expectedBlogName = "Cool Restaurant"
        let expectedPublicValue = true
        let expectedLanguageId = "TEST-ENGLISH"
        let expectedValidateValue = true
        let expectedClientId = "TEST-ID"
        let expectedClientSecret = "TEST-SECRET"

        let request = SiteCreationRequest(
            segmentIdentifier: expectedSegmentId,
            verticalIdentifier: expectedVerticalId,
            title: expectedBlogTitle,
            tagline: expectedTagline,
            siteURLString: expectedBlogName,
            isPublic: expectedPublicValue,
            languageIdentifier: expectedLanguageId,
            shouldValidate: expectedValidateValue,
            clientIdentifier: expectedClientId,
            clientSecret: expectedClientSecret
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
        let actualBlogName = jsonDictionary["blog_name"] as? String
        XCTAssertNotNil(actualBlogName)
        XCTAssertEqual(expectedBlogName, actualBlogName!)

        let actualBlogTitle = jsonDictionary["blog_title"] as? String
        XCTAssertNotNil(actualBlogTitle)
        XCTAssertEqual(expectedBlogTitle, actualBlogTitle!)

        let actualClientId = jsonDictionary["client_id"] as? String
        XCTAssertNotNil(actualClientId)
        XCTAssertEqual(expectedClientId, actualClientId!)

        let actualClientSecret = jsonDictionary["client_secret"] as? String
        XCTAssertNotNil(actualClientSecret)
        XCTAssertEqual(expectedClientSecret, actualClientSecret!)

        let actualPublicValue = jsonDictionary["public"] as? Bool
        XCTAssertNotNil(actualPublicValue)
        XCTAssertEqual(expectedPublicValue, actualPublicValue!)

        let actualLanguageId = jsonDictionary["lang_id"] as? String
        XCTAssertNotNil(actualLanguageId)

        let actualValidateValue = jsonDictionary["validate"] as? Bool
        XCTAssertNotNil(actualValidateValue)

        let actualOptions = jsonDictionary["options"] as? [String : AnyObject]
        XCTAssertNotNil(actualOptions)

        let actualSegmentId = actualOptions!["site_segment"] as? Int64
        XCTAssertNotNil(actualSegmentId)
        XCTAssertEqual(expectedSegmentId, actualSegmentId!)

        let actualVerticalId = actualOptions!["site_vertical"] as? String
        XCTAssertNotNil(actualVerticalId)
        XCTAssertEqual(expectedVerticalId, actualVerticalId!)

        let actualSiteInfo = actualOptions!["site_information"] as? [String : AnyObject]
        XCTAssertNotNil(actualSiteInfo)

        let actualTagline = actualSiteInfo!["site_tagline"] as? String
        XCTAssertNotNil(actualTagline)
        XCTAssertEqual(expectedTagline, actualTagline!)
    }

    func testSiteCreationRequestEncoding_WorksWithPrivate() {
        // Given
        let expectedSegmentId = Int64(1)
        let expectedVerticalId = "p2v10"
        let expectedBlogTitle = "Come on in"
        let expectedTagline = "This is a site I like"
        let expectedBlogName = "Cool Restaurant"
        let expectedPublicValue = false
        let expectedLanguageId = "TEST-ENGLISH"
        let expectedValidateValue = true
        let expectedClientId = "TEST-ID"
        let expectedClientSecret = "TEST-SECRET"

        let request = SiteCreationRequest(
            segmentIdentifier: expectedSegmentId,
            verticalIdentifier: expectedVerticalId,
            title: expectedBlogTitle,
            tagline: expectedTagline,
            siteURLString: expectedBlogName,
            isPublic: expectedPublicValue,
            languageIdentifier: expectedLanguageId,
            shouldValidate: expectedValidateValue,
            clientIdentifier: expectedClientId,
            clientSecret: expectedClientSecret
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
        let actualBlogName = jsonDictionary["blog_name"] as? String
        XCTAssertNotNil(actualBlogName)
        XCTAssertEqual(expectedBlogName, actualBlogName!)

        let actualBlogTitle = jsonDictionary["blog_title"] as? String
        XCTAssertNotNil(actualBlogTitle)
        XCTAssertEqual(expectedBlogTitle, actualBlogTitle!)

        let actualClientId = jsonDictionary["client_id"] as? String
        XCTAssertNotNil(actualClientId)
        XCTAssertEqual(expectedClientId, actualClientId!)

        let actualClientSecret = jsonDictionary["client_secret"] as? String
        XCTAssertNotNil(actualClientSecret)
        XCTAssertEqual(expectedClientSecret, actualClientSecret!)

        let actualPublicValue = jsonDictionary["public"] as? Bool
        XCTAssertNotNil(actualPublicValue)
        XCTAssertEqual(expectedPublicValue, actualPublicValue!)

        let actualLanguageId = jsonDictionary["lang_id"] as? String
        XCTAssertNotNil(actualLanguageId)

        let actualValidateValue = jsonDictionary["validate"] as? Bool
        XCTAssertNotNil(actualValidateValue)

        let actualOptions = jsonDictionary["options"] as? [String : AnyObject]
        XCTAssertNotNil(actualOptions)

        let actualSegmentId = actualOptions!["site_segment"] as? Int64
        XCTAssertNotNil(actualSegmentId)
        XCTAssertEqual(expectedSegmentId, actualSegmentId!)

        let actualVerticalId = actualOptions!["site_vertical"] as? String
        XCTAssertNotNil(actualVerticalId)
        XCTAssertEqual(expectedVerticalId, actualVerticalId!)

        let actualSiteInfo = actualOptions!["site_information"] as? [String : AnyObject]
        XCTAssertNotNil(actualSiteInfo)

        let actualTagline = actualSiteInfo!["site_tagline"] as? String
        XCTAssertNotNil(actualTagline)
        XCTAssertEqual(expectedTagline, actualTagline!)
    }

    func testSiteCreationRequestEncoding_WorksWithValidate_SetToFalse() {
        // Given
        let expectedSegmentId = Int64(1)
        let expectedVerticalId = "p2v10"
        let expectedBlogTitle = "Come on in"
        let expectedTagline = "This is a site I like"
        let expectedBlogName = "Cool Restaurant"
        let expectedPublicValue = true
        let expectedLanguageId = "TEST-ENGLISH"
        let expectedValidateValue = false
        let expectedClientId = "TEST-ID"
        let expectedClientSecret = "TEST-SECRET"

        let request = SiteCreationRequest(
            segmentIdentifier: expectedSegmentId,
            verticalIdentifier: expectedVerticalId,
            title: expectedBlogTitle,
            tagline: expectedTagline,
            siteURLString: expectedBlogName,
            isPublic: expectedPublicValue,
            languageIdentifier: expectedLanguageId,
            shouldValidate: expectedValidateValue,
            clientIdentifier: expectedClientId,
            clientSecret: expectedClientSecret
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
        let actualBlogName = jsonDictionary["blog_name"] as? String
        XCTAssertNotNil(actualBlogName)
        XCTAssertEqual(expectedBlogName, actualBlogName!)

        let actualBlogTitle = jsonDictionary["blog_title"] as? String
        XCTAssertNotNil(actualBlogTitle)
        XCTAssertEqual(expectedBlogTitle, actualBlogTitle!)

        let actualClientId = jsonDictionary["client_id"] as? String
        XCTAssertNotNil(actualClientId)
        XCTAssertEqual(expectedClientId, actualClientId!)

        let actualClientSecret = jsonDictionary["client_secret"] as? String
        XCTAssertNotNil(actualClientSecret)
        XCTAssertEqual(expectedClientSecret, actualClientSecret!)

        let actualPublicValue = jsonDictionary["public"] as? Bool
        XCTAssertNotNil(actualPublicValue)
        XCTAssertEqual(expectedPublicValue, actualPublicValue!)

        let actualLanguageId = jsonDictionary["lang_id"] as? String
        XCTAssertNotNil(actualLanguageId)

        let actualValidateValue = jsonDictionary["validate"] as? Bool
        XCTAssertNotNil(actualValidateValue)

        let actualOptions = jsonDictionary["options"] as? [String : AnyObject]
        XCTAssertNotNil(actualOptions)

        let actualSegmentId = actualOptions!["site_segment"] as? Int64
        XCTAssertNotNil(actualSegmentId)
        XCTAssertEqual(expectedSegmentId, actualSegmentId!)

        let actualVerticalId = actualOptions!["site_vertical"] as? String
        XCTAssertNotNil(actualVerticalId)
        XCTAssertEqual(expectedVerticalId, actualVerticalId!)

        let actualSiteInfo = actualOptions!["site_information"] as? [String : AnyObject]
        XCTAssertNotNil(actualSiteInfo)

        let actualTagline = actualSiteInfo!["site_tagline"] as? String
        XCTAssertNotNil(actualTagline)
        XCTAssertEqual(expectedTagline, actualTagline!)
    }

    func testSiteCreationRequestEncoding_WorksWithoutVertical() {
        // Given
        let expectedSegmentId = Int64(1)
        let expectedVerticalId: String? = nil
        let expectedBlogTitle = "Come on in"
        let expectedTagline = "This is a site I like"
        let expectedBlogName = "Cool Restaurant"
        let expectedPublicValue = true
        let expectedLanguageId = "TEST-ENGLISH"
        let expectedValidateValue = true
        let expectedClientId = "TEST-ID"
        let expectedClientSecret = "TEST-SECRET"

        let request = SiteCreationRequest(
            segmentIdentifier: expectedSegmentId,
            verticalIdentifier: expectedVerticalId,
            title: expectedBlogTitle,
            tagline: expectedTagline,
            siteURLString: expectedBlogName,
            isPublic: expectedPublicValue,
            languageIdentifier: expectedLanguageId,
            shouldValidate: expectedValidateValue,
            clientIdentifier: expectedClientId,
            clientSecret: expectedClientSecret
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
        let actualBlogName = jsonDictionary["blog_name"] as? String
        XCTAssertNotNil(actualBlogName)
        XCTAssertEqual(expectedBlogName, actualBlogName!)

        let actualBlogTitle = jsonDictionary["blog_title"] as? String
        XCTAssertNotNil(actualBlogTitle)
        XCTAssertEqual(expectedBlogTitle, actualBlogTitle!)

        let actualClientId = jsonDictionary["client_id"] as? String
        XCTAssertNotNil(actualClientId)
        XCTAssertEqual(expectedClientId, actualClientId!)

        let actualClientSecret = jsonDictionary["client_secret"] as? String
        XCTAssertNotNil(actualClientSecret)
        XCTAssertEqual(expectedClientSecret, actualClientSecret!)

        let actualPublicValue = jsonDictionary["public"] as? Bool
        XCTAssertNotNil(actualPublicValue)
        XCTAssertEqual(expectedPublicValue, actualPublicValue!)

        let actualLanguageId = jsonDictionary["lang_id"] as? String
        XCTAssertNotNil(actualLanguageId)

        let actualValidateValue = jsonDictionary["validate"] as? Bool
        XCTAssertNotNil(actualValidateValue)

        let actualOptions = jsonDictionary["options"] as? [String : AnyObject]
        XCTAssertNotNil(actualOptions)

        let actualSegmentId = actualOptions!["site_segment"] as? Int64
        XCTAssertNotNil(actualSegmentId)
        XCTAssertEqual(expectedSegmentId, actualSegmentId!)

        let actualVerticalId = actualOptions!["site_vertical"] as? String
        XCTAssertNil(actualVerticalId)

        let actualSiteInfo = actualOptions!["site_information"] as? [String : AnyObject]
        XCTAssertNotNil(actualSiteInfo)

        let actualTagline = actualSiteInfo!["site_tagline"] as? String
        XCTAssertNotNil(actualTagline)
        XCTAssertEqual(expectedTagline, actualTagline!)
    }

    func testSiteCreationRequestEncoding_WorksWithoutTagline() {
        // Given
        let expectedSegmentId = Int64(1)
        let expectedVerticalId = "p2v10"
        let expectedBlogTitle = "Come on in"
        let expectedTagline: String? = nil
        let expectedBlogName = "Cool Restaurant"
        let expectedPublicValue = true
        let expectedLanguageId = "TEST-ENGLISH"
        let expectedValidateValue = true
        let expectedClientId = "TEST-ID"
        let expectedClientSecret = "TEST-SECRET"

        let request = SiteCreationRequest(
            segmentIdentifier: expectedSegmentId,
            verticalIdentifier: expectedVerticalId,
            title: expectedBlogTitle,
            tagline: expectedTagline,
            siteURLString: expectedBlogName,
            isPublic: expectedPublicValue,
            languageIdentifier: expectedLanguageId,
            shouldValidate: expectedValidateValue,
            clientIdentifier: expectedClientId,
            clientSecret: expectedClientSecret
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
        let actualBlogName = jsonDictionary["blog_name"] as? String
        XCTAssertNotNil(actualBlogName)
        XCTAssertEqual(expectedBlogName, actualBlogName!)

        let actualBlogTitle = jsonDictionary["blog_title"] as? String
        XCTAssertNotNil(actualBlogTitle)
        XCTAssertEqual(expectedBlogTitle, actualBlogTitle!)

        let actualClientId = jsonDictionary["client_id"] as? String
        XCTAssertNotNil(actualClientId)
        XCTAssertEqual(expectedClientId, actualClientId!)

        let actualClientSecret = jsonDictionary["client_secret"] as? String
        XCTAssertNotNil(actualClientSecret)
        XCTAssertEqual(expectedClientSecret, actualClientSecret!)

        let actualPublicValue = jsonDictionary["public"] as? Bool
        XCTAssertNotNil(actualPublicValue)
        XCTAssertEqual(expectedPublicValue, actualPublicValue!)

        let actualLanguageId = jsonDictionary["lang_id"] as? String
        XCTAssertNotNil(actualLanguageId)

        let actualValidateValue = jsonDictionary["validate"] as? Bool
        XCTAssertNotNil(actualValidateValue)

        let actualOptions = jsonDictionary["options"] as? [String : AnyObject]
        XCTAssertNotNil(actualOptions)

        let actualSegmentId = actualOptions!["site_segment"] as? Int64
        XCTAssertNotNil(actualSegmentId)
        XCTAssertEqual(expectedSegmentId, actualSegmentId!)

        let actualVerticalId = actualOptions!["site_vertical"] as? String
        XCTAssertNotNil(actualVerticalId)
        XCTAssertEqual(expectedVerticalId, actualVerticalId!)

        let actualSiteInfo = actualOptions!["site_information"] as? [String : AnyObject]
        XCTAssertNil(actualSiteInfo)
    }
}
