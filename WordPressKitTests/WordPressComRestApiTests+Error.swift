import Foundation
import XCTest

@testable import WordPressKit

class WordPressComRestApiErrorTests: XCTestCase {

    func testNSErrorBridging() {
        for error in WordPressComRestApiErrorCode.allCases {
            let oldNSError = error as NSError

            let apiError = WordPressAPIError.endpointError(WordPressComRestApiEndpointError(code: error))
            let newNSError = apiError as NSError

            XCTAssertEqual(oldNSError.domain, "WordPressKit.WordPressComRestApiError")
            XCTAssertEqual(oldNSError.domain, newNSError.domain)

            XCTAssertEqual(oldNSError.code, error.rawValue)
            XCTAssertEqual(oldNSError.code, newNSError.code)
        }
    }

    func testErrorDomain() {
        XCTAssertEqual(WordPressComRestApiErrorDomain, WordPressComRestApiEndpointError.errorDomain)
    }

}
