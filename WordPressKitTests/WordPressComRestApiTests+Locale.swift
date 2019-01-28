import Foundation
import XCTest

import WordPressShared
@testable import WordPressKit

extension WordPressComRestApiTests {

    func testThatAppendingLocaleWorks() {
        // Given
        let path = "/path/path"
        let preferredLanguageIdentifier = WordPressComLanguageDatabase().deviceLanguage.slug

        // When
        let localeAppendedPath = WordPressComRestApi.pathByAppendingPreferredLanguageLocale(path)

        // Then
        let actualURL = URL(string: localeAppendedPath, relativeTo: URL(string: WordPressComRestApi.apiBaseURLString))
        XCTAssertNotNil(actualURL)

        let actualURLComponents = URLComponents(url: actualURL!, resolvingAgainstBaseURL: false)
        XCTAssertNotNil(actualURLComponents)

        let expectedPath = path
        let actualPath = actualURLComponents!.path
        XCTAssertEqual(expectedPath, actualPath)

        let actualQueryItems = actualURLComponents!.queryItems
        XCTAssertNotNil(actualQueryItems)

        let expectedQueryItemCount = 1
        let actualQueryItemCount = actualQueryItems!.count
        XCTAssertEqual(expectedQueryItemCount, actualQueryItemCount)

        let actualQueryItem = actualQueryItems!.first
        XCTAssertNotNil(actualQueryItem!)

        let actualQueryItemKey = actualQueryItem!.name
        let expectedQueryItemKey = WordPressComRestApi.localeKey
        XCTAssertEqual(expectedQueryItemKey, actualQueryItemKey)

        let actualQueryItemValue = actualQueryItem!.value
        XCTAssertNotNil(actualQueryItemValue)

        let expectedQueryItemValue = preferredLanguageIdentifier
        XCTAssertEqual(expectedQueryItemValue, actualQueryItemValue!)
    }

    func testThatAppendingLocalePreservesExistingParams() {
        // Given
        let path = "/path/path?someKey=value"

        // When
        let localeAppendedPath = WordPressComRestApi.pathByAppendingPreferredLanguageLocale(path)

        // Then
        let actualURL = URL(string: localeAppendedPath, relativeTo: URL(string: WordPressComRestApi.apiBaseURLString))
        XCTAssertNotNil(actualURL)

        let actualURLComponents = URLComponents(url: actualURL!, resolvingAgainstBaseURL: false)
        XCTAssertNotNil(actualURLComponents)

        let expectedPath = "/path/path"
        let actualPath = actualURLComponents!.path
        XCTAssertEqual(expectedPath, actualPath)

        let actualQueryItems = actualURLComponents!.queryItems
        XCTAssertNotNil(actualQueryItems)

        let expectedQueryItemCount = 2
        let actualQueryItemCount = actualQueryItems!.count
        XCTAssertEqual(expectedQueryItemCount, actualQueryItemCount)

        let actualQueryString = actualURLComponents?.query
        XCTAssertNotNil(actualQueryString)

        let queryStringIncludesLocale = actualQueryString!.contains(WordPressComRestApi.localeKey)
        XCTAssertTrue(queryStringIncludesLocale)

        let queryStringIncludesSomeKey = actualQueryString!.contains("someKey")
        XCTAssertTrue(queryStringIncludesSomeKey)
    }

    func testThatAppendingLocaleIgnoresIfAlreadyIncludedInPath() {
        // Given
        let preferredLanguageIdentifier = "foo"
        let path = "/path/path?locale=\(preferredLanguageIdentifier)"

        // When
        let localeAppendedPath = WordPressComRestApi.pathByAppendingPreferredLanguageLocale(path)

        // Then
        let actualURL = URL(string: localeAppendedPath, relativeTo: URL(string: WordPressComRestApi.apiBaseURLString))
        XCTAssertNotNil(actualURL)

        let actualURLComponents = URLComponents(url: actualURL!, resolvingAgainstBaseURL: false)
        XCTAssertNotNil(actualURLComponents)

        let expectedPath = "/path/path"
        let actualPath = actualURLComponents!.path
        XCTAssertEqual(expectedPath, actualPath)

        let actualQueryItems = actualURLComponents!.queryItems
        XCTAssertNotNil(actualQueryItems)

        let expectedQueryItemCount = 1
        let actualQueryItemCount = actualQueryItems!.count
        XCTAssertEqual(expectedQueryItemCount, actualQueryItemCount)

        let actualQueryItem = actualQueryItems!.first
        XCTAssertNotNil(actualQueryItem!)

        let actualQueryItemKey = actualQueryItem!.name
        let expectedQueryItemKey = WordPressComRestApi.localeKey
        XCTAssertEqual(expectedQueryItemKey, actualQueryItemKey)

        let actualQueryItemValue = actualQueryItem!.value
        XCTAssertNotNil(actualQueryItemValue)

        let expectedQueryItemValue = preferredLanguageIdentifier
        XCTAssertEqual(expectedQueryItemValue, actualQueryItemValue!)
    }
}
