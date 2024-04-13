#if SWIFT_PACKAGE
@testable import CoreAPI
#else
@testable import WordPressKit
#endif
import XCTest

class WordPressOrgXMLRPCApiErrorTests: XCTestCase {

    func testNSErrorBridging() throws {
        for error in WordPressOrgXMLRPCApiError.allCases {
            let xmlRPCError = try XCTUnwrap(WordPressOrgXMLRPCApiError(rawValue: error.rawValue))
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
