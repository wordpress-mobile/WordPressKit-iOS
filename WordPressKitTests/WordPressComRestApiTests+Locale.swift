import Foundation
import XCTest
import OHHTTPStubs

import WordPressShared
@testable import WordPressKit

extension WordPressComRestApiTests {

    func testThatAppendingLocaleWorks() async throws {
        var request: URLRequest?
        stub(condition: { _ in true }, response: {
            request = $0
            return HTTPStubsResponse(error: URLError(.networkConnectionLost))
        })

        let api = WordPressComRestApi()
        let _ = await api.perform(.get, URLString: "/path/path")

        let preferredLanguageIdentifier = WordPressComLanguageDatabase().deviceLanguage.slug
        try XCTAssertTrue(XCTUnwrap(request?.url?.query).contains("locale=\(preferredLanguageIdentifier)"))
    }

    func testThatAppendingLocaleWorksWithExistingParams() async {
        var request: URLRequest?
        stub(condition: { _ in true }, response: {
            request = $0
            return HTTPStubsResponse(error: URLError(.networkConnectionLost))
        })

        let path = "/path/path"
        let params: [String: AnyObject] = [
            "someKey": "value" as AnyObject
        ]

        let api = WordPressComRestApi()
        let _ = await api.perform(.get, URLString: path, parameters: params)

        let preferredLanguageIdentifier = WordPressComLanguageDatabase().deviceLanguage.slug
        try XCTAssertTrue(XCTUnwrap(request?.url?.query).contains("locale=\(preferredLanguageIdentifier)"))
        try XCTAssertTrue(XCTUnwrap(request?.url?.query).contains("someKey=value"))
    }

    func testThatLocaleIsNotAppendedIfAlreadyIncludedInPath() async {
        var request: URLRequest?
        stub(condition: { _ in true }, response: {
            request = $0
            return HTTPStubsResponse(error: URLError(.networkConnectionLost))
        })

        let api = WordPressComRestApi()
        let _ = await api.perform(.get, URLString: "/path?locale=foo")

        try XCTAssertEqual(XCTUnwrap(request?.url?.query), "locale=foo")
    }

    func testThatAppendingLocaleIgnoresIfAlreadyIncludedInRequestParameters() async throws {
        var request: URLRequest?
        stub(condition: { _ in true }, response: {
            request = $0
            return HTTPStubsResponse(error: URLError(.networkConnectionLost))
        })

        let api = WordPressComRestApi()
        let _ = await api.perform(.get, URLString: "/path", parameters: ["locale": "foo"] as [String: AnyObject])

        try XCTAssertEqual(XCTUnwrap(request?.url?.query), "locale=foo")
    }

    func testThatLocaleIsNotAppendedWhenDisabled() async {
        var request: URLRequest?
        stub(condition: { _ in true }, response: {
            request = $0
            return HTTPStubsResponse(error: URLError(.networkConnectionLost))
        })

        let api = WordPressComRestApi()
        api.appendsPreferredLanguageLocale = false
        let _ = await api.perform(.get, URLString: "/path")

        XCTAssertNotNil(request?.url)
        XCTAssertNil(request?.url?.query)
    }

    func testThatAlternateLocaleKeyIsHonoredWhenSpecified() async {
        var request: URLRequest?
        stub(condition: { _ in true }, response: {
            request = $0
            return HTTPStubsResponse(error: URLError(.networkConnectionLost))
        })

        let api = WordPressComRestApi(localeKey: "foo")

        let _ = await api.perform(.get, URLString: "/path/path")
        try XCTAssertTrue(XCTUnwrap(request?.url?.query).contains("foo="))
    }
}
