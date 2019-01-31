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
}
