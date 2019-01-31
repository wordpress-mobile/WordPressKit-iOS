import Foundation
import XCTest

@testable import WordPressKit

class ServiceRemoteWordPressComRESTTests: XCTestCase {

    func testRegularInitialization() {
        let api = WordPressComRestApi(oAuthToken: nil, userAgent: nil)

        XCTAssertNoThrow(ServiceRemoteWordPressComREST(wordPressComRestApi: api))
        let service = ServiceRemoteWordPressComREST(wordPressComRestApi: api)

        XCTAssertTrue(service.isKind(of: ServiceRemoteWordPressComREST.self))
        XCTAssertEqual(service.wordPressComRestApi, api)
    }

    func testLocaleKeyFor_1_x_VersionsReadsLocale() {
        let expectedKey = "locale"

        let api = WordPressComRestApi(oAuthToken: nil, userAgent: nil)
        let service = ServiceRemoteWordPressComREST(wordPressComRestApi: api)

        let actualKeyV1_0 = service.localeKey(forVersion: ._1_0)
        XCTAssertEqual(actualKeyV1_0, expectedKey)

        let actualKeyV1_1 = service.localeKey(forVersion: ._1_1)
        XCTAssertEqual(actualKeyV1_1, expectedKey)

        let actualKeyV1_2 = service.localeKey(forVersion: ._1_2)
        XCTAssertEqual(actualKeyV1_2, expectedKey)

        let actualKeyV1_3 = service.localeKey(forVersion: ._1_3)
        XCTAssertEqual(actualKeyV1_3, expectedKey)
    }

    func testLocaleKeyFor_2_x_VersionsReadsUnderscoreLocale() {
        let expectedKey = "_locale"

        let api = WordPressComRestApi(oAuthToken: nil, userAgent: nil)
        let service = ServiceRemoteWordPressComREST(wordPressComRestApi: api)

        let actualKey = service.localeKey(forVersion: ._2_0)
        XCTAssertEqual(actualKey, expectedKey)
    }
}
