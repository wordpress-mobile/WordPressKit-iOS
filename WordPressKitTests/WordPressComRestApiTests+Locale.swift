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
        let api = WordPressComRestApi()
        let localeAppendedPath = api.buildRequestURLFor(path: path)

        // Then
        XCTAssertNotNil(localeAppendedPath)
        let actualURL = URL(string: localeAppendedPath!, relativeTo: URL(string: api.baseURLString))
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
        let expectedQueryItemKey = WordPressComRestApi.LocaleKeyDefault
        XCTAssertEqual(expectedQueryItemKey, actualQueryItemKey)

        let actualQueryItemValue = actualQueryItem!.value
        XCTAssertNotNil(actualQueryItemValue)

        let expectedQueryItemValue = preferredLanguageIdentifier
        XCTAssertEqual(expectedQueryItemValue, actualQueryItemValue!)
    }

    func testThatAppendingLocaleWorksWithExistingParams() {
        // Given
        let path = "/path/path"
        let params: [String: AnyObject] = [
            "someKey": "value" as AnyObject
        ]

        // When
        let api = WordPressComRestApi()
        let localeAppendedPath = api.buildRequestURLFor(path: path, parameters: params)

        // Then
        XCTAssertNotNil(localeAppendedPath)
        let actualURL = URL(string: localeAppendedPath!, relativeTo: URL(string: api.baseURLString))
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

        let actualQueryString = actualURLComponents?.query
        XCTAssertNotNil(actualQueryString)

        let queryStringIncludesLocale = actualQueryString!.contains(WordPressComRestApi.LocaleKeyDefault)
        XCTAssertTrue(queryStringIncludesLocale)
    }

    func testThatLocaleIsNotAppendedIfAlreadyIncludedInPath() {
        // Given
        let preferredLanguageIdentifier = "foo"
        let path = "/path/path?locale=\(preferredLanguageIdentifier)"

        // When
        let api = WordPressComRestApi()
        let localeAppendedPath = api.buildRequestURLFor(path: path)

        // Then
        XCTAssertNotNil(localeAppendedPath)
        let actualURL = URL(string: localeAppendedPath!, relativeTo: URL(string: api.baseURLString))
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
        let expectedQueryItemKey = WordPressComRestApi.LocaleKeyDefault
        XCTAssertEqual(expectedQueryItemKey, actualQueryItemKey)

        let actualQueryItemValue = actualQueryItem!.value
        XCTAssertNotNil(actualQueryItemValue)

        let expectedQueryItemValue = preferredLanguageIdentifier
        XCTAssertEqual(expectedQueryItemValue, actualQueryItemValue!)
    }

    func testThatAppendingLocaleIgnoresIfAlreadyIncludedInRequestParameters() {
        // Given
        let inputPath = "/path/path"
        let expectedLocaleValue = "foo"
        let params: [String: AnyObject] = [
            WordPressComRestApi.LocaleKeyDefault: expectedLocaleValue as AnyObject
        ]

        // When
        let requestURLString = WordPressComRestApi().buildRequestURLFor(path: inputPath, parameters: params)

        // Then
        let preferredLanguageIdentifier = WordPressComLanguageDatabase().deviceLanguage.slug
        XCTAssertFalse(requestURLString!.contains(preferredLanguageIdentifier))
    }

    func testThatLocaleIsNotAppendedWhenDisabled() {
        // Given
        let path = "/path/path"

        // When
        let api = WordPressComRestApi()
        api.appendsPreferredLanguageLocale = false
        let localeAppendedPath = api.buildRequestURLFor(path: path)

        // Then
        XCTAssertNotNil(localeAppendedPath)
        let actualURL = URL(string: localeAppendedPath!, relativeTo: URL(string: api.baseURLString))
        XCTAssertNotNil(actualURL)

        let actualURLComponents = URLComponents(url: actualURL!, resolvingAgainstBaseURL: false)
        XCTAssertNotNil(actualURLComponents)

        let expectedPath = path
        let actualPath = actualURLComponents!.path
        XCTAssertEqual(expectedPath, actualPath)

        let actualQueryItems = actualURLComponents!.queryItems
        XCTAssertNil(actualQueryItems)
    }

    func testThatAlternateLocaleKeyIsHonoredWhenSpecified() {
        // Given
        let path = "/path/path"
        let expectedKey = "foo"

        // When
        let api = WordPressComRestApi(localeKey: expectedKey)
        let localeAppendedPath = api.buildRequestURLFor(path: path)

        // Then
        XCTAssertNotNil(localeAppendedPath)
        let actualURL = URL(string: localeAppendedPath!, relativeTo: URL(string: api.baseURLString))
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
        XCTAssertEqual(expectedKey, actualQueryItemKey)
    }

    func testThatAppendingLocaleWorksWhenPassingNilParameters() {
        // Given
        let path = "/path/path"
        let preferredLanguageIdentifier = WordPressComLanguageDatabase().deviceLanguage.slug

        // When
        let api = WordPressComRestApi()
        let localeAppendedPath = WordPressComRestApi().buildRequestURLFor(path: path, parameters: nil)

        // Then
        XCTAssertNotNil(localeAppendedPath)
        let actualURL = URL(string: localeAppendedPath!, relativeTo: URL(string: api.baseURLString))
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
        let expectedQueryItemKey = WordPressComRestApi.LocaleKeyDefault
        XCTAssertEqual(expectedQueryItemKey, actualQueryItemKey)

        let actualQueryItemValue = actualQueryItem!.value
        XCTAssertNotNil(actualQueryItemValue)

        let expectedQueryItemValue = preferredLanguageIdentifier
        XCTAssertEqual(expectedQueryItemValue, actualQueryItemValue!)
    }

    func testThatLocaleIsNotAppendedWhenDisabledAndParametersAreNil() {
        // Given
        let path = "/path/path"

        // When
        let api = WordPressComRestApi()
        api.appendsPreferredLanguageLocale = false
        let localeAppendedPath = api.buildRequestURLFor(path: path, parameters: nil)

        // Then
        XCTAssertNotNil(localeAppendedPath)
        let actualURL = URL(string: localeAppendedPath!, relativeTo: URL(string: api.baseURLString))
        XCTAssertNotNil(actualURL)

        let actualURLComponents = URLComponents(url: actualURL!, resolvingAgainstBaseURL: false)
        XCTAssertNotNil(actualURLComponents)

        let expectedPath = path
        let actualPath = actualURLComponents!.path
        XCTAssertEqual(expectedPath, actualPath)

        let actualQueryItems = actualURLComponents!.queryItems
        XCTAssertNil(actualQueryItems)
    }
}
