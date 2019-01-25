import Foundation
import XCTest

import WordPressShared
@testable import WordPressKit

extension WordPressComRestApiTests {

    func testThatAppendingLocaleWorks() {

        let path = "path/path"
        let localeKey = "locale"
        let preferredLanguageIdentifier = WordPressComLanguageDatabase().deviceLanguage.slug
        let expectedPath = "\(path)?\(localeKey)=\(preferredLanguageIdentifier)"

        let localeAppendedPath = WordPressComRestApi.pathByAppendingPreferredLanguageLocale(path)
        XCTAssert(localeAppendedPath == expectedPath, "Expected the locale to be appended to the path as (\(expectedPath)) but instead encountered (\(localeAppendedPath)).")
    }

    func testThatAppendingLocaleWorksWithExistingParams() {

        let path = "path/path?someKey=value"
        let localeKey = "locale"
        let preferredLanguageIdentifier = WordPressComLanguageDatabase().deviceLanguage.slug
        let expectedPath = "\(path)&\(localeKey)=\(preferredLanguageIdentifier)"

        let localeAppendedPath = WordPressComRestApi.pathByAppendingPreferredLanguageLocale(path)
        XCTAssert(localeAppendedPath == expectedPath, "Expected the locale to be appended to the path as (\(expectedPath)) but instead encountered (\(localeAppendedPath)).")
    }

    func testThatAppendingLocaleIgnoresIfAlreadyIncluded() {

        let localeKey = "locale"
        let preferredLanguageIdentifier = WordPressComLanguageDatabase().deviceLanguage.slug
        let path = "path/path?\(localeKey)=\(preferredLanguageIdentifier)&someKey=value"

        let localeAppendedPath = WordPressComRestApi.pathByAppendingPreferredLanguageLocale(path)
        XCTAssert(localeAppendedPath == path, "Expected the locale to already be appended to the path as (\(path)) but instead encountered (\(localeAppendedPath)).")
    }
}
