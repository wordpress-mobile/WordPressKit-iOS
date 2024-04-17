#if SWIFT_PACKAGE
import APIInterface
@testable import CoreAPI
#else
@testable import WordPressKit
#endif
import XCTest

class WordPressOrgXMLRPCApiErrorTests: XCTestCase {

    func testNSErrorBridging() throws {
        for error in WordPressOrgXMLRPCApiError.Code.allCases {
            let xmlRPCError = try XCTUnwrap(WordPressOrgXMLRPCApiError(code: error))
            let apiError = WordPressAPIError.endpointError(xmlRPCError)
            let newNSError = apiError as NSError

            XCTAssertEqual(newNSError.domain, "WordPressKit.WordPressOrgXMLRPCApiError")
            XCTAssertEqual(newNSError.code, error.rawValue)
        }
    }

    func testErrorDomain() {
        XCTAssertEqual(WordPressOrgXMLRPCApiErrorDomain, WordPressOrgXMLRPCApiError.errorDomain)
    }
}
